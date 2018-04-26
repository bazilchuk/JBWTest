//
//  APIClient.swift
//  JBWTest
//
//  Created by Andrew on 25.04.2018.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class APIClient {
    
    private func composeRequest(postData: Dictionary<String, String>?,
                                path: String,
                                completion: @escaping ((_ message: String?) -> Void)) -> URLRequest{
        
        let baseUrl = URL(string: "https://apiecho.cf\(path)")
        var request = URLRequest(url: baseUrl!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = KeychainWrapper.standard.string(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion("No token in keyChain.")
        }
        
        if let userData = postData {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: .prettyPrinted)
            } catch let error {
                completion(error.localizedDescription)
            }
        }
        
        return request
    }
    
    func login(postData: Dictionary<String, String>, completion: @escaping((_ message: String, _ success: Bool) -> ())) {
        
        var endpoint = composeRequest(postData: postData, path: "/api/login/") { (message) in
            if let message = message, message != ""  {
                completion(message, false)
            }
        }
        endpoint.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: endpoint) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                completion("Could not perform request. Try later.", false)
                
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                guard let parseJson = json else {
                    completion("Could not perform request. Try later.", false)
                    
                    return
                }
                
                guard let success = parseJson["success"] as? Bool else {
                    
                    return
                }
                
                if success == false {
                    let response = parseJson["errors"] as? NSArray
                    let errors = response![0] as? NSDictionary
                    let errorMessage = errors!["message"] as? String
                    completion(errorMessage!, false)
                } else {
                    
                    guard let userData = parseJson["data"] as? NSDictionary else {
                    completion("Could not get access token. Try later.", false)
                        
                    return
                }
                    let accessToken = userData["access_token"] as? String

                    let saveSuccessfuly: Bool = KeychainWrapper.standard.set(accessToken!, forKey: "accessToken")
                completion("", true)
                }
            } catch {
                completion("Could not perform request. Try later.", false)
            }
        }
        task.resume()
    }
    
    func signup(postData: Dictionary<String, String>, completion: @escaping((_ message: String) -> ())) {
        
        var endpoint = composeRequest(postData: postData, path: "/api/signup/") { (message) in
            if let message = message, message != ""  {
                completion(message)
            }
        }
        
        endpoint.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: endpoint) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                completion("Could not perform request. Try later.")
                
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                guard let parseJson = json as? NSDictionary else {
                    completion("Could not perform request. Try later.")
                    
                    return
                }
                
                guard let success = parseJson["success"] as? Bool else {
                    
                    return
                }
                
                if success == false {
                    let response = parseJson["errors"] as? NSArray
                    let errors = response![0] as? NSDictionary
                    let errorMessage = errors!["message"] as? String
                    
                    completion(errorMessage!)
                } else {
                        completion("New account registrated successfuly.")
                }
    
            } catch {
                completion("Could not perform request. Try later.")
            }
        }
        task.resume()
    }
    
    func logout(completion: @escaping((_ message: String, _ success: Bool) -> ())) {
        
        var endpoint = composeRequest(postData: nil, path: "/api/logout/") { (message) in
            if let message = message, message != ""  {
                completion(message, false)
            }
        }
        endpoint.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: endpoint) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                completion("Could not perform request. Try later.", false)
                
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                guard let parseJson = json, parseJson != nil else {
                    completion("Could not perform request. Try later.", false)
                    
                    return
                }
                
                guard let success = parseJson["success"] as? Bool else {
                    
                    return
                }
                
                if success == false {
                    
                    let response = parseJson["errors"] as? NSArray
                    let errors = response![0] as? NSDictionary
                    let errorMessage = errors!["message"] as? String
                    
                    completion(errorMessage!, false)
                } else {
                    completion("Successfuly logged out.", true)
                }
                
            } catch {
                completion("Could not perform request. Try later.", false)
            }
        }
        task.resume()
    }
    
    func fetchData(completion: @escaping((_ message: String, _ success: Bool, _ text: String) -> ())) {
        
        var endpoint = composeRequest(postData: nil, path: "/api/get/text/") { (message) in
            if let message = message, message != ""  {
                completion(message, false, "")
            }
        }
        endpoint.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: endpoint) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                completion("Could not perform request. Try later.", false, "")
                
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                guard let parseJson = json, parseJson != nil else {
                    completion("Could not perform request. Try later.", false, "")
                    return
                }
                
                guard let text = parseJson["data"] as? String, text != "" else {
                    let err = parseJson["errors"] as? NSDictionary
                    let errorMessage = err!["message"] as? String
                    completion(errorMessage!, false, "")
                    return
                }
                
                completion("", true, text)
                
            } catch {
                completion("Could not perform request. Try later.", false, "")
            }
        }
        task.resume()
    }
    
}
