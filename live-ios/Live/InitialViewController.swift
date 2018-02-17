//
//  InitialViewController.swift
//  Live
//
//  Created by Matt Schrage on 2/13/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit
import Cheers

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = App.theme.primaryColor

        let cheerView = CheerView()
        cheerView.alpha = 0.25
        cheerView.frame = self.view.bounds
        self.view.insertSubview(cheerView, at: 0)
        //self.view.addSubview(cheerView)
        //self.view.insertSubview(cheerView, at: 1)
        
        // Configure
        cheerView.config.particle = .confetti(allowedShapes: Particle.ConfettiShape.all)
        cheerView.config.customize = { cells in
            cells.forEach({ (cell) in
                cell.birthRate = 10
            })
        }
        
        //        let heart = NSAttributedString(string: "❤️", attributes: [
        //            NSAttributedStringKey.font: UIFont(name: "AppleColorEmoji", size: 10)!
        //            ])
        //        cheerView.config.particle = Particle.text(CGSize(width:40, height:40),[heart])
        cheerView.config.colors = [UIColor.white]
        cheerView.start()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func openTOS(){
        //UIApplication.shared.openURL(URL(string: "http://fameshow.co/tos")!)
        UIApplication.shared.open(URL(string: "http://fameshow.co/tos")!, options: [:], completionHandler: nil)
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
