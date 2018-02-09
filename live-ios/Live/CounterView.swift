//
//  CounterView.swift
//  Live
//
//  Created by Matt Schrage on 2/9/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit

private enum Radians {
    static let zero        = CGFloat(0)
    static let two_pi      = CGFloat(Double.pi*2)
    static let pi_over_two = CGFloat(Double.pi/2.0)
}

private enum State {
    case warning, normal, full
}

class CounterView: UIView {
    
    var label:UILabel!       = UILabel()
    var timeRemaining:Int!   = 15 {
        didSet {
            if (self.state != .full) {
                if (timeRemaining <= 5) {
                    self.state = .warning;
                } else {
                    self.state = .normal
                }
            }
        }
    }
    var voteProgress:Double! = 0.0
    var color:UIColor!      = UIColor(red:0.42, green:0.36, blue:0.91, alpha:1.0)
    var warningColor:UIColor!   = UIColor(red:0.84, green:0.19, blue:0.19, alpha:1.0)
    var fullColor:UIColor!   = UIColor(red:0.84, green:0.19, blue:0.19, alpha:1.0)

    private var fillColor : CGColor {
        get {
            switch self.state {
            case .full:
                return self.fullColor.cgColor
            case .warning:
                return self.warningColor.cgColor
            case .normal:
                return self.color.cgColor
            }
        }
    }
    private var startAngle: CGFloat {
        get {
            return -Radians.pi_over_two
        }
    }
    private var   endAngle: CGFloat {
        get {
            return (CGFloat(self.voteProgress) * Radians.two_pi) - Radians.pi_over_two
        }
    }

    private var progressView:UIView!
    private var state = State.normal {
        didSet {
            if (self.state == .warning) {
                let pulseAnimation = CABasicAnimation(keyPath:"transform.scale")
                pulseAnimation.duration = 1
                pulseAnimation.fromValue = 0.9
                pulseAnimation.toValue = 1.1
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = .greatestFiniteMagnitude
                self.label.layer.add(pulseAnimation, forKey: "pulse")
            } else {
                self.label.layer.removeAllAnimations()
            }
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label.frame = frame
        self.label.backgroundColor = UIColor.clear
        self.label.text = "15"
        self.label.font = UIFont(name: "Avenir", size: 40);
        self.label.textColor = UIColor.white
        self.label.textAlignment = NSTextAlignment.center
        self.label.shadowColor = UIColor.black;
        self.label.shadowOffset = CGSize(width:0.0, height:2.0)
        self.addSubview(self.label)
        
        progressView = UIView(frame:frame)
        self.addSubview(progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        
        self.label.frame = self.bounds
        self.label.backgroundColor = UIColor.clear
        self.label.text = "15"
        self.label.font = UIFont(name: "Avenir", size: 20);
        self.label.textColor = UIColor.white
        self.label.textAlignment = NSTextAlignment.center
        self.label.shadowColor = UIColor.black;
        self.label.shadowOffset = CGSize(width:0.0, height:2.0)
        self.addSubview(self.label)
        
        progressView = UIView(frame:self.bounds)
        self.addSubview(progressView)
        
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let radius = CGFloat((rect.size.height / 2) - 10)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let circle = UIBezierPath(arcCenter: center, radius: radius, startAngle: Radians.zero, endAngle:Radians.two_pi, clockwise: true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circle.cgPath
        circleLayer.strokeColor = UIColor(red:0.87, green:0.90, blue:0.91, alpha:1.0).cgColor
        circleLayer.lineWidth = 10.0
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = kCALineCapRound
        self.layer.addSublayer(circleLayer)
        
        let progress = UIBezierPath(arcCenter: center, radius: radius, startAngle: self.startAngle, endAngle:self.endAngle, clockwise: true)
        
        let progressLayer = CAShapeLayer()
        progressLayer.path = progress.cgPath
        
        progressLayer.strokeColor = self.fillColor
        progressLayer.lineWidth = 10.0
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = kCALineCapRound
        
        self.layer.addSublayer(progressLayer)
    }

}
