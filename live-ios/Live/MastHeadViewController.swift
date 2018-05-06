
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
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        view.backgroundColor = App.theme.primaryColor
        manager.defaultSocket.on(clientEvent: .connect) { [weak self] data, ack in
            guard let this = self else {
                return
            }
            this.manager.defaultSocket.emit("register_user", User.currentUser.username!, version)
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
        
        cheerView.config.colors = [UIColor.white]
        
        if let balance = User.currentUser.balance {
            self.usernameLabel.text = User.currentUser.username! + " | $" + balance

        } else {
            self.usernameLabel.text = User.currentUser.username! + " | $-"
        }
        
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
            if let key = data[0] as? String, let version = data[1] as? String {
                let room = Room(dict: [
                    "title": "upcoming" as AnyObject,
                    "key": key as AnyObject,
                    "version" : version as AnyObject
                    ])
                self?.joinRoom(room)
            }
        }
    }
    
    func fetchUserBalance() {
        App.post("/balance.php", parameters: ["username" : User.currentUser.username!]) { (res) in
            User.currentUser.balance = res
            self.usernameLabel.text = User.currentUser.username! + " | $" + User.currentUser.balance!
        }
    }
    
    func fetchShowDetails() {
        SVProgressHUD.show()
        
        self.descriptionLabel.alpha = 0
        self.nextShowLabel.alpha    = 0
        self.prizeLabel.alpha       = 0
        
        App.get("/next-show.php") { (res) in
            SVProgressHUD.dismiss()
            
            UIView.animate(withDuration: 0.5, animations: {
                self.descriptionLabel.alpha = 1
                self.nextShowLabel.alpha    = 1
                self.prizeLabel.alpha       = 1
            })
            
            let array = res.components(separatedBy: ",")
            if array.count != 3 {
                
                self.descriptionLabel.text = ""
                self.nextShowLabel.text    = ""
                self.prizeLabel.text       = "Looks like something went wrong..."
                
                return
            }
            
            self.descriptionLabel.text = array[0]
            self.nextShowLabel.text    = array[1]
            self.prizeLabel.text       = array[2]
            SVProgressHUD.dismiss()
            
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cheerView.start()

        refresh()
        fetchUserBalance()
        fetchShowDetails()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.exitedApp),
            name: Notification.Name.UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.enteredApp),
            name: Notification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)

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
    
    @IBAction func contact() {
        UIApplication.shared.open(URL(string:"mailto:contact@fameshow.co")!, options: [:]) { (completed) in
            
        }
        //UIApplication.shared.openURL(URL(string:"mailto:contact@fameshow.co")!)
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
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

        if (room.version == version) {
            let vc = R.storyboard.main.audience()!
            vc.room = room
            vc.socket = manager.defaultSocket
            present(vc, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "You're running an old version of Fameshow", message: "Please update the app in order to watch the show.", preferredStyle: .alert)
            
            let gotToAppStore = UIAlertAction(title: "Go to App Store", style: .default) { (action:UIAlertAction) in
                UIApplication.shared.openURL(NSURL(string: "itms://itunes.apple.com/us/app/fameshow/id1350328096?mt=8")! as URL)
            }
            
            let cancel = UIAlertAction(title: "Not now", style: .default) { (action:UIAlertAction) in
                print("You've pressed cancel");
            }

            
            alertController.addAction(gotToAppStore)
            alertController.addAction(cancel)

            self.present(alertController, animated: true, completion: nil);

        }
        
        //UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/de/app/x-gift/id839686104?mt=8&uo=4")!)

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
    
    @objc func exitedApp () {
        manager.defaultSocket.emit("leave")
    }
    
    @objc func enteredApp () {
        manager.defaultSocket.emit("reconnect")
    }

}
