//
//  TextEntryViewController.swift
//  Live
//
//  Created by Matt Schrage on 2/13/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit

class TextEntryViewController: UIViewController {
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var confirmTextfield: UITextField!
    @IBOutlet weak var errorTextLabel: UILabel!

    var nextButton: RoundedButton!
    
    private let baseURL = "http://cs50.vojtadrmota.com/fame"
    enum EntryType: String {
        case email    = "email"
        case username = "username"
        case password = "password"
        case login    = "login"

        var verificationEndpoint: String {
            switch self {
            case .email:
                return "/email.php"
                
            case .username:
                return "/username.php"
                
            default:
                return "/"
            }
        }
    }
    
    var type: EntryType = .email;
    @IBInspectable var nextViewControllerID: String = ""
    
    var user : User = User()
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'type' instead.")
    @IBInspectable var typeName: String? {
        willSet {
            // Ensure user enters a valid shape while making it lowercase.
            // Ignore input if not valid.
            if let newType = EntryType(rawValue: newValue?.lowercased() ?? "") {
                type = newType
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = App.theme.primaryColor

//        NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) { notification in
//            print("\(notification.name): \(notification.userInfo ?? [:])")
//        }
        let container = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height:100));

        self.nextButton = RoundedButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8, height: 44))
        self.nextButton.center = CGPoint(x: self.view.bounds.midX, y: container.bounds.midY)
        self.nextButton.addTarget(self, action: #selector(TextEntryViewController.nextPage), for: .touchUpInside)
        self.nextButton.color = App.theme.secondaryColor
        self.nextButton.cornerRadius = 25
        if (self.type == .login) {
            self.nextButton.setTitle("Log in", for: .normal)
        } else {
            self.nextButton.setTitle("Next", for: .normal)
        }
        
        container.addSubview(self.nextButton)
        
        self.textfield.inputAccessoryView = container
        if ((self.confirmTextfield) != nil) {
            self.confirmTextfield.inputAccessoryView = container
        }
        
        self.errorTextLabel.text      = ""
        self.errorTextLabel.font      = UIFont(name: "Avenir", size: 14)
        self.errorTextLabel.textColor = UIColor.white//UIColor(red:0.84, green:0.19, blue:0.19, alpha:1.0)
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textfield?.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func validate(data: String) -> Bool {
        return (data.count > 0)
    }
    @objc func nextPage() {
        
        if (self.type == .login){
            
            if (!self.validate(data: self.textfield.text!)) {
                signalValidationError("Please enter your username.")
                return
            }
            
            if (!self.validate(data: self.confirmTextfield.text!)) {
                signalValidationError("Please enter your password.")
                return
            }
            
            login(self.textfield.text!, self.confirmTextfield.text!)
            return
        }
        
        //determine endpoint
        // post to server
        
        if (!self.validate(data: self.textfield.text!)) {
            signalValidationError("You have to type something!")
            return
        }
        
        if (self.type == .password && (self.confirmTextfield != nil) && self.confirmTextfield.text! != self.textfield.text!) {
            signalValidationError("These passwords don't match!")
            return
        }
        
        if self.nextViewControllerID == "" {
            self.createUser()
        } else {
            let url = URL(string: self.baseURL + self.type.verificationEndpoint)!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let postString = "\(self.type.rawValue)=\(self.textfield.text!)"
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    // check for fundamental networking error
                    print("error=\(error!)")
                    return
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString!)")
                
                if responseString == "success" {
                    DispatchQueue.main.async {
                        let nextVC : TextEntryViewController = self.storyboard?.instantiateViewController(withIdentifier: self.nextViewControllerID) as! TextEntryViewController
                        switch (self.type) {
                            case .email:
                                self.user.email = self.textfield.text!
                            case .username:
                                self.user.username = self.textfield.text!
                            case .password:
                                self.user.password = self.textfield.text!
                            default:
                                break
                        }
                        nextVC.user = self.user
                        nextVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        self.present(nextVC, animated: false, completion: nil)
                    }
                } else {
                    // else animation and show error text
                   self.signalValidationError(responseString!)
                    
                }
                
            }
            task.resume()
        }
        
//success or error message
//        if (true) {
//            // if valid next page
//
//            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: self.nextViewControllerID)
//            self.present(nextVC!, animated: true, completion: nil)
//
//        } else {
//            // else animation and show error text
//
//            let shake = CAKeyframeAnimation(keyPath: "transform")
//            shake.values = [NSValue(caTransform3D: CATransform3DMakeTranslation(-10, 0, 0)) , NSValue(caTransform3D: CATransform3DMakeTranslation(10, 0, 0))]
//            shake.autoreverses = true;
//            shake.repeatCount = 2;
//            shake.duration = 0.1;
//            shake.isRemovedOnCompletion = true;
//            self.textfield.layer .add(shake, forKey: "shake")
//
//            self.errorTextLabel.text = "An error occured" //replace this with message from server
//        }
//

    }
    
    func signalValidationError(_ errorDescription: String) {
        let shake = CAKeyframeAnimation(keyPath: "transform")
        shake.values = [NSValue(caTransform3D: CATransform3DMakeTranslation(-10, 0, 0)) , NSValue(caTransform3D: CATransform3DMakeTranslation(10, 0, 0))]
        shake.autoreverses = true;
        shake.repeatCount = 2;
        shake.duration = 0.1;
        shake.isRemovedOnCompletion = true;
        
        DispatchQueue.main.async {
            self.textfield.layer.add(shake, forKey: "shake")
            if (self.confirmTextfield != nil) {
                self.confirmTextfield.text = ""
            }
            self.errorTextLabel.text = errorDescription //replace this with message from server
            
        }
    }
    
    @IBAction func createUser() {
        // register.php, [username], password, email
        // post user object to server
        // if 1 send to Push notification confirmation
        // else animation and show error text
        
        
        // login [username] [password]
        self.user.password = self.textfield.text!

        
        let url = URL(string: self.baseURL + "/register.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(user.username!)&email=\(user.email!)&password=\(user.password!)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            
            if responseString == "success" {
                User.currentUser.username = self.user.username
                User.currentUser.registered = true
                DispatchQueue.main.async {
                    let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "push")
                    nextVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.present(nextVC, animated: true, completion: nil)
                }
            } else {
                // else animation and show error text
                self.signalValidationError("That's weird. Something went wrong.")
                
            }
            
        }
        task.resume()

        
    }
    
    func login (_ username: String, _ password: String) {
        let url = URL(string: self.baseURL + "/login.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(username)&password=\(password)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            
            if responseString == "1" {
                User.currentUser.username = username
                //User.currentUser.email = self.user.email
                User.currentUser.registered = true
                
                DispatchQueue.main.async {
                    let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "push")
                    nextVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.present(nextVC, animated: true, completion: nil)
                }
            } else {
                // else animation and show error text
                self.signalValidationError("Your username or password was incorrect.💩")
                
            }
            
        }
        task.resume()

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
