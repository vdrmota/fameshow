//
//  Colors.swift
//  Live
//
//  Created by Matt Schrage on 2/14/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit

struct App {
    var primaryColor   : UIColor = UIColor(red:0.93, green:0.32, blue:0.33, alpha:1.0)//UIColor(red:1.00, green:0.79, blue:0.34, alpha:1.0)
    var secondaryColor : UIColor = UIColor(red:1.00, green:0.79, blue:0.34, alpha:1.0)//UIColor(red:0.93, green:0.32, blue:0.33, alpha:1.0)
    var warningColor   : UIColor = UIColor(red:0.84, green:0.19, blue:0.19, alpha:1.0)

    //var font    : UIFont  = UIFont(name: "Avenir", size: 16)
    
    static let theme = App()
}
