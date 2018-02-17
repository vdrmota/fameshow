//
//  PushNotificationViewController.swift
//  Live
//
//  Created by Matt Schrage on 2/15/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit
import UserNotifications

class PushNotificationViewController: UIViewController {
    private let baseURL = "http://cs50.vojtadrmota.com/fame"

    override func viewDidLoad() {
        view.backgroundColor = App.theme.primaryColor

        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didRegister(notification:)), name: .didRegister, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFailToRegister), name: .didFailToRegister, object: nil)
        

        // Do any additional setup after loading the view.
    }

    @IBAction func requestPermission () {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    @IBAction func skip () {
        DispatchQueue.main.async {
            let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "masthead")
            nextVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(nextVC, animated: true, completion: nil)
        }
    }
    
    @objc func didFailToRegister () {
        self.skip()
    }
    
    @objc func didRegister (notification : Notification) {
        let token = notification.object as! String!
        
        // push token to server
        let url = URL(string: self.baseURL + "/token.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(User.currentUser.username!)&token=\(token!)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            
            if responseString == "1" {
                User.currentUser.pushToken = token
                DispatchQueue.main.async {
//                    let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "masthead")
//                    nextVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//                    self.present(nextVC, animated: true, completion: nil)
                    self.skip()
                }
            } else {
                // else animation and show error text
                print("error")
                
            }
            
        }
        task.resume()
        
        self.skip()
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
