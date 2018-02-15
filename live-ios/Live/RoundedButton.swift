//
//  RoundedButton.swift
//  Live
//
//  Created by Matt Schrage on 2/9/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit


extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x:0, y:0, width:1, height:1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width:1, height:1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

class RoundedButton: UIButton {
    @IBInspectable var color : UIColor! =  App.theme.secondaryColor {
        didSet {
            self.setBackgroundImage(UIImage.imageWithColor(color: self.color), for: .normal)
        }
    }
    @IBInspectable var highlightedColor : UIColor! = App.theme.secondaryColor.lighter(by:10)
    
    @IBInspectable var cornerRadius : CGFloat = 10.0 {
        didSet{
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable var fontSize : UIFont! = UIFont(name: "Avenir", size: 16){
        didSet{
            self.titleLabel?.font = self.fontSize;
        }
    }

    
    func initialize(frame: CGRect){
        self.titleLabel?.backgroundColor = UIColor.clear
        self.frame = frame.insetBy(dx:-3, dy:-5)//CGRect(x:50, y:70, width: 120, height: 44)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
        
        self.titleLabel?.textAlignment = NSTextAlignment.center

        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.cornerRadius
        self.setBackgroundImage(UIImage.imageWithColor(color: self.color), for: .normal)
        self.setBackgroundImage(UIImage.imageWithColor(color: self.highlightedColor), for: .highlighted)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize(frame: self.bounds)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize(frame: frame)

    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
