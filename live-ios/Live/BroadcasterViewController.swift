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
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var titleTextField: TextField!
    @IBOutlet weak var inputTitleOverlay: UIVisualEffectView!
    @IBOutlet weak var inputContainer: UIView!

    
    var isLive:Bool!
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
            // Do any additional setup after loading the view, typically from a nib.
        //self.inputTitleOverlay.isHidden = true
        start()
					

        socket.on("is_live") {[weak self] data, ack in
            print("IS LIVE");
            self?.isLive = true;
            self?.infoLabel.text = "LIVE";
        }
        
        socket.on("is_dead") {[weak self] data, ack in
            print("IS DEAD");
            DispatchQueue.main.async {

            self?.presentingViewController?.dismiss(animated: true, completion: nil)
            self?.isLive = false;
            self?.infoLabel.text = "DEAD";

            }

        }

    }
    
    func tap (recognizer: UIGestureRecognizer){
        print("hi")
  
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.running = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.isLive) {
            infoLabel.text = "LIVE";
        } else {
            infoLabel.text = "UP NEXT";
            ///let controller = R.storyboard.main.up_next_overlay()!
            //self.present(controller, animated: true, completion: nil)
            
        }
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
        
        infoLabel.text = "Room: \(room.key)"

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
    
    @IBAction func startButtonPressed(_ sender: AnyObject) {
        titleTextField.resignFirstResponder()
        start()
        UIView.animate(withDuration: 0.2, animations: {
            self.inputTitleOverlay.alpha = 0
        }, completion: { finished in
            self.inputTitleOverlay.isHidden = true
        })
    }
        
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
	
	@IBAction func handleTapUI(_ gesture: UITapGestureRecognizer) {
		print("whwhhw")
		//textField.resignFirstResponder()
	}
	
	@objc func handleTap(_ gesture: UITapGestureRecognizer) {
	print("whwhhw")
		//textField.resignFirstResponder()
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

