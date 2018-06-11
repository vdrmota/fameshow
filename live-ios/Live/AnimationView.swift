//
//  File.swift
//  Bubblechat
//
//  Created by Matt Schrage on 3/19/16.
//  Copyright © 2016 Matt Schrage. All rights reserved.
//

import UIKit

class AnimationView: UIView, AnimationCanvasDelegate {
    var canvas:AnimationCanvas = AnimationCanvas()
    var animations:[[AnimationOptions]]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        canvas.delegate = self
        canvas.frame = self.bounds
        self.addSubview(canvas)
        
        let backgroundView = UIView()
        backgroundView.frame = self.bounds
        backgroundView.backgroundColor = UIColor.clear
        self.canvas.backgroundView = backgroundView

    }
    
    convenience init(){
            self.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func animateQueueWithIndex(_ index:Int, completion:(() -> Void?)?){
        
        self.animateWith(self.animations![index]) { () -> Void? in
            
            if (self.canvas.loopAnimationOnCompletion) {
                let id = (self.animations!.count == index + 1) ? 0 : index + 1
                self.animateQueueWithIndex(id, completion: completion)
            } else {
                
                
                if (self.animations!.count > index + 1) {
                    let id = index + 1
                    self.animateQueueWithIndex(id, completion: completion)
                } else {
                    self.animationCanvasShouldBeRemovedFromView(self.canvas)
                    completion!()
                }
            }

            return nil
        }
        
        
    }
    
    func animateWith(_ options:[AnimationOptions], completion:(() -> Void?)?){
        
        if let cf = options.first?.canvasFrame{
            self.canvas.frame = cf
        } else {
            self.canvas.frame = self.bounds
        }
        
        self.canvas.completion = completion
        
        for option in options {
            
            for _ in 0 ..< option.quantity {
                
                var size:CGFloat
                
                if let characterSize =  option.characterSize{
                    size = characterSize
                } else {
                    size =  CGFloat(self.randomInRange(Int(option.characterSizeRange.0), hi: Int(option.characterSizeRange.1)))
                }
                
                let emojiView = Emoji(character: option.characters[Int(arc4random_uniform(UInt32(option.characters.count)))], frame: CGRect(x: 0, y: 0, width: size,height: size))
                
                UIGraphicsBeginImageContextWithOptions(emojiView.bounds.size, false, UIScreen.main.scale);
                emojiView.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
                UIGraphicsEndImageContext();
                
                let emoji = UIImageView(image: image)
                
                if let startPoint = option.startPoint {
                    emoji.center = startPoint
                } else {
                    let x = self.randomInRange(Int(option.startRect!.minX), hi: Int(option.startRect!.maxX))
                    let y = self.randomInRange(Int(option.startRect!.minY), hi: Int(option.startRect!.maxY))
                    
                    emoji.center  = CGPoint(x: CGFloat(x),y: CGFloat(y))
                }
                
                
                //probabaly should just screenshot emoji and use image for animations
                self.canvas.addSubview(emoji)
                //also remember to create canvas later and ad to that instead of the view
                
                
                let delay:TimeInterval = (option.staggered) ? Double(Float(arc4random())/Float(UINT32_MAX)) + TimeInterval(arc4random_uniform(UInt32(option.staggeredPeriod))) : 0
                
                if option.appearanceAnimation.contains(.fadeIn){
                    emoji.alpha = 0
                }
                
                if option.appearanceAnimation.contains(.grow) {
                    emoji.transform = CGAffineTransform(scaleX: 0, y: 0)
                }
                
                if option.appearanceAnimation.contains(.shrink) {
                    emoji.transform = CGAffineTransform(scaleX: 5, y: 5)
                }
                
                if option.appearanceAnimation.contains(.hidden) {
                    emoji.isHidden = true;
                }
                
                //Appearance
                UIView.animate(withDuration: option.appearanceDuration, delay: delay, options: .beginFromCurrentState, animations: { () -> Void in
                    
                    if option.appearanceAnimation.contains(.fadeIn){
                        emoji.alpha = 1
                    }
                    
                    if option.appearanceAnimation.contains(.grow) {
                        emoji.transform = CGAffineTransform.identity
                    }
                    
                    if option.appearanceAnimation.contains(.shrink) {
                        emoji.transform = CGAffineTransform.identity
                    }
                    
                    if option.appearanceAnimation.contains(.hidden) {
                        emoji.center = CGPoint(x: emoji.center.x, y: emoji.center.y + 0.1); // Ensures that the duration occurs
                    }
                    
                    }, completion: { (Bool) -> Void in
                        
                        if option.appearanceAnimation.contains(.hidden) {
                            emoji.isHidden = false;
                        }
                        
                    })
                
                
                //Movement
                UIView.animate(withDuration: option.duration, delay: delay + option.appearanceDuration, options: .beginFromCurrentState, animations: { () -> Void in
                    
                    if let endPoint = option.endPoint {
                        emoji.center = endPoint
                    } else if let endRect = option.endRect{
                        let x = self.randomInRange(Int(endRect.minX), hi: Int(endRect.maxX))
                        let y = self.randomInRange(Int(endRect.minY), hi: Int(endRect.midY))
                        
                        emoji.center  = CGPoint(x: CGFloat(x),y: CGFloat(y))
                    } else {
                        //Ensure animation occurs
                        emoji.center  = CGPoint(x: emoji.center.x,y: emoji.center.y+0.1)
                    }
                    
                    }, completion: nil)
                
                //Duration
                if option.durationAnimation.contains(.spin){
                    let animate = CABasicAnimation(keyPath: "transform.rotation")
                    animate.duration = 1
                    animate.repeatCount = Float.infinity
                    animate.fromValue = 0.0
                    animate.toValue = Float(M_PI * 2.0)
                    emoji.layer.add(animate, forKey: "Spin")
                }
                
                if option.durationAnimation.contains(.wobble){
                    let animate = CABasicAnimation(keyPath: "transform.rotation")
                    animate.duration = 0.5
                    animate.autoreverses = true
                    animate.repeatCount = Float.infinity
                    animate.fromValue = CGFloat(-0.2)
                    animate.toValue = CGFloat(0.2)
                    emoji.layer.add(animate, forKey: "Wobble")
                }
                
                //TODO: Pulse
                if option.durationAnimation.contains(.pulse){
                    let animate = CABasicAnimation(keyPath: "transform.scale")
                    animate.duration = 0.75
                    animate.fromValue = 1
                    animate.toValue = 1.25
                    animate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    animate.autoreverses = true
                    animate.repeatCount = Float.infinity
                    emoji.layer.add(animate, forKey: "Pulse")
                }
                
                if option.durationAnimation.contains(.vertical){
                    let animate = CABasicAnimation(keyPath: "position.y")
                    animate.duration = 0.5
                    animate.fromValue = emoji.layer.position.y
                    animate.toValue = emoji.layer.position.y + emoji.frame.height/10
                    animate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    animate.autoreverses = true
                    animate.repeatCount = Float.infinity
                    emoji.layer.add(animate, forKey: "Vertical")
                }
                
                if option.durationAnimation.contains(.horizontal){
                    let animate = CABasicAnimation(keyPath: "position.x")
                    animate.duration = 0.5
                    animate.fromValue = emoji.layer.position.x
                    animate.toValue = emoji.layer.position.x + emoji.frame.width/10
                    animate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    animate.autoreverses = true
                    animate.repeatCount = Float.infinity
                    emoji.layer.add(animate, forKey: "Vertical")
                }
                
                //Disappearance
                UIView.animate(withDuration: option.disappearanceDuration, delay: delay + option.appearanceDuration + option.duration, options: .beginFromCurrentState, animations: { () -> Void in
                    
                    if option.disappearanceAnimation.contains(.fadeOut){
                        emoji.alpha = 0
                    }
                    
                    if option.disappearanceAnimation.contains(.shrink) {
                        emoji.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }
                    
                    if option.disappearanceAnimation.contains(.grow) {
                        emoji.transform = CGAffineTransform(scaleX: 5, y: 5)
                    }
                    
                    if option.appearanceAnimation.contains(.hidden) {
                        emoji.center = CGPoint(x: emoji.center.x, y: emoji.center.y + 0.1); // Ensures that the duration occurs
                    }
                    
                    }, completion: { (Bool) -> Void in
                        emoji.removeFromSuperview()
                })
                
                
            }
            
        }
    
    }
    
    func animateWithOptions(_ options:[AnimationOptions], blurStyle:UIBlurEffectStyle?, completion:(() -> Void?)?){
        var blurStyle = blurStyle
        
        if blurStyle == nil {
            blurStyle = .light
        }
        
        let blurEffect = UIBlurEffect(style: blurStyle!)
        let backgroundView = UIVisualEffectView(effect: blurEffect)
        backgroundView.frame = self.bounds
        backgroundView.alpha = 0.0
        self.canvas.backgroundView = backgroundView
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.canvas.backgroundView!.alpha = 0.6;
        })
        
        self.animateWith(options, completion: completion)
        
    }
    
    func animationCanvasShouldBeRemovedFromView(_ canvas: AnimationCanvas) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            canvas.alpha = 0;
            }, completion: { (Bool) -> Void in
                
//                if let completion =  canvas.completion{
//                    completion()
//                }
                //canvas.removeFromSuperview()
                self.removeFromSuperview()
        }) 
    }
    
    func randomInRange(_ lo: Int, hi : Int) -> Int {
        return lo + Int(arc4random_uniform(UInt32(hi - lo + 1)))
    }

}
