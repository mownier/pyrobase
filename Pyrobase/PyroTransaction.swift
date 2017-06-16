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
    internal(set) public var temporaryPathExpiration: UInt
    
    public var baseURL: String {
        return path.baseURL
    }
    
    public class func create(baseURL: String, accessToken: String, maxTry: UInt = 100, temporaryPath: String = "pyrobase_transactions", temporaryPathExpiration: UInt = 30) -> PyroTransaction {
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = Request.create()
        let transaction = PyroTransaction(request: request, path: path, maxTry: maxTry, temporaryPath: temporaryPath, temporaryPathExpiration: temporaryPathExpiration)
        return transaction
    }
    
    public init(request: RequestProtocol, path: RequestPathProtocol, maxTry: UInt, temporaryPath: String, temporaryPathExpiration: UInt) {
        self.request = request
        self.path = path
        self.maxTry = maxTry
        self.tryCount = 0
        self.temporaryPath = temporaryPath
        self.temporaryPathExpiration = temporaryPathExpiration
    }
    
    public func run(parentPath: String, childKey: String, mutator: @escaping (Any) -> Any, completion: @escaping (RequestResult) -> Void) {
        let readPath = path.build("\(temporaryPath)/\(parentPath)/\(childKey)")
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
                
                let info = ["\(param.parentPath)/\(param.childKey)": [".sv": "timestamp"]]
                let writePath = self.path.build(self.temporaryPath)
                self.writeTransaction(param: param, info: info, writePath: writePath)
                
            case .succeeded(let info):
                guard let string = info as? String, let timestamp = Double(string) else {
                    self.checkTryCount(param: param) {
                        self.readTransaction(param: param, readPath: readPath)
                    }
                    return
                }
                
                let now = Date()
                let transactionDate = Date(timeIntervalSince1970: timestamp / 1000)
                let seconds: Int = Calendar.current.dateComponents([.second], from: transactionDate, to: now).second ?? 0
                
                if seconds > Int(self.temporaryPathExpiration) {
                    let info = ["\(param.parentPath)/\(param.childKey)": [".sv": "timestamp"]]
                    let writePath = self.path.build(self.temporaryPath)
                    self.writeTransaction(param: param, info: info, writePath: writePath)
                
                } else {
                    self.checkTryCount(param: param) {
                        self.readTransaction(param: param, readPath: readPath)
                    }
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
                self.deleteTransaction(param: param) { _ in
                    param.completion(result)
                }
            }
        }
    }
    
    internal func deleteTransaction(param: Parameter, completion: @escaping (RequestResult) -> Void) {
        let deletePath = path.build("\(temporaryPath)/\(param.parentPath)")
        request.delete(path: deletePath) { result in
            completion(result)
        }
    }
    
    internal func checkTryCount(param: Parameter, pass: @escaping () -> Void) {
        if tryCount + 1 == maxTry {
            deleteTransaction(param: param) { _ in
                param.completion(.failed(RequestError.maxTryReached))
                self.tryCount = 0
            }
            
        } else {
            tryCount += 1
            pass()
        }
    }
}

