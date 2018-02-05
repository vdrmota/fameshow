
//
//  MastHeadViewController.swift
//  Live
//
//  Created by Matt Schrage on 2/3/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit
import SVProgressHUD
import SocketIO

class MastHeadViewController: UIViewController {
    var rooms: [Room] = []
    let manager = SocketManager(socketURL:URL(string: Config.serverUrl)!, config: [.log(true), .forceWebsockets(true)])


    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.defaultSocket.once(clientEvent: .connect) { [weak self] data, ack in
            guard let this = self else {
                return
            }
            
            this.manager.defaultSocket.emit("register_user", "this_should_be_user_id")
            
        }
        
        manager.defaultSocket.connect()

        let tap = UITapGestureRecognizer(target: self, action: #selector(MastHeadViewController.refresh))
        view.addGestureRecognizer(tap)
        
        _ = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) {
            (_) in
            
            if (self.rooms.count == 0) {
                self.refresh()
            }
        }
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
        vc.socket = manager.defaultSocket
        present(vc, animated: true, completion: nil)
    }
    
    func joinRoom(_ room: Room) {
        let vc = R.storyboard.main.audience()!
        vc.room = room
        vc.socket = manager.defaultSocket
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
