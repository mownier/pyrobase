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
    internal var tempPath: PyroTransactionTemporaryPathProtocol
    
    public var baseURL: String {
        return path.baseURL
    }
    
    public class func create(baseURL: String, accessToken: String) -> PyroTransaction {
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = Request.create()
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        return transaction
    }
    
    public init(request: RequestProtocol, path: RequestPathProtocol, tempPath: PyroTransactionTemporaryPathProtocol) {
        self.request = request
        self.path = path
        self.tempPath = tempPath
    }
    
    public func run(parentPath: String, childKey: String, mutator: @escaping (Any) -> Any, completion: @escaping (PyroTransactionResult) -> Void) {
        let param = Parameter(parentPath: parentPath, childKey: childKey, mutator: mutator, completion: completion)
        
        readTransaction(param: param)
    }
    
    internal func readTransaction(param: Parameter) {
        let readPath = path.build("\(tempPath.key)/\(param.parentPath)/\(param.childKey)")
        
        request.read(path: readPath, query: [:]) { result in
            switch result {
            case .failed(let info):
                guard let errorInfo = info as? RequestError, errorInfo == .nullJSON else {
                    param.completion(.failed(info))
                    return
                }
                
                self.writeTransaction(param: param)
                
            case .succeeded(let info):
                guard let string = info as? String, let timestamp = Double(string) else {
                    param.completion(.failed(PyroTransactionError.invalidExpirationTimestamp))
                    return
                }
                
                if self.tempPath.isTransactionDateExpired(timestamp, now: Date()) {
                    self.writeTransaction(param: param)
                    
                } else {
                    param.completion(.failed(PyroTransactionError.activeTransactionNotDone))
                }
            }
        }
    }
    
    internal func writeTransaction(param: Parameter) {
        let info = ["\(param.parentPath)/\(param.childKey)": [".sv": "timestamp"]]
        let writePath = path.build(tempPath.key)
        
        request.write(path: writePath, method: .patch, data: info) { result in
            switch result {
            case .failed(let info):
                param.completion(.failed(info))
                
            case .succeeded:
                self.readChild(param: param)
            }
        }
    }
    
    internal func readChild(param: Parameter) {
        let readPath = path.build("\(param.parentPath)/\(param.childKey)")
        
        request.read(path: readPath, query: [:]) { result in
            switch result {
            case .failed(let info):
                self.deleteTransaction(param: param) { _ in
                    param.completion(.failed(info))
                }
                
            case .succeeded(let info):
                self.writeChild(param: param, info: info)
            }
        }
    }
    
    internal func writeChild(param: Parameter, info: Any) {
        let newInfo = param.mutator(info)
        let writePath = path.build(param.parentPath)
        let data = [param.childKey: newInfo]
        
        request.write(path: writePath, method: .patch, data: data) { result in
            let completion: (RequestResult) -> Void
            
            switch result {
            case .failed(let info):
                completion = { _ in param.completion(.failed(info)) }
                
            case .succeeded(let info):
                completion = { _ in param.completion(.succeeded(info)) }
            }
            
            self.deleteTransaction(param: param, completion: completion)
        }
    }
    
    internal func deleteTransaction(param: Parameter, completion: @escaping (RequestResult) -> Void) {
        let deletePath = path.build("\(tempPath.key)/\(param.parentPath)")
        
        request.delete(path: deletePath) { result in
            completion(result)
        }
    }
}

