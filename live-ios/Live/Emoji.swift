//
//  Emoji.swift
//  Bubblechat
//
//  Created by Matt Schrage on 2/9/16.
//  Copyright © 2016 Matt Schrage. All rights reserved.
//

import UIKit

class Emoji: UIView {
    var label:UILabel?
    var background:UIImageView?
    var character:String = "" {
        didSet{
            
            label?.text = character
            label?.transform = CGAffineTransform.identity
            label?.frame = self.frame
            
            let fontSize = floor(self.frame.width) - floor(self.frame.width).truncatingRemainder(dividingBy: 10)
            
            let nonemoji =  Emoji.alphabet() + Emoji.txts() + Emoji.apps()
            
            let characterIsEmoji:Bool = !nonemoji.contains(character)
            if characterIsEmoji{
                label!.font = UIFont(name: "AppleColorEmoji", size: fontSize);//60 -5.5
                label?.adjustsFontSizeToFitWidth = true
                
                label?.shadowColor = nil

                background?.isHidden = true

            } else if Emoji.apps().contains(character){
                background?.frame = self.frame.insetBy(dx: fontSize * (1/12), dy: fontSize * (1/12))
                background?.isHidden = false
                background?.image = UIImage(named: "\(character).png")
                background?.layer.cornerRadius = fontSize * (1/4);
                background?.layer.masksToBounds = true
                
                label?.text = ""

            } else {

                background?.frame = self.frame.insetBy(dx: fontSize * (1/12), dy: fontSize * (1/12))
                background?.isHidden = false
                background?.image = UIImage(named: "Emoji-letter-92.png")
                background?.layer.cornerRadius = 0;
                background?.layer.masksToBounds = false

                if character.characters.count == 1 {
                    label!.font = UIFont(name: "Helvetica-Bold", size: ceil(fontSize * 3/5));
                    label?.adjustsFontSizeToFitWidth = false

                    label?.shadowColor = UIColor.black
                    label?.shadowOffset = CGSize(width: 0, height: -0.5)

                    

                } else {
                    
                    var size: CGFloat = ceil(fontSize * 4/10)
                    
                    if character.characters.count == 2 {
                        size = ceil(fontSize * 5/10)
                    } else if character.characters.count == 3 {
                        size = ceil(fontSize * 4/10)
                    } else if character.characters.count >= 4 {
                        size = ceil(fontSize * 3/10)

                    }
                    
                    label!.font = UIFont(name: "Arial-BoldMT", size: size);
                    label?.adjustsFontSizeToFitWidth = false
                    
                    
                    label?.transform =  CGAffineTransform(scaleX: 0.75, y: 1.15);
                    label?.center = CGPoint(x: label!.center.x - self.bounds.width * (1/70), y: label!.center.y) // wierd necessary offest... after transform label no longer centered
                    
                    
                    let kerning:CGFloat
                    if(self.background!.frame.width < 30){
                        kerning = 0
                        label?.shadowColor = nil

                    } else {
                        kerning = -2
                        label?.shadowColor = UIColor(red:0.3, green:0.49, blue:0.69, alpha:1.0)

                    }
                    let attributedString = NSMutableAttributedString(string: character)
                    attributedString.addAttribute(NSAttributedStringKey.kern, value: kerning, range: NSRange(location: 0, length: character.characters.count))
                    
                    label?.attributedText = attributedString

                }
            }
        }
    }
    
    init(character:String, frame: CGRect) {
        super.init(frame: frame)

        background = UIImageView(frame: frame.insetBy(dx: 9, dy: 9))
        self.addSubview(background!)
        
        label = UILabel(frame: frame)
        label?.textColor = UIColor.white
        //label?.shadowOffset = CGSizeMake(0, -0.5)
        label?.textAlignment = .center;
        self.addSubview(label!)

        //closue to ensure that didSet is called
        let _ = {self.character = character}()

        //label?.text = character

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func alphabet() -> [String]{
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?@$&*<>+-=".characters.map { String($0) }
    }
    
    class func txts() -> [String]{
        //sorted by # of characters and alphabetically
        let txts:[String] = ["ME","LOL","GTG","HAHA","OK","BRB","WBU","WOW","OMG","YAY", "NEW", "WHAT","COOL", "HERE","COME","MEET","LETS","CYA","BYE","THIS","AFTER","ALSO","GO","WHEN", "WHO","NO","NOT","YOUR","TRY","HUH","YOU","UP","CHILL","BUT","WHERE","THX","SOON","SHUD","IM","WE","NOW","FOR","THEN","TIME","WE","ALL","SORRY","TODAY","MAYBE","BTW","NVM","HI"].sorted(by: {($0.characters.count == $1.characters.count) ?$0 < $1 : ($0.characters.count < $1.characters.count)})
        
        return txts
    }
    
    class func apps() -> [String]{
        let apps:[String] = ["instagram","messenger-bordered","whatsapp-bordered","imessage-bordered","snapchat"]
        return apps
    }
    
    class func groupedByCategory() -> [[(category:String, emojis:[String])]]{
        let alphabet = Emoji.alphabet()
        
        let txt = Emoji.txts()

        let apps = Emoji.apps()

        var dict: [String: [String]]? = nil
        
        if let path = Bundle.main.path(forResource: "emojis", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
//                let json = JSON(data: data, options: JSONSerialization.ReadingOptions.allowFragments, error: nil)
//                //print("jsonData:\(json)")
//                
//                for (_,subJson):(String, JSON) in json {
//                    
//                    let category = subJson["category"].stringValue
//                    let char = subJson["char"].stringValue
//                    
//                    if dict == nil {
//                        dict  = [category : [char]]
//                        continue
//                    }
//                    
//                    if dict![category] == nil {
//                        dict![category] = []
//                        
//                    }
//                    dict![category]!.append(char)
//                    
//                }
            }
        }
        
        
        var categories: [[(category:String, emojis:[String])]] = [[("Faces",["😂","😍","😒","😊","😭","😘","😏","😋","😴","😡"]),("Apps",apps),("👍Hands",["👌","🙏","👍","🙌","✌️"]),("🍴Food",["🍔","🍕","🍟","🍣","🍗","🍝","🍜","🍚","🍰","🍴"]),("🆒Making Plans",["WHAT","WBU","LETS", "MEET","CHILL","GO","SOON","TODAY","WHERE","COME"]),("💕Hearts",["❤️","💔","💘","💖","💝","💕","💟","💙","💛","💜"]),("⚽️Sports",["⚽️","🏀","🏈","⚾️","🎾"]),("🍻Night out",["🎈","🎉","🍸","🍷","🍺","🍻"])]]
        
//        for cat in dict!{
//            
//            let sorted = cat.1.sorted(by: {String($0).unicodeScalars.first!.value > String($1).unicodeScalars.first!.value})
//            
//            categories.append([(cat.0, sorted)])
//        }
        
        //flatten
        /*var categories = dict!.map{$1}
        
        
        //sort by code point
        for i in 0...7 {
            categories[i].sortInPlace({String($0).unicodeScalars.first!.value > String($1).unicodeScalars.first!.value})
        }
        */
        //append custom emoji
        categories.append([("🔠Alphabet",alphabet)])
        categories.append([("🆒Texts",txt)])
        categories.append([("🌀Apps",apps)])
        
        //categories.insert([("Faces",["😂","😍","😒","😊","😭","😘","😏","😋","😴","😡"]),("👍Hands",["👌","🙏","👍","🙌","✌️"]),("🍴Food",["🍔","🍕","🍟","🍣","🍗","🍝","🍜","🍚","🍰","🍴"]),("🆒Making Plans",["WHAT","WBU","LETS", "MEET","CHILL","GO","SOON","TODAY","WHERE","COME"]),("💕Hearts",["❤️","💔","💘","💖","💝","💕","💟","💙","💛","💜"]),("Sports",["⚽️","🏀","🏈","⚾️","🎾"])], atIndex: 0)
        
        return categories
    }
    
    class func allEmoji() -> [String]{
        let alphabet = Emoji.alphabet()
        
        let txt = Emoji.txts()
        
        let apps = Emoji.apps()
        
        var dict: [String: [String]]? = nil
        
        if let path = Bundle.main.path(forResource: "emojis", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                //let json = JSON(data: data, options: JSONSerialization.ReadingOptions.allowFragments, error: nil)
                //print("jsonData:\(json)")
                
//                for (_,subJson):(String, JSON) in json {
//
//                    let category = subJson["category"].stringValue
//                    let char = subJson["char"].stringValue
//
//                    if dict == nil {
//                        dict  = [category : [char]]
//                        continue
//                    }
//
//                    if dict![category] == nil {
//                        dict![category] = []
//
//                    }
//                    dict![category]!.append(char)
//
//                }
            }
        }

        
        //flatten
        var categories:[[String]] = []//dict!.map{$1}
        
        
        //sort by code point
//        for i in 0...7 {
//        categories[i].sort(by: {String($0).unicodeScalars.first!.value > String($1).unicodeScalars.first!.value})
//        }

        //append custom emoji
        categories += [alphabet, txt, apps]
        
        return categories.flatMap({$0})
    }
        
}
