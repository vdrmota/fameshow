//
//  AnimationCanvas.swift
//  Bubblechat
//
//  Created by Matt Schrage on 2/18/16.
//  Copyright © 2016 Matt Schrage. All rights reserved.
//

import UIKit

protocol AnimationCanvasDelegate {
    func animationCanvasShouldBeRemovedFromView(_ canvas:AnimationCanvas)

}

class AnimationCanvas : UIView {
    var delegate:AnimationCanvasDelegate?
    var completion:(() -> Void?)?
    var backgroundView:UIView? {
        didSet{
            if self.subviews.count > 0 {
                self.subviews[0].removeFromSuperview()
                self.insertSubview(self.backgroundView!, at: 0)
            } else {
                self.addSubview(self.backgroundView!)
            }
        }
    }
    var tappingEndsAnimation:Bool = true
    var removeFromSuperViewOnCompletion:Bool = true
    var loopAnimationOnCompletion:Bool = true
    
     init() {
        super.init(frame: CGRect.zero)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(AnimationCanvas.tapped))
        self.addGestureRecognizer(gesture)
        
        self.clipsToBounds = true
    }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if  self.removeFromSuperViewOnCompletion && self.subviews.count == 1 && self.subviews.contains(self.backgroundView!) {
            //we want to remove the view AND the animation is complete
            delegate?.animationCanvasShouldBeRemovedFromView(self)
        }
        
        if (self.subviews.count == 1 && self.subviews.contains(self.backgroundView!) ){
            if let completion =  self.completion{
                completion()
            }
        }
    }
    
    @objc func tapped(){
        if self.tappingEndsAnimation{
            delegate?.animationCanvasShouldBeRemovedFromView(self)
        }
    }
}
