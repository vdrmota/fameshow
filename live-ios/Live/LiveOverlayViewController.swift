//
//  LiveOverlayViewController.swift
//  Live
//
//  Created by leo on 16/7/12.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SocketIO
import IHKeyboardAvoiding
import Whisper
import Cheers

enum UnderlayState {
    case broadcasting, pending, viewing
}

class LiveOverlayViewController: UIViewController {
    
    @IBOutlet weak var emitterView: WaveEmitterView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var giftArea: GiftDisplayArea!
    //@IBOutlet weak var viewerLabel: UILabel!
    
    @IBOutlet weak var viewerLabel: UIButton!
    //@IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var counter: CounterView!
//    @IBOutlet weak var audienceSwitch: UISwitch!
//    @IBOutlet weak var cameraFlipButton: UIButton!


    var comments: [Comment] = []
    var room: Room!
    var cheerView: CheerView =  CheerView()

    var socket: SocketIOClient!
    
    var state: UnderlayState = .viewing
//        didSet {
//            switch state {
//                case .broadcasting: do {
//                    self.subscribeButton.isHidden  = true
//                    self.audienceSwitch.isHidden   = true
//                    self.cameraFlipButton.isHidden = false
//                }
//                case .pending: do {
//                    self.subscribeButton.isHidden  = true
//                    self.audienceSwitch.isHidden   = true
//                    self.cameraFlipButton.isHidden = false
//                }
//                case .viewing: do {
//                    self.subscribeButton.isHidden  = false
//                    self.audienceSwitch.isHidden   = false
//                    self.cameraFlipButton.isHidden = true
//
//                }
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //KeyboardAvoiding.avoidingView = self.inputContainer

        textField.delegate = self
//
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.estimatedRowHeight = 20
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false;
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LiveOverlayViewController.tick(_:)), userInfo: nil, repeats: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LiveOverlayViewController.handleTap(_:)))
        view.addGestureRecognizer(tap)
        //KeyboardAvoiding.avoidingView = self.inputContainer
        KeyboardAvoiding.padding = 10

        textField.tintColor = App.theme.primaryColor
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.layer.masksToBounds = true
        
        cheerView.frame = self.view.bounds
        cheerView.config.colors = [UIColor.white]

        //self.view.addSubview(cheerView)
        self.view.insertSubview(cheerView, at: 1)
        
        // Configure
 
        
        socket.on("confetti") { data, ack in
            if let icon = data[0] as? String {
                DispatchQueue.main.async {
                    
                    let confetti = NSAttributedString(string: icon, attributes: [
                        NSAttributedStringKey.font: UIFont(name: "AppleColorEmoji", size: 30)!
                        ])
                    self.cheerView.config.particle = Particle.text(CGSize(width:100, height:100),[confetti])
                    // Start
                    self.cheerView.start()
                    
                    let when = DispatchTime.now() + 3.5 // change 2 to desired number of seconds
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        // Your code with delay
                        self.cheerView.stop()
                        
                    }
                }
            }
        }
        
        socket.on("message") { data, ack in
            if let message = data[0] as? String {
                let murmur = Murmur(title: message, backgroundColor: UIColor.colorWithRGB(red: 0, green: 0, blue: 0, alpha: 0.4), titleColor: UIColor.white, font: UIFont(name: "Avenir", size: 13)!)
                
                // Show and hide a message after delay
                Whisper.show(whistle: murmur, action: .show(5))
            }
        }
        
        socket.on("tick") {[weak self] data ,ack in
            if let viewers  = data[0] as? Int,
               let votes    = data[1] as? Int,
               let time     = data[2] as? Int,
               let progress = data[3] as? Double,
               let counterVisible = data[4] as? Bool {
                self?.viewerLabel.setTitle(String(viewers), for: .normal)
                
                self?.counter.voteProgress = Double(progress)
                self?.counter.timeRemaining = time
                self?.counter.isHidden = !counterVisible
                self?.counter.setNeedsDisplay()

            }
            
        }

        socket.on("upvote") {[weak self] data ,ack in
            self?.emitterView.emitImage(R.image.heart()!)
        }
        
        socket.on("comment") {[weak self] data ,ack in
            var comment = Comment(dict: data[0] as! [String: AnyObject])
            comment.user = data[1] as! String
            self?.comments.append(comment)
            self?.tableView.reloadData()
        }
        
        socket.on("gift") {[weak self] data ,ack in
            let event = GiftEvent(dict: data[0] as! [String: AnyObject])
           // self?.giftArea.pushGiftEvent(event)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset.top = tableView.bounds.height
        tableView.reloadData()
        KeyboardAvoiding.avoidingView = self.inputContainer

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //KeyboardAvoiding.avoidingView = self.inputContainer

    }

    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        textField.resignFirstResponder()
    }
    
    @objc func tick(_ timer: Timer) {
        guard comments.count > 0 else {
            return
        }
        if tableView.contentSize.height > tableView.bounds.height {
            tableView.contentInset.top = 0
        }
        tableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
    }

    @IBAction func giftButtonPressed(_ sender: AnyObject) {
        let vc = R.storyboard.main.giftChooser()!
        vc.socket = socket
        vc.room = room
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func upvoteButtonPressed(_ sender: AnyObject) {
        socket.emit("upvote", room.key)
    }
    
    @IBAction func subscribeButtonPressed(_ sender: AnyObject) {
        socket.emit("subscribe", room.key)
    }
}

extension LiveOverlayViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            if let text = textField.text , text != "" {
                socket.emit("comment", [
                    "roomKey": room.key,
                    "text": text,
                ])
            }
            textField.text = ""
            return false
        }
        return true
    }
}

extension LiveOverlayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        cell.comment = comments[(indexPath as NSIndexPath).row]
        return cell
    }
    
}


class TableView : UITableView {
    
    let fadePercentage: Double = 0.2
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let transparent = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor
        
        let maskLayer = CALayer()
        maskLayer.frame = self.bounds
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        gradientLayer.colors = [transparent, opaque]//,opaque,transparent]
        gradientLayer.locations = [0, NSNumber(floatLiteral: fadePercentage)]//,  NSNumber(floatLiteral: 1 - fadePercentage), 1]
        
        maskLayer.addSublayer(gradientLayer)
        self.layer.mask = maskLayer
        
    }
}

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var commentContainer: UIView!
    
    var comment: Comment! {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //commentContainer.layer.cornerRadius = 3
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    func updateUI() {
        let font = [ NSAttributedStringKey.font: UIFont(name: "Avenir", size: 15.0)!, NSAttributedStringKey.foregroundColor : UIColor.white ]
        let string = NSMutableAttributedString(string: comment.user + " " + comment.text, attributes: font )
        string.addAttribute(NSAttributedStringKey.foregroundColor, value: App.theme.secondaryColor, range: NSRange(location: 0, length: comment.user.count) )
        titleLabel.attributedText = string
        //titleLabel.text = comment.user + ": " + comment.text
        titleLabel.layer.shadowOpacity = 0.8;
        titleLabel.layer.shadowRadius = 5;
        titleLabel.layer.shadowColor = UIColor.black.cgColor;
        titleLabel.layer.shadowOffset = CGSize(width:0.0,height: 1.0);
        //titleLabel.attributedText = comment.text.attributedComment()
    }
    
}
