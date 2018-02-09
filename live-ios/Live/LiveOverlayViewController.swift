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

class LiveOverlayViewController: UIViewController {
    
    @IBOutlet weak var emitterView: WaveEmitterView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var giftArea: GiftDisplayArea!
    @IBOutlet weak var viewerLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var counter: CounterView!

    var comments: [Comment] = []
    var room: Room!
    
    var socket: SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        //textField.delegate = self
//
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.estimatedRowHeight = 30
//        tableView.rowHeight = UITableViewAutomaticDimension

        
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LiveOverlayViewController.tick(_:)), userInfo: nil, repeats: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LiveOverlayViewController.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        //IHKeyboardAvoiding.setAvoiding(inputContainer)
        
        socket.on("tick") {[weak self] data ,ack in
            print("hello ther")
            if let viewers = data[0] as? Int, let votes = data[1] as? Int, let time = data[2] as? Int, let progress = data[3] as? Float {
                self?.viewerLabel.text = String(viewers)
                
                self?.counter.voteProgress = Double(progress)
                self?.counter.timeRemaining = time
                self?.counter.setNeedsDisplay()

                
            }
            
        }

        socket.on("upvote") {[weak self] data ,ack in
            self?.emitterView.emitImage(R.image.heart()!)
        }
        
        socket.on("comment") {[weak self] data ,ack in
            let comment = Comment(dict: data[0] as! [String: AnyObject])
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
        //tableView.contentInset.top = tableView.bounds.height
        //tableView.reloadData()
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        //textField.resignFirstResponder()
    }
    
    @objc func tick(_ timer: Timer) {
//        guard comments.count > 0 else {
//            return
//        }
//        if tableView.contentSize.height > tableView.bounds.height {
//            tableView.contentInset.top = 0
//        }
//        tableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
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
                    "text": text
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
        commentContainer.layer.cornerRadius = 3
    }
    
    func updateUI() {
        titleLabel.attributedText = comment.text.attributedComment()
    }
    
}
