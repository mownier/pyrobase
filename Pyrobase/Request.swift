//
//  Request.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol RequestProtocol {
    
    func read(path: String, completion: @escaping (Any) -> Void)
}

public class Request: RequestProtocol {
    
    internal var session: URLSession
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    public func read(path: String, completion: @escaping (Any) -> Void) {
        let url = URL(string: path)!
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil, data != nil else {
                completion([AnyHashable: Any]())
                return
            }
            
            let result: Any
            
            do {
                if JSONSerialization.isValidJSONObject(data!) {
                    result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                } else {
                    result = String(data: data!, encoding: .utf8)
                }
            } catch {
                completion([AnyHashable: Any]())
                return
            }
   
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(result)
            } else {
                completion([AnyHashable: Any]())
            }
        }
        task.resume()
    }
}
