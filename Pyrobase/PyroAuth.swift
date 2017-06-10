//
//  PyroAuth.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 05/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public class PyroAuth {

    internal var key: String
    internal var request: RequestProtocol
    internal var signInPath: String
    internal var registerPath: String
    
    public init(key: String, request: RequestProtocol, signInPath: String, registerPath: String) {
        self.key = key
        self.request = request
        self.signInPath = signInPath
        self.registerPath = registerPath
    }
    
    public func register(email: String, password: String, completion: @escaping (PyroAuthResult) -> Void) {
        let data: [AnyHashable: Any] = ["email": email, "password": password, "returnSecureToken": true]
        let path = "\(registerPath)?key=\(key)"
        request.write(path: path, method: .post, data: data) { result in
            self.handleRequestResult(result, completion: completion)
        }
    }
    
    public func signIn(email: String, password: String, completion: @escaping (PyroAuthResult) -> Void) {
        let data: [AnyHashable: Any] = ["email": email, "password": password, "returnSecureToken": true]
        let path = "\(signInPath)?key=\(key)"
        request.write(path: path, method: .post, data: data) { result in
            self.handleRequestResult(result, completion: completion)
        }
    }
    
    internal func handleRequestResult(_ result: RequestResult, completion: @escaping (PyroAuthResult) -> Void) {
        switch result {
        case .succeeded(let info):
            guard let resultInfo = info as? [AnyHashable: Any] else {
                completion(.failed(PyroAuthError.unexpectedContent))
                return
            }
            
            guard let userId = resultInfo["localId"] as? String,
                let email = resultInfo["email"] as? String,
                let accessToken = resultInfo["idToken"] as? String,
                let refreshToken = resultInfo["refreshToken"] as? String,
                let expiration = resultInfo["expiresIn"] as? String else {
                    return completion(.failed(PyroAuthError.incompleteContent))
            }
            
            var content = PyroAuthContent()
            content.userId = userId
            content.email = email
            content.accessToken = accessToken
            content.refreshToken = refreshToken
            content.expiration = expiration
            
            completion(.succeeded(content))
            
        case .failed(let info):
            completion(.failed(info))
        }
    }
}

extension PyroAuth {
    
    public class func create(key: String, bundle: Bundle = .main, plistName: String = "PyroAuthInfo", request: RequestProtocol = Request.create() ) -> PyroAuth? {
        guard let reader = PlistReader.create(name: plistName, bundle: bundle) else {
            return nil
        }
        
        var registerPath: String = ""
        var signInPath: String = ""
        if let readerInfo = reader.data as? [AnyHashable: Any] {
            registerPath = (readerInfo["register_path"] as? String) ?? ""
            signInPath = (readerInfo["sign_in_path"] as? String) ?? ""
        }
        
        let auth = PyroAuth(key: key, request: request, signInPath: signInPath, registerPath: registerPath)
        return auth
    }
}
