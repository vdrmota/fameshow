//
//  AppDelegate.swift
//  Live
//
//  Created by leo on 16/7/11.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
//import TextAttributes
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        application.isIdleTimerDisabled = true
//        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//        UserDefaults.standard.synchronize()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Override point for customization after application launch.
        //UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        //application.registerForRemoteNotifications()
        
        //UINavigationBar.appearance().clipsToBounds = true
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        
        statusBar.backgroundColor = UIColor.colorWithRGB(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        let navigationBar = UINavigationBar.appearance();
        
        let navigationTitleFont = UIFont(name: "Avenir", size: 20)!
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont]
        
        navigationBar.barTintColor = UIColor.white
        navigationBar.isTranslucent = false
        
        //setupAppearance()
        
        if (!User.currentUser.registered) {
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let initialVC = storyboard.instantiateViewController(withIdentifier: "initial")
            self.window?.rootViewController = initialVC;
        }
        
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            // User is registered for notification
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }

        }
        
        return true
    }
    
    fileprivate func setupAppearance() {
        let navigationBar = UINavigationBar.appearance();
        navigationBar.tintColor = UIColor.white
        navigationBar.barTintColor = UIColor.white
        navigationBar.isTranslucent = false
//        let titleAttrs = TextAttributes()
//            .font(UIFont.defaultFont(size: 19))
//            .foregroundColor(UIColor.white)
        navigationBar.titleTextAttributes = nil//titleAttrs.dictionary
        
        let barButtonItem = UIBarButtonItem.appearance()
//        let barButtonAttrs = TextAttributes()
//            .font(UIFont.defaultFont(size: 15))
//            .foregroundColor(UIColor.white)
        //barButtonAttrs.dictionary
        barButtonItem.setTitleTextAttributes(nil, for: .normal)
        barButtonItem.setTitleTextAttributes(nil, for: .highlighted)
        
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        NotificationCenter.default.post(name: .didRegister, object: deviceTokenString)
        
        let url = URL(string: Config.phpUrl + "/token.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(User.currentUser.username! )&token=\(deviceTokenString)"
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
                User.currentUser.pushToken = deviceTokenString
                //                DispatchQueue.main.async {
                ////                    let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "masthead")
                ////                    nextVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                ////                    self.present(nextVC, animated: true, completion: nil)
                //                    self.skip()
                //                }
            } else {
                // else animation and show error text
                print("error")
                
            }
            
        }
        task.resume()
        
        

        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // Persist it in your backend in case it's new
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
        
         NotificationCenter.default.post(name:.didFailToRegister, object: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
    }

    
    //KEY ID: 92BND42T3H
    //TEAM ID: D93PPD94WK

}

