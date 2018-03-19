//
//  Model.swift
//  Live
//
//  Created by leo on 16/7/13.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import Foundation

struct Room {
    
    var key: String
    var title: String
    
    init(dict: [String: AnyObject]) {
        title = dict["title"] as! String
        key = dict["key"] as! String
    }
    
    func toDict() -> [String: AnyObject] {
        return [
            "title": title as AnyObject,
            "key": key as AnyObject
        ]
    }
}


struct Comment {
    
    var text: String
    var user: String

    init(dict: [String: AnyObject]) {
        text = dict["text"] as! String
        user = ""//dict["user"] as! String

    }
}


struct User {
    enum Key : String {
        case username   = "username"
        case password   = "password"
        case email      = "email"
        case pushToken  = "pushToken"
        case registered = "registered"
        case balance    = "balance"

    }
    
    var id = Int(arc4random())
    var username:String? {
        set(val) {
            UserDefaults.standard.set(val, forKey: Key.username.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Key.username.rawValue)
        }
    }
    //password is just set temporarily @ login flow. Shouldn't be stored in user defaults.
    var password:String?
    var email:String? {
        set(val) {
            UserDefaults.standard.set(val, forKey: Key.email.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Key.email.rawValue)
        }
    }
    var pushToken:String? {
        set(val) {
            UserDefaults.standard.set(val, forKey: Key.pushToken.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Key.pushToken.rawValue)
        }
    }
    
    var registered: Bool {
        set(val) {
            UserDefaults.standard.set(val, forKey: Key.registered.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: Key.registered.rawValue)
        }
    }
    
    var balance: String? {
        set(val) {
            UserDefaults.standard.set(val, forKey: Key.balance.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Key.balance.rawValue)
        }
    }
    
    static var currentUser = User()
}


class GiftEvent: NSObject {
    
    var senderId: Int
    
    var giftId: Int
    
    var giftCount: Int
    
    init(dict: [String: AnyObject]) {
        senderId = dict["senderId"] as! Int
        giftId = dict["giftId"] as! Int
        giftCount = dict["giftCount"] as! Int
    }
    
    func shouldComboWith(_ event: GiftEvent) -> Bool {
        return senderId == event.senderId && giftId == event.giftId
    }
    
}


