//
//  BubbleChatAnimation.swift
//  Bubblechat
//
//  Created by Matt Schrage on 2/18/16.
//  Copyright © 2016 Matt Schrage. All rights reserved.
//

import UIKit

enum Animation {
    case grow, shrink, fadeOut, fadeIn, spin, wobble, pulse, horizontal, vertical, hidden
}

class AnimationOptions : NSObject{
    var startPoint: CGPoint?
    var startRect: CGRect?
    var endPoint: CGPoint?
    var endRect: CGRect?
    
    var characterSize: CGFloat? 
    var characterSizeRange: (CGFloat, CGFloat) = (24, 24)
    
    var canvasFrame: CGRect?

    var appearanceAnimation: [Animation] = []
    var disappearanceAnimation: [Animation] = [.fadeOut]
    var durationAnimation: [Animation] = []

    var staggered:Bool = false
    var staggeredPeriod:TimeInterval = 1
    
    var quantity: NSInteger = 1
    var appearanceDuration: TimeInterval = 1
    var disappearanceDuration: TimeInterval = 1
    var duration: TimeInterval = 2
    var characters: [String] = []
    
    override init() {
        super.init()
    }
    
    class func manyFloatUp(_ characters:[String]) -> AnimationOptions {
        let option = AnimationOptions()
        option.characters = characters
        option.quantity = 50
        //option.startPoint = center
        //option.endPoint = CGPointZero
        option.appearanceDuration = 0
        option.disappearanceDuration = 0
        option.duration = 3
        option.characterSizeRange = (30,50)
        option.startRect = CGRect(x: 0, y: UIScreen.main.bounds.height + 30, width: UIScreen.main.bounds.width, height: 100)
        option.endRect = CGRect(x: -30, y: -100, width: UIScreen.main.bounds.width + 60, height: 10)
        option.staggered = true
        option.staggeredPeriod = 2
        
        return option
    }
    
    class func manyFloatDown(_ characters:[String]) -> AnimationOptions {
        let option = AnimationOptions()
        option.characters = characters
        option.quantity = 50
        //option.startPoint = center
        //option.endPoint = CGPointZero
        option.appearanceDuration = 0
        option.disappearanceDuration = 0
        option.duration = 3
        option.characterSizeRange = (30,50)
        option.startRect = CGRect(x: -30, y: -100, width: UIScreen.main.bounds.width + 60, height: 10)
        option.endRect = CGRect(x: 0, y: UIScreen.main.bounds.height + 30, width: UIScreen.main.bounds.width, height: 100)
        option.staggered = true
        option.staggeredPeriod = 2
        
        return option
    }
    
    class func oneFloatsDown(_ character:String, x:CGFloat) -> AnimationOptions {
        let option = AnimationOptions()
        option.characters = [character]
        option.quantity = 1
        option.startPoint = CGPoint(x: x, y: -30)
        option.endPoint = CGPoint(x: x, y: UIScreen.main.bounds.height + 30)
        option.appearanceDuration = 0
        option.disappearanceDuration = 0
        option.duration = 3
        option.characterSize = 40

        
        return option
    }
    
    class func oneMovesLeftToRight(_ character:String, y:CGFloat) -> AnimationOptions {
    
        let bounds = UIScreen.main.bounds
        
        let option = AnimationOptions()
        option.characters = [character]
        option.quantity = 1
        option.appearanceDuration = 0
        option.duration = 2
        option.characterSize =  60
        option.startPoint = CGPoint(x: bounds.width +  30, y: y)
        option.endPoint = CGPoint(x: -30, y: y)
        option.disappearanceDuration = 0
        
        return option
    }
    
    class func oneMovesRightToLeft(_ character:String, y:CGFloat) -> AnimationOptions {
        
        let bounds = UIScreen.main.bounds
        
        let option = AnimationOptions()
        option.characters = [character]
        option.quantity = 1
        option.appearanceDuration = 0
        option.duration = 2
        option.characterSize =  60
        option.startPoint = CGPoint(x: -30, y: y)
        option.endPoint = CGPoint(x: bounds.width +  30, y: y)
        option.disappearanceDuration = 0
        
        return option
    }
    
    class func oneAppearsCenter(_ character:String) -> AnimationOptions {
        
        let center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        
        let option = AnimationOptions()
        option.characters = [character]
        option.quantity = 1
        option.appearanceAnimation = [.grow]
        option.appearanceDuration = 1
        option.duration = 2
        option.characterSize =  100
        option.startPoint = center
        option.disappearanceDuration = 1
        option.disappearanceAnimation = [.fadeOut]
        
        return option
    }
    
    class func manyAppearRandomly(_ characters:[String]) -> AnimationOptions {
        let option = AnimationOptions()
        option.characters = characters
        option.quantity = 25
        option.appearanceAnimation = [.grow]
        option.appearanceDuration = 0.5
        option.duration = 2
        option.durationAnimation = [.wobble]
        option.characterSize = 50
        option.startRect = UIScreen.main.bounds
        option.disappearanceDuration = 0.5
        option.disappearanceAnimation = [.shrink]
        option.staggered = true
        option.staggeredPeriod = 1
        
        return option
    }
    
    class func row(_ characters:[String], center:CGPoint, templateOptions:AnimationOptions) -> [AnimationOptions]{
        
        
        let size = templateOptions.characterSize!
        let padding:CGFloat = size/10
        
        let x:CGFloat = center.x - CGFloat((padding+size) * CGFloat(characters.count/2)) + (padding+size)
        
        var options:[AnimationOptions] = []
        
        for i in 0..<characters.count {
            
            let emoji = characters[i]
            
            let option = AnimationOptions()
            option.characters = [emoji]
            option.quantity = 1
            option.appearanceAnimation = templateOptions.appearanceAnimation
            option.appearanceDuration = templateOptions.appearanceDuration
            option.duration = templateOptions.duration
            option.durationAnimation = templateOptions.durationAnimation
            option.characterSize =  templateOptions.characterSize
            option.disappearanceDuration = templateOptions.disappearanceDuration
            option.disappearanceAnimation = templateOptions.disappearanceAnimation
            option.staggeredPeriod = templateOptions.staggeredPeriod
            option.staggered = templateOptions.staggered
            
            option.startPoint = CGPoint(x: (x+(size+padding)*CGFloat(i)) - size/2,y: center.y)
            
            options.append(option)
        }
        
        return options
    }
    
    class func defaultAnimation(_ character:String) -> AnimationOptions {
        
        let center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        
        let option = AnimationOptions()
        option.characters = [character]
        option.quantity = 1
        option.appearanceAnimation = [.grow]
        option.appearanceDuration = 0.25
        option.duration = 0.75
        option.characterSize =  100
        option.startPoint = center
        option.disappearanceDuration = 0.35
        option.disappearanceAnimation = [.shrink]
        
        return option
    }


    
    

}
