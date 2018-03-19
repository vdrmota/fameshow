//
//  Colors.swift
//  Live
//
//  Created by Matt Schrage on 2/14/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit

extension Notification.Name {
    
    static let didRegister = Notification.Name(rawValue: "didRegisterForRemoteNotificationsWithDeviceToken")
    static let didFailToRegister = Notification.Name(rawValue: "didFailToRegisterForRemoteNotifications")
    
    static let showDidFinish = Notification.Name(rawValue: "showDidFinish")

}

struct App {
    var primaryColor   : UIColor = UIColor(red:0.93, green:0.32, blue:0.33, alpha:1.0)//UIColor(red:1.00, green:0.79, blue:0.34, alpha:1.0)
    var secondaryColor : UIColor = UIColor(red:1.00, green:0.79, blue:0.34, alpha:1.0)//UIColor(red:0.93, green:0.32, blue:0.33, alpha:1.0)
    var warningColor   : UIColor = UIColor(red:0.84, green:0.19, blue:0.19, alpha:1.0)

    //var font    : UIFont  = UIFont(name: "Avenir", size: 16)

    static let theme = App()
    
    static func get(_ endpoint: String, completion: @escaping (String) -> Void) {
        let url = URL(string: Config.phpUrl + endpoint)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                completion(responseString!)
            }
        }
        
        task.resume()
    }
    
    static func post(_ endpoint: String, parameters: Dictionary<String, String>, completion: @escaping (String) -> Void) {
        let url = URL(string: Config.phpUrl + endpoint)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var postString = parameters.reduce("", { $0 + $1.0 + "=" + $1.1 + "&"})
        
        postString = String(postString.dropLast())
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                completion(responseString!)
            }
            
        }
        task.resume()
    }

}
