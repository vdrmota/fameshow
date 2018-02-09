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
    
    let label:UILabel!       = UILabel()
    var timeRemaining:Int!   = 15 {
        didSet {
            self.label.text = String(timeRemaining+1)
            if (self.state != .full) {
                if (self.timeRemaining <= 5) {
                    self.state = .warning;
                } else {
                    self.state = .normal
                }
            }
        }
    }
    var voteProgress:Double! = 0.0 {
        didSet{
            if voteProgress >= 1.0 {
                self.state = .full
            } else {
                self.state = .normal
            }
        }
    }
    var color:UIColor!      = UIColor(red:0.42, green:0.36, blue:0.91, alpha:1.0)
    var warningColor:UIColor!   = UIColor(red:0.84, green:0.19, blue:0.19, alpha:1.0)
    var fullColor:UIColor!   = UIColor(red:0.33, green:0.94, blue:0.77, alpha:1.0)

    private var fillColor : UIColor {
        get {
            switch self.state {
            case .full:
                return self.fullColor
            case .warning:
                return self.warningColor
            case .normal:
                return self.color
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
    private let circleLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()


    private var progressView:UIView!
    private var state = State.normal {
        didSet {
            self.label.shadowColor = self.fillColor;
            self.label.layer.removeAllAnimations()
            self.progressView.layer.removeAllAnimations()
            switch self.state {
                case .warning: do {
                    let pulseAnimation = CABasicAnimation(keyPath:"transform.scale")
                    pulseAnimation.duration = 0.5
                    pulseAnimation.fromValue = 1.75
                    pulseAnimation.toValue = 1
                    pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    //pulseAnimation.autoreverses = true
                    pulseAnimation.repeatCount = 1
                    self.label.layer.add(pulseAnimation, forKey: "pulse")
                    
                    let circleAnimation = CABasicAnimation(keyPath:"transform.scale")
                    circleAnimation.duration = 0.1
                    circleAnimation.fromValue = 1
                    circleAnimation.toValue = 0.9
                    //circleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    circleAnimation.autoreverses = true
                    circleAnimation.repeatCount = .greatestFiniteMagnitude
                    progressView.layer.add(circleAnimation, forKey: "pulse")

                }
                case .normal: do {
                    let circleAnimation = CABasicAnimation(keyPath:"transform.scale")
                    circleAnimation.duration = 1
                    circleAnimation.fromValue = 1
                    circleAnimation.toValue = 0.9
                    //circleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    circleAnimation.autoreverses = true
                    circleAnimation.repeatCount = .greatestFiniteMagnitude
                    progressView.layer.add(circleAnimation, forKey: "pulse")
                }
                
                default:
                    break;
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
        self.label.shadowOffset = CGSize(width:0.0, height:1.0)
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
        self.label.shadowColor = self.color;
        self.label.shadowOffset = CGSize(width:0.0, height:1.0)
        self.addSubview(self.label)
        
        progressView = UIView(frame:self.bounds)
        self.addSubview(progressView)
        
        progressView.layer.addSublayer(circleLayer)
        progressView.layer.addSublayer(progressLayer)

        
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        //self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        //self.layer.sublayers = nil
        let radius = CGFloat((rect.size.height / 2) - 10)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let circle = UIBezierPath(arcCenter: center, radius: radius, startAngle: Radians.zero, endAngle:Radians.two_pi, clockwise: true)
        
        circleLayer.path = circle.cgPath
        circleLayer.strokeColor = UIColor(red:0.87, green:0.90, blue:0.91, alpha:0.25).cgColor
        circleLayer.lineWidth = 10.0
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = kCALineCapRound
        
        let progress = UIBezierPath(arcCenter: center, radius: radius, startAngle: self.startAngle, endAngle:self.endAngle, clockwise: true)
        
        progressLayer.path = progress.cgPath
        
        progressLayer.strokeColor = self.fillColor.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = kCALineCapRound
        
    }

}
