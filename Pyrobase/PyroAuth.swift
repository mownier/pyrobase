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
    internal var refreshPath: String
    internal var confirmationCodePath: String
    
    public init(key: String, request: RequestProtocol, signInPath: String, registerPath: String, refreshPath: String, confirmationCodePath: String) {
        self.key = key
        self.request = request
        self.signInPath = signInPath
        self.registerPath = registerPath
        self.refreshPath = refreshPath
        self.confirmationCodePath = confirmationCodePath
    }
    
    public func register(email: String, password: String, completion: @escaping (PyroAuthResult<PyroAuthContent>) -> Void) {
        let data: [AnyHashable: Any] = ["email": email, "password": password, "returnSecureToken": true]
        let path = "\(registerPath)?key=\(key)"
        request.write(path: path, method: .post, data: data) { result in
            self.handleRequestResult(result, completion: completion)
        }
    }
    
    public func signIn(email: String, password: String, completion: @escaping (PyroAuthResult<PyroAuthContent>) -> Void) {
        let data: [AnyHashable: Any] = ["email": email, "password": password, "returnSecureToken": true]
        let path = "\(signInPath)?key=\(key)"
        request.write(path: path, method: .post, data: data) { result in
            self.handleRequestResult(result, completion: completion)
        }
    }
    
    public func refresh(token: String, completion: @escaping (PyroAuthResult<PyroAuthTokenContent>) -> Void) {
        let data: [AnyHashable: Any] = ["grant_type": "refresh_token", "refresh_token": token]
        let path = "\(refreshPath)?key=\(key)"
        request.write(path: path, method: .post, data: data) { result in
            switch result {
            case .succeeded(let info):
                guard let resultInfo = info as? [AnyHashable: Any] else {
                    completion(.failed(PyroAuthError.unexpectedContent))
                    return
                }
                
                guard let accessToken = resultInfo["access_token"] as? String,
                    let refreshToken = resultInfo["refresh_token"] as? String,
                    let expiration = resultInfo["expires_in"] as? String else {
                    return completion(.failed(PyroAuthError.incompleteContent))
                }
                
                var content = PyroAuthTokenContent()
                content.accessToken = accessToken
                content.refreshToken = refreshToken
                content.expiration = expiration
                
                completion(.succeeded(content))
            
            case .failed(let info):
                completion(.failed(info))
            }
        }
    }
    
    public func sendPasswordReset(email: String, completion: @escaping (PyroAuthResult<Bool>) -> Void) {
        let data: [AnyHashable: Any] = ["requestType": "PASSWORD_RESET", "email": email]
        let path = "\(confirmationCodePath)?key=\(key)"
        request.write(path: path, method: .post, data: data) { result in
            switch result {
            case .succeeded:
                completion(.succeeded(true))
            
            case .failed(let info):
                completion(.failed(info))
            }
        }
    }
    
    internal func handleRequestResult(_ result: RequestResult, completion: @escaping (PyroAuthResult<PyroAuthContent>) -> Void) {
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
        var refreshPath: String = ""
        var confirmationCodePath: String = ""
        
        if let readerInfo = reader.data as? [AnyHashable: Any] {
            registerPath = (readerInfo["register_path"] as? String) ?? ""
            signInPath = (readerInfo["sign_in_path"] as? String) ?? ""
            refreshPath = (readerInfo["refresh_path"] as? String) ?? ""
            confirmationCodePath = (readerInfo["confirmation_code_path"] as? String) ?? ""
        }
        
        let auth = PyroAuth(key: key, request: request, signInPath: signInPath, registerPath: registerPath, refreshPath: refreshPath, confirmationCodePath: confirmationCodePath)
        return auth
    }
}
