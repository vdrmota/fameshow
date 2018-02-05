
//
//  AudienceViewController.swift
//  Live
//
//  Created by leo on 16/7/11.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SocketIO
import IHKeyboardAvoiding

struct Tick: Codable {
    let votes: Int?
    let viewers: Int?
}

class AudienceViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var room: Room!
    var socket: SocketIOClient!

    var player: IJKFFMoviePlayerController!
    //let socket = SocketIOClient(manager: URL(string: Config.serverUrl)!, nsp: [.log(true), .forcePolling(true)])
    
    let manager = SocketManager(socketURL: URL(string: Config.serverUrl)!, config:  [.log(true), .forcePolling(true)])
    //let socket = SocketManager(socketURL: URL(string: Config.serverUrl)!, config:  [.log(true), .forcePolling(true)]).defaultSocket
    /// let swiftSocket = manager.socket(forNamespace: "/swift")
    
    var overlayController: LiveOverlayViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = Config.rtmpPlayUrl + room.key
        player = IJKFFMoviePlayerController(contentURLString: urlString, with: IJKFFOptions.byDefault())  //contetURLStrint helps you making a complete stream at rooms with special characters.
        
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = previewView.bounds
        previewView.addSubview(player.view)
        

        player.prepareToPlay()
        
        socket.on("connect") {[weak self] data, ack in
            self?.joinRoom()
        }
        
        socket.on("new_room") {[weak self] data, ack in
            self?.player.shutdown()
            self?.player.view.removeFromSuperview()
            self?.player = nil
            if let key = data[0] as? String {
                 self?.room = Room(dict: [
                    "title": "upcoming" as AnyObject,
                    "key": key as AnyObject
                    ])
                let urlString = Config.rtmpPlayUrl + (self?.room.key)!
                self?.player = IJKFFMoviePlayerController(contentURLString: urlString, with: IJKFFOptions.byDefault())
                self?.player.prepareToPlay()
                self?.player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self?.player.view.frame = (self?.previewView.bounds)!
                self?.previewView.addSubview((self?.player.view)!)
                self?.joinRoom()
            }
        }
        
       socket.on("winner") {[weak self] data, ack in
        
            DispatchQueue.main.async {
                print("WINNER")
                let vc = R.storyboard.main.broadcast()!
                vc.isLive = true;
                vc.socket = self?.socket
                self?.present(vc, animated: true, completion: nil)
                
            }

        }
        
        socket.on("up_next") {[weak self] data, ack in
            DispatchQueue.main.async {
                print("upnext")
                let vc = R.storyboard.main.broadcast()!
                vc.isLive = false;
                vc.socket = self?.socket
                self?.present(vc, animated: true, completion: nil)
                
            }
            
        }
        
        socket.on("tick") {[weak self] data, ack in
            print("hello")
            
            if let viewers = data[0] as? Int, let votes = data[1] as? Int, let time = data[2] as? Int {
                self?.tick(viewers: viewers, timeRemaining: time, vote: Float(votes))
            }
            //print(data["votes"], data["viewers"])
            
//            self?.tick(viewers: json!["viewers"] as Int, timeRemaining: json["timeRemaining"] as Int, vote: json["vote"] as Float)
        }
        
    }
    
    func tick(viewers : Int, timeRemaining: Int, vote : Float) {
        print(viewers, timeRemaining, vote)
    }
    
    func joinRoom() {
        socket.emit("join_room", room.key)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "overlay" {
            overlayController = segue.destination as! LiveOverlayViewController
            overlayController.socket = manager.defaultSocket
            overlayController.room = room
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.play()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player, queue: OperationQueue.main, using: { [weak self] notification in
            
            guard let this = self else {
                return
            }
            let state = this.player.loadState
            switch state {
            case IJKMPMovieLoadState.playable:
                this.statusLabel.text = "Playable"
            case IJKMPMovieLoadState.playthroughOK:
                this.statusLabel.text = "Playing"
            case IJKMPMovieLoadState.stalled:
                this.statusLabel.text = "Buffering"
            default:
                this.statusLabel.text = "Playing"
            }
        })

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.shutdown()
        //manager.defaultSocket.disconnect()
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func beginBroadcast (){
        let vc = R.storyboard.main.broadcast()!
        vc.socket = self.socket
        present(vc, animated: true, completion: nil)
    }
}
