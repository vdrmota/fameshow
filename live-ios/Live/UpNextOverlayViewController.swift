//
//  UpNextOverlayViewController.swift
//  Live
//
//  Created by Matt Schrage on 2/10/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit
import Cheers

class UpNextOverlayViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UpNextOverlayViewController.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        let cheerView = CheerView()
        cheerView.frame = self.view.bounds
        self.view.addSubview(cheerView)
        
        // Configure
        cheerView.config.particle = .confetti(allowedShapes: Particle.ConfettiShape.all)
        
        let heart = NSAttributedString(string: "❤️", attributes: [
            NSAttributedStringKey.font: UIFont(name: "AppleColorEmoji", size: 10)!
            ])
        cheerView.config.particle = Particle.text(CGSize(width:40, height:40),[heart])
        cheerView.config.colors = [UIColor.white]
        // Start
        cheerView.start()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            print("dismissed")
        });
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
