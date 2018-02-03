//
//  MastHeadViewController.swift
//  Live
//
//  Created by Matt Schrage on 2/3/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit
import SVProgressHUD

class MastHeadViewController: UIViewController {
    var rooms: [Room] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MastHeadViewController.refresh))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        SVProgressHUD.show()
        let request = URLRequest(url: URL(string: "\(Config.serverUrl)/rooms")!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { resp, data, err in
            guard err == nil else {
                SVProgressHUD.showError(withStatus: "Error")
                return
            }
            SVProgressHUD.dismiss()
            let rooms = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [[String: AnyObject]]
            self.rooms = rooms.map {
                Room(dict: $0)
            }
            
            if (rooms.count > 0) {
                self.joinRoom(self.rooms[0])
            } else {
                SVProgressHUD.showError(withStatus: "No live stream could be joined")
                // set status text or something
            }
        })
    }
    
    @IBAction func createRoom() {
        let vc = R.storyboard.main.broadcast()!
        present(vc, animated: true, completion: nil)
    }
    
    func joinRoom(_ room: Room) {
        let vc = R.storyboard.main.audience()!
        vc.room = room
        present(vc, animated: true, completion: nil)
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
