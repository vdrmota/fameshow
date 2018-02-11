//
//  BroadcasterViewController.swift
//  Live
//
//  Created by leo on 16/7/11.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SocketIO
import LFLiveKit
import IHKeyboardAvoiding
import SVProgressHUD

class BroadcasterViewController: UIViewController {
        
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var titleTextField: TextField!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var cameraFlipButton: UIButton!
    @IBOutlet weak var liveIndicator: RoundedButton!


    var isLive:Bool! {
        didSet {
            if (self.liveIndicator != nil) {
                if (isLive) {
                    self.liveIndicator.setTitle("LIVE", for: .normal)
                    self.liveIndicator.color = UIColor(red:0.84, green:0.19, blue:0.19, alpha:1.0)
                    let fadeAnimation = CABasicAnimation(keyPath:"opacity")
                    fadeAnimation.duration = 1
                    fadeAnimation.fromValue = 1
                    fadeAnimation.toValue = 0.75
                    fadeAnimation.autoreverses = true
                    fadeAnimation.repeatCount = .greatestFiniteMagnitude
                    self.liveIndicator.layer.add(fadeAnimation, forKey: "pulse")
                } else {
                    self.liveIndicator.setTitle("UP NEXT", for: .normal)
                    self.liveIndicator.color = UIColor(red:0.42, green:0.36, blue:0.91, alpha:1.0)
                }
            }
        }
    }
    var socket: SocketIOClient!

    let manager = SocketManager(socketURL:URL(string: Config.serverUrl)!, config: [.log(true), .forceWebsockets(true)])
    //var socket = manager.defaultSocket//SocketIOClient(manager: SocketManager(socketURL:URL(string: Config.serverUrl)!, config: [.log(true), .forceWebsockets(true)]), nsp: "/")//SocketIOClient(socketURL: URL(string: Config.serverUrl)!, config: [.log(true), .forceWebsockets(true)])

    
   // let socket = SocketIOClient(manager: URL(string: Config.serverUrl)! as! SocketManagerSpec, nsp: [.log(true), .forceWebsockets(true)])

    lazy var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: .medium3)
        
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)!
        session.delegate = self
        session.beautyFace = false
        
        
        session.captureDevicePosition = .front
        session.preView = self.previewView

        return session
    }()
    
    var room: Room!
    
    var overlayController: LiveOverlayViewController!
    var upNextOverlayController: UpNextOverlayViewController!

    override func viewDidLoad() {

        super.viewDidLoad()

        start()
					
        // trigger UI updates if isLive is set before view has loaded
        self.isLive = (isLive) ? true : false
        
        socket.on("is_live") {[weak self] data, ack in
            self?.isLive = true;
            self?.upNextOverlayController.dismiss()
        }
        
        socket.on("is_dead") {[weak self] data, ack in
            print("IS DEAD");
            DispatchQueue.main.async {

            self?.presentingViewController?.dismiss(animated: true, completion: nil)
            self?.isLive = false;

            }

        }

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.running = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.running = false
        stop()
       //socket.disconnect()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "overlay" {
            overlayController = segue.destination as! LiveOverlayViewController
            overlayController.socket = socket
									//overlayController.view.isUserInteractionEnabled = false
        }
            if segue.identifier == "upnext" {
            upNextOverlayController = segue.destination as! UpNextOverlayViewController
            upNextOverlayController.delegate = self
            //upNextOverlayController.socket = socket
        }
    }
	private func remove(asChildViewController viewController: UIViewController) {
		// Notify Child View Controller
		viewController.willMove(toParentViewController: nil)
		
		// Remove Child View From Superview
		viewController.view.removeFromSuperview()
		
		// Notify Child View Controller
		viewController.removeFromParentViewController()
	}
    
    func start() {
        room = Room(dict: [
            "title": "upcoming" as AnyObject,
            "key": String.random() as AnyObject
        ])
        
        overlayController.room = room
        
        let stream = LFLiveStreamInfo()
        stream.url = "\(Config.rtmpPushUrl)\(room.key)"
        session.startLive(stream)
        
        socket.emit("create_room", room.toDict())


//        socket.once("connect") {[weak self] data, ack in
//            guard let this = self else {
//                return
//            }
//            this.socket.emit("create_room", this.room.toDict())
//        }
        
//        infoLabel.text = "Room: \(room.key)"

        //IHKeyboardAvoiding.setAvoiding(overlayController.inputContainer)
    }
    
    func stop() {
        guard room != nil else {
            return
        }
        session.stopLive()
        manager.defaultSocket.emit("leave", room.key)
        //manager.defaultSocket.disconnect()
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
	
	@IBAction func flipCamera(_ sender: UIButton) {
        switch(self.session.captureDevicePosition){
            case .front: do {
                self.session.captureDevicePosition = .back
            }
            case .back: do {
                self.session.captureDevicePosition = .front
            }
            case .unspecified:
                break;
        }
	}
	

}

extension BroadcasterViewController: UpNextOverlayViewControllerDelegate {
    
    func wasDismissed(sender: UpNextOverlayViewController) {
        self.remove(asChildViewController: sender)
        self.containerView.removeFromSuperview()
    }
}

extension BroadcasterViewController: LFLiveSessionDelegate {
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        
        switch state {
        case .error:
            statusLabel.text = "error"
        case .pending:
            statusLabel.text = "pending"
        case .ready:
            statusLabel.text = "ready"
        case.start:
            statusLabel.text = "start"
        case.stop:
            statusLabel.text = "stop"
        case .refresh:
            statusLabel.text = "refresh"

        }
    }
    
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        //print("debugInfo: \(debugInfo)")

    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print("error: \(errorCode)")
        
    }
}

