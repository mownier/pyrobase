//
//  PyroTransaction.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 15/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public class PyroTransaction {
    
    internal var path: RequestPathProtocol
    internal var request: RequestProtocol
    internal var tryCount: UInt
    internal(set) public var maxTry: UInt
    internal(set) public var temporaryPath: String
    
    public var baseURL: String {
        return path.baseURL
    }
    
    public class func create(baseURL: String, accessToken: String, maxTry: UInt = 100, temporaryPath: String = "pyrobase_transactions") -> PyroTransaction {
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = Request.create()
        let transaction = PyroTransaction(request: request, path: path, maxTry: maxTry, temporaryPath: temporaryPath)
        return transaction
    }
    
    public init(request: RequestProtocol, path: RequestPathProtocol, maxTry: UInt, temporaryPath: String) {
        self.request = request
        self.path = path
        self.maxTry = maxTry
        self.tryCount = 0
        self.temporaryPath = temporaryPath
    }
    
    public func run(parentPath: String, childKey: String, mutator: @escaping (Any) -> Any, completion: @escaping (RequestResult) -> Void) {
        let readPath = path.build("\(temporaryPath)/\(parentPath)")
        let param = Parameter(parentPath: parentPath, childKey: childKey, mutator: mutator, completion: completion)
        readTransaction(param: param, readPath: readPath)
    }
    
    internal func readTransaction(param: Parameter, readPath: String) {
        request.read(path: readPath, query: [:]) { result in
            switch result {
            case .failed(let info):
                guard let errorInfo = info as? RequestError, errorInfo == .nullJSON else {
                    self.checkTryCount(param: param) {
                        self.readTransaction(param: param, readPath: readPath)
                    }
                    return
                }
                
                let info = [param.parentPath: true]
                let writePath = self.path.build(self.temporaryPath)
                self.writeTransaction(param: param, info: info, writePath: writePath)
                
            case .succeeded:
                self.checkTryCount(param: param) {
                    self.readTransaction(param: param, readPath: readPath)
                }
            }
        }
    }
    
    internal func writeTransaction(param: Parameter, info: [AnyHashable: Any], writePath: String) {
        request.write(path: writePath, method: .patch, data: info) { result in
            switch result {
            case .failed:
                self.checkTryCount(param: param) {
                    self.writeTransaction(param: param, info: info, writePath: writePath)
                }
                
            case .succeeded:
                let readPath = self.path.build("\(param.parentPath)/\(param.childKey)")
                self.readChild(param: param, readPath: readPath)
            }
        }
    }
    
    internal func readChild(param: Parameter, readPath: String) {
        request.read(path: readPath, query: [:]) { result in
            switch result {
            case .failed:
                param.completion(result)
                
            case .succeeded(let info):
                let newInfo = param.mutator(info)
                let writePath = self.path.build(param.parentPath)
                let data = [param.childKey: newInfo]
                self.writeChild(param: param, info: data, writePath: writePath)
            }
        }
    }
    
    internal func writeChild(param: Parameter, info: [AnyHashable: Any], writePath: String) {
        request.write(path: writePath, method: .patch, data: info) { result in
            switch result {
            case .failed:
                self.checkTryCount(param: param) {
                    self.writeChild(param: param, info: info, writePath: writePath)
                }
                
            case .succeeded:
                self.deleteTransaction(param: param)
                param.completion(result)
            }
        }
    }
    
    internal func deleteTransaction(param: Parameter) {
        let deletePath = path.build("\(temporaryPath)/\(param.parentPath)")
        request.delete(path: deletePath) { _ in }
    }
    
    internal func checkTryCount(param: Parameter, pass: () -> Void) {
        if tryCount + 1 == maxTry {
            deleteTransaction(param: param)
            param.completion(.failed(RequestError.maxTryReached))
            tryCount = 0
            
        } else {
            tryCount += 1
            pass()
        }
    }
}

struct Parameter {
    
    let parentPath: String
    let childKey: String
    let mutator: (Any) -> Any
    let completion: (RequestResult) -> Void
    
    init(parentPath: String, childKey: String, mutator: @escaping (Any) -> Any, completion: @escaping (RequestResult) -> Void) {
        self.parentPath = parentPath
        self.childKey = childKey
        self.mutator = mutator
        self.completion = completion
    }
}
