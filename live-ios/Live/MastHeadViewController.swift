
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
import Cheers

class MastHeadViewController: UIViewController {
    var rooms: [Room] = []
    let manager = SocketManager(socketURL:URL(string: Config.serverUrl)!, config: [.log(true), .forceWebsockets(true)])
    let cheerView = CheerView()
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nextShowLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = App.theme.primaryColor
        manager.defaultSocket.once(clientEvent: .connect) { [weak self] data, ack in
            guard let this = self else {
                return
            }
            connectedSpeed().testDownloadSpeedWithTimout(timeout: 5.0) { (megabytesPerSecond, error) -> () in
                print("mbps:\(String(describing: megabytesPerSecond))")
                this.manager.defaultSocket.emit("register_user", User.currentUser.username!, megabytesPerSecond!,"welcometothefameshow")

            }
            
        }
        
        
        cheerView.alpha = 0.25
        cheerView.frame = self.view.bounds
        //self.view.addSubview(cheerView)
        self.view.insertSubview(cheerView, at: 0)
        
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
        // Start
        
        self.usernameLabel.text = User.currentUser.username! + " | $0"
        
        manager.defaultSocket.connect()

        let tap = UITapGestureRecognizer(target: self, action: #selector(MastHeadViewController.refresh))
        view.addGestureRecognizer(tap)
        
        _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) {
            (_) in
            
            if (self.rooms.count == 0 && self.viewIfLoaded?.window != nil) {
                self.refresh()
            }
        }
        
         manager.defaultSocket.on("start_show") {[weak self] data, ack in
            if let key = data[0] as? String {
                let room = Room(dict: [
                    "title": "upcoming" as AnyObject,
                    "key": key as AnyObject
                    ])
                self?.joinRoom(room)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cheerView.start()

        refresh()
        
        let url = URL(string: "http://cs50.vojtadrmota.com/fame/next-show.php")
        SVProgressHUD.show()
        
        
        
        self.descriptionLabel.alpha = 0
        self.nextShowLabel.alpha    = 0
        self.prizeLabel.alpha       = 0
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            let csv = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            let array = csv.components(separatedBy: ",")
            
            if array.count != 3 {
                
                DispatchQueue.main.async {
                    self.descriptionLabel.text = ""
                    self.nextShowLabel.text    = ""
                    self.prizeLabel.text       = "Looks like something went wrong..."
                    SVProgressHUD.dismiss()
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.descriptionLabel.alpha = 1
                        self.nextShowLabel.alpha    = 1
                        self.prizeLabel.alpha       = 1
                    })
                }
                
                return
            }
            
            DispatchQueue.main.async {
                self.descriptionLabel.text = array[0]
                self.nextShowLabel.text    = array[1]
                self.prizeLabel.text       = array[2]
                SVProgressHUD.dismiss()
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.descriptionLabel.alpha = 1
                    self.nextShowLabel.alpha    = 1
                    self.prizeLabel.alpha       = 1
                })
            }
        }
        
        task.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cheerView.stop()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        // this is temporary 
        exit(0);
    }
    
    @objc func refresh() {
        //SVProgressHUD.show()
        let request = URLRequest(url: URL(string: "\(Config.serverUrl)/rooms")!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { resp, data, err in
            guard err == nil else {
                //SVProgressHUD.showError(withStatus: "Error")
                return
            }
            //SVProgressHUD.dismiss()
            let rooms = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [[String: AnyObject]]
            self.rooms = rooms.map {
                Room(dict: $0)
            }
            
            if (rooms.count > 0) {
                self.joinRoom(self.rooms[0])
            } else {
                //SVProgressHUD.showError(withStatus: "No live stream could be joined")
                // set status text or something
            }
        })
    }
    
    @IBAction func createRoom() {
//        let vc = R.storyboard.main.broadcast()!
//        vc.socket = manager.defaultSocket
//        present(vc, animated: true, completion: nil)
        let room = Room(dict: [
            "title": "upcoming" as AnyObject,
            "key": String.random() as AnyObject
            ])
        
        let vc = R.storyboard.main.audience()!
        vc.socket = manager.defaultSocket
        vc.room = room
        present(vc, animated: true, completion: nil)
        vc.beginBroadcast()
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
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}
