//
//  UpNextOverlayViewController.swift
//  Live
//
//  Created by Matt Schrage on 2/10/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit
import Cheers

protocol UpNextOverlayViewControllerDelegate: class {
    func wasDismissed(sender: UpNextOverlayViewController)
}

class UpNextOverlayViewController: UIViewController {
    weak var delegate:UpNextOverlayViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
							let tap = UITapGestureRecognizer(target: self, action: #selector(UpNextOverlayViewController.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
					
        let cheerView = CheerView()
        cheerView.frame = self.view.bounds
        //self.view.addSubview(cheerView)
        self.view.insertSubview(cheerView, at: 1)
        
        // Configure
        cheerView.config.particle = .confetti(allowedShapes: Particle.ConfettiShape.all)
        
//        let heart = NSAttributedString(string: "❤️", attributes: [
//            NSAttributedStringKey.font: UIFont(name: "AppleColorEmoji", size: 10)!
//            ])
//        cheerView.config.particle = Particle.text(CGSize(width:40, height:40),[heart])
        cheerView.config.colors = [UIColor.white]
        // Start
        cheerView.start()
					
					let when = DispatchTime.now() + 3.5 // change 2 to desired number of seconds
					DispatchQueue.main.asyncAfter(deadline: when) {
						// Your code with delay
						cheerView.stop()

					}
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func dismiss () {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
        }) { (completed) in
            //self.removeFromParentViewController()
            //self.view.removeFromSuperview()
            self.delegate?.wasDismissed(sender: self)

        }
    }
@objc func handleTap(_ gesture: UITapGestureRecognizer) {
//    UIView.animate(withDuration: 0.5, animations: {
//        self.view.alpha = 0
//    }) { (completed) in
//        self.removeFromParentViewController()
//        self.view.removeFromSuperview()
//    }
    
    self.dismiss()

		//textField.resignFirstResponder()
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
