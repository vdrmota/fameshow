//
//  AnimationLibrary.swift
//  Bubblechat
//
//  Created by Matt Schrage on 6/10/16.
//  Copyright © 2016 Matt Schrage. All rights reserved.
//

import UIKit


class AnimationLibrary {
    var lib = [(key:[String], animationOptions:[AnimationOptions], style: UIBlurEffectStyle)]()

    static let sharedInstance = AnimationLibrary()
    
    fileprivate init() {
        
        let center:CGPoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        let bounds:CGRect = UIScreen.main.bounds
        
        lib.append({(key: ["❤️"], animationOptions:{
            let option = AnimationOptions()
            option.characters = ["❤️"]
            option.quantity = 100
            //option.startPoint = center
            //option.endPoint = CGPointZero
            option.appearanceDuration = 0
            option.disappearanceDuration = 0
            option.duration = 3
            option.characterSizeRange = (30,50)
            option.startRect = CGRect(x: 0, y: UIScreen.main.bounds.height + 30, width: UIScreen.main.bounds.width, height: 100)
            option.endRect = CGRect(x: -30, y: -100, width: UIScreen.main.bounds.width + 60, height: 10)
            option.staggered = true
            option.staggeredPeriod = 4
            
            return [option]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        lib.append({(key: ["🚀"], animationOptions:{
            let rocket = AnimationOptions()
            rocket.characters = ["🚀"]
            rocket.quantity = 1
            rocket.appearanceDuration = 0
            rocket.disappearanceDuration = 0
            rocket.startPoint = CGPoint(x: -50, y: UIScreen.main.bounds.height+50)
            rocket.endPoint = CGPoint(x: UIScreen.main.bounds.width+50, y: -50)
            rocket.duration = 3
            rocket.characterSize = 100

            let stars = AnimationOptions()
            stars.characters = ["⭐️", "🌟"]
            stars.quantity = 10
            stars.characterSizeRange = (30,50)
            stars.staggered = true
            stars.appearanceAnimation = [.fadeIn, .grow]
            stars.durationAnimation = [.spin]
            stars.duration = 1
            stars.disappearanceAnimation = [.fadeOut]
            stars.startRect = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 300)
            
            return [rocket, stars]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        lib.append({(key: ["👉","👌"], animationOptions:{
            let finger = AnimationOptions()
            finger.characters = ["👉"]
            finger.quantity = 1
            finger.appearanceAnimation = [.grow]
            finger.appearanceDuration = 0.5
            finger.duration = 3
            finger.durationAnimation = [.horizontal]
            finger.characterSize =  150
            finger.startPoint =  CGPoint(x: center.x - 30, y: center.y)
            finger.disappearanceDuration = 1
            finger.disappearanceAnimation = [.fadeOut]
            
            let hole = AnimationOptions()
            hole.characters = ["👌"]
            hole.quantity = 1
            hole.appearanceAnimation = [.grow]
            hole.appearanceDuration = 0.5
            hole.duration = 3
            hole.characterSize =  130
            hole.startPoint =  CGPoint(x: center.x + 50, y: center.y - 20)
            hole.disappearanceDuration = 1
            hole.disappearanceAnimation = [.fadeOut]

            
            return [hole, finger]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
            
        lib.append({(key: ["🌱"], animationOptions:{
            let plants = AnimationOptions()
            plants.characters = ["🌻","🌱","🌿","🌾"]
            plants.quantity = 20
            plants.appearanceAnimation = [.grow]
            plants.appearanceDuration = 0.5
            plants.duration = 3
            plants.characterSizeRange = (50,60)
            plants.startRect = CGRect(x: 0, y: bounds.height - 30, width: bounds.width, height: 30)
            plants.disappearanceDuration = 0.5
            plants.disappearanceAnimation = [.shrink]
            plants.staggered = true
            plants.staggeredPeriod = 0.5
            
            let tree = AnimationOptions()
            tree.characters = ["🌳"]
            tree.quantity = 1
            tree.appearanceAnimation = [.grow]
            tree.appearanceDuration = 0.5
            tree.duration = 3
            tree.characterSize = 300
            tree.startRect = CGRect(x: 100, y: bounds.height - 200, width: bounds.width-200, height: 100)
            tree.disappearanceDuration = 0.25
            tree.disappearanceAnimation = [.fadeOut]
            
            return [tree, plants]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        
        lib.append({(key: ["💧"], animationOptions:{
            let leftCloud = AnimationOptions()
            leftCloud.characters = ["☁️"]
            leftCloud.quantity = 1
            leftCloud.appearanceDuration = 0
            leftCloud.duration = 3
            leftCloud.characterSize =  300
            leftCloud.startPoint = CGPoint(x: -120, y: 75)
            leftCloud.endPoint = CGPoint(x: center.x - 100, y: 75)
            leftCloud.disappearanceDuration = 10
            leftCloud.disappearanceAnimation = [.shrink, .fadeOut]
            
            let rightCloud = AnimationOptions()
            rightCloud.characters = ["☁️"]
            rightCloud.quantity = 1
            rightCloud.appearanceDuration = 0
            rightCloud.duration = 3
            rightCloud.characterSize =  300
            rightCloud.startPoint = CGPoint(x: bounds.width+120, y: 75)
            rightCloud.endPoint = CGPoint(x: center.x + 50, y: 75)
            rightCloud.disappearanceDuration = 10
            rightCloud.disappearanceAnimation = [.shrink, .fadeOut]
            
            let rain = AnimationOptions()
            rain.characters = ["💧"]
            rain.quantity = 100
            rain.appearanceDuration = 2
            rain.duration = 2
            rain.characterSize =  20
            rain.startRect = CGRect(x: 30, y: -40, width: bounds.width - 60, height: 30)
            rain.endRect = CGRect(x: 0, y: bounds.height + 30, width: bounds.width, height: 100)
            rain.disappearanceDuration = 0
            rain.staggered = true
            rain.staggeredPeriod = 4
            
            return [rain, leftCloud,rightCloud]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        lib.append({(key: ["❄️"], animationOptions:{
            let leftCloud = AnimationOptions()
            leftCloud.characters = ["☁️"]
            leftCloud.quantity = 1
            leftCloud.appearanceDuration = 0
            leftCloud.duration = 3
            leftCloud.characterSize =  300
            leftCloud.startPoint = CGPoint(x: -120, y: 75)
            leftCloud.endPoint = CGPoint(x: center.x - 100, y: 75)
            leftCloud.disappearanceDuration = 10
            leftCloud.disappearanceAnimation = [.shrink, .fadeOut]
            
            let rightCloud = AnimationOptions()
            rightCloud.characters = ["☁️"]
            rightCloud.quantity = 1
            rightCloud.appearanceDuration = 0
            rightCloud.duration = 3
            rightCloud.characterSize =  300
            rightCloud.startPoint = CGPoint(x: bounds.width+120, y: 75)
            rightCloud.endPoint = CGPoint(x: center.x + 50, y: 75)
            rightCloud.disappearanceDuration = 10
            rightCloud.disappearanceAnimation = [.shrink, .fadeOut]
            
            let rain = AnimationOptions()
            rain.characters = ["❄️"]
            rain.quantity = 100
            rain.appearanceDuration = 2
            rain.duration = 2
            rain.characterSize =  20
            rain.startRect = CGRect(x: 30, y: -40, width: bounds.width - 60, height: 30)
            rain.endRect = CGRect(x: 0, y: bounds.height + 30, width: bounds.width, height: 100)
            rain.disappearanceDuration = 0
            rain.staggered = true
            rain.staggeredPeriod = 4
            
            return [rain, leftCloud,rightCloud]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())

        
        lib.append({(key: ["🍑"], animationOptions:{
            let butt = AnimationOptions()
            butt.characters = ["🍑"]
            butt.quantity = 1
            butt.appearanceAnimation = [.grow]
            butt.appearanceDuration = 1
            butt.duration = 1
            butt.characterSize =  200
            butt.startPoint = center
            butt.disappearanceDuration = 1
            butt.disappearanceAnimation = [.grow, .fadeOut]
            
            let other = AnimationOptions()
            other.characters = ["👀"]
            other.quantity = 10
            other.appearanceAnimation = [.grow]
            other.appearanceDuration = 0.5
            other.duration = 1.25
            other.durationAnimation = [.spin]
            other.characterSize = 50
            other.startRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            other.disappearanceDuration = 0.5
            other.disappearanceAnimation = [.shrink]
            other.staggered = true
            other.staggeredPeriod = 1
            
            return [other, butt]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        lib.append({(key: ["💩"], animationOptions:{
            let poo = AnimationOptions()
            poo.characters = ["💩"]
            poo.quantity = 1
            poo.appearanceAnimation = [.grow]
            poo.appearanceDuration = 1
            poo.duration = 0
            poo.characterSize =  200
            poo.startPoint = center
            poo.disappearanceDuration = 1
            poo.disappearanceAnimation = [.grow, .fadeOut]
            
            return [poo]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())

        lib.append({(key: ["💡"], animationOptions:{
            let face = AnimationOptions()
            face.characters = ["😃"]
            face.quantity = 1
            face.appearanceAnimation = [.grow]
            face.appearanceDuration = 1
            face.duration = 4
            face.characterSize =  150
            face.startPoint = center
            face.disappearanceDuration = 1
            face.disappearanceAnimation = [.shrink]
            
            let bulb = AnimationOptions()
            bulb.characters = ["💡"]
            bulb.quantity = 1
            bulb.appearanceAnimation = [.hidden]
            bulb.appearanceDuration = 1
            bulb.durationAnimation = [.vertical]
            bulb.duration = 1.5
            bulb.characterSize =  90
            bulb.startPoint = center
            bulb.endPoint = CGPoint(x: center.x, y: center.y - 150);
            bulb.disappearanceDuration = 3.5
            bulb.disappearanceAnimation = [.fadeOut]
            
            return [bulb, face]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["🎩"], animationOptions:{
            let face = AnimationOptions()
            face.characters = ["😃"]
            face.quantity = 1
            face.appearanceAnimation = [.grow]
            face.appearanceDuration = 1
            face.duration = 4
            face.characterSize =  150
            face.startPoint = center
            face.disappearanceDuration = 1
            face.disappearanceAnimation = [.fadeOut]
            
            let hat = AnimationOptions()
            hat.characters = ["🎩"]
            hat.quantity = 1
            hat.appearanceAnimation = [.hidden]
            hat.appearanceDuration = 1
            hat.durationAnimation = [.vertical]
            hat.duration = 1.5
            hat.characterSize =  90
            hat.startPoint = CGPoint(x: center.x, y: -50);
            hat.endPoint = CGPoint(x: center.x, y: center.y - 100);
            hat.disappearanceDuration = 3.5
            hat.disappearanceAnimation = [.hidden]
            
            return [face, hat]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["💣"], animationOptions:{
            let bomb = AnimationOptions()
            bomb.characters = ["💣"]
            bomb.quantity = 1
            bomb.appearanceAnimation = [.grow]
            bomb.appearanceDuration = 1
            bomb.duration = 1
            bomb.characterSize =  150
            bomb.startPoint = center
            bomb.disappearanceDuration = 0
            
            let three = AnimationOptions()
            three.characters = ["3️⃣"]
            three.quantity = 1
            three.appearanceAnimation = [.hidden]
            three.appearanceDuration = 1
            three.durationAnimation = [.pulse]
            three.duration = 0.3
            three.characterSize =  90
            three.startPoint = CGPoint(x: center.x, y: center.y - 130);
            three.disappearanceDuration = 0

            let two = AnimationOptions()
            two.characters = ["2️⃣"]
            two.quantity = 1
            two.appearanceAnimation = [.hidden]
            two.appearanceDuration = 1.3
            two.durationAnimation = [.pulse]
            two.duration = 0.3
            two.characterSize =  90
            two.startPoint = CGPoint(x: center.x, y: center.y - 130);
            two.disappearanceDuration = 0
            
            let one = AnimationOptions()
            one.characters = ["1️⃣"]
            one.quantity = 1
            one.appearanceAnimation = [.hidden]
            one.appearanceDuration = 1.6
            one.durationAnimation = [.pulse]
            one.duration = 0.3
            one.characterSize =  90
            one.startPoint = CGPoint(x: center.x, y: center.y - 130);
            one.disappearanceDuration = 0
            
            let bang = AnimationOptions()
            bang.characters = ["⁉️"]
            bang.quantity = 1
            bang.appearanceAnimation = [.hidden]
            bang.appearanceDuration = 1.9
            bang.durationAnimation = [.pulse]
            bang.duration = 0.1
            bang.characterSize =  90
            bang.startPoint = CGPoint(x: center.x, y: center.y - 130);
            bang.disappearanceDuration = 0
            
            let explosion = AnimationOptions()
            explosion.characters = ["💥"]
            explosion.quantity = 30
            explosion.appearanceAnimation = [.hidden]
            explosion.appearanceDuration = 2
            explosion.durationAnimation = [.pulse, .spin]
            explosion.duration = 0.1
            explosion.characterSize =  90
            explosion.startRect = CGRect(x: 50, y: center.y - 75, width: bounds.width - 100, height: 150)
            explosion.disappearanceDuration = 0
            explosion.staggered = true
            
            let explosionMain = AnimationOptions()
            explosionMain.characters = ["💥"]
            explosionMain.quantity = 1
            explosionMain.appearanceAnimation = [.hidden]
            explosionMain.appearanceDuration = 2
            explosionMain.durationAnimation = [.pulse, .spin]
            explosionMain.duration = 0
            explosionMain.characterSize =  150
            explosionMain.startPoint = center
            explosionMain.disappearanceDuration = 0.5
            explosionMain.disappearanceAnimation = [.grow, .fadeOut]
            


            return [ bomb,three,two, one, bang, explosionMain, explosion]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["🔫"], animationOptions:{
            let face = AnimationOptions()
            face.characters = ["😐"]
            face.quantity = 1
            face.appearanceAnimation = [.grow]
            face.appearanceDuration = 1
            face.duration = 0.25
            face.characterSize =  100
            face.startPoint = CGPoint(x: center.x - 50, y: center.y)
            face.disappearanceDuration = 0
            
            let gun = AnimationOptions()
            gun.characters = ["🔫"]
            gun.quantity = 1
            gun.appearanceAnimation = [.grow]
            gun.appearanceDuration = 1
            gun.duration = 1.5
            gun.characterSize =  90
            gun.startPoint = CGPoint(x: center.x + 50, y: center.y)
            gun.disappearanceDuration = 1
            gun.disappearanceAnimation = [.shrink]
            
            let explosion = AnimationOptions()
            explosion.characters = ["💥"]
            explosion.quantity = 1
            explosion.appearanceAnimation = [.hidden]
            explosion.appearanceDuration = 1
            explosion.durationAnimation = [.spin]
            explosion.duration = 0
            explosion.characterSize =  200
            explosion.startPoint =  CGPoint(x: center.x - 50, y: center.y)
            explosion.disappearanceDuration = 1
            explosion.disappearanceAnimation = [.fadeOut]
            
            let skull = AnimationOptions()
            skull.characters = ["💀"]
            skull.quantity = 1
            skull.appearanceAnimation = [.hidden]
            skull.appearanceDuration = 1.25
            skull.duration = 0.25
            skull.characterSize =  100
            skull.startPoint = CGPoint(x: center.x - 50, y: center.y)
            skull.disappearanceDuration = 1
            skull.disappearanceAnimation = [.shrink]
            
            return [face, skull, gun, explosion]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
            lib.append({(key: ["🔥"], animationOptions:{
                let fire = AnimationOptions()
                fire.characters = ["🔥"]
                fire.quantity = 30
                fire.appearanceAnimation = [.fadeIn]
                fire.appearanceDuration = 0.5
                fire.duration = 2
                fire.durationAnimation = [.wobble, .pulse]
                fire.characterSize =  80
                fire.startRect = CGRect(x: 0, y: bounds.height - 50, width: bounds.width, height: 20);
                fire.disappearanceDuration = 1
                fire.disappearanceAnimation = [.fadeOut]
                fire.staggered = true
                
                return [fire]
                
                }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["👑"], animationOptions:{
            let face = AnimationOptions()
            face.characters = ["😃"]
            face.quantity = 1
            face.appearanceAnimation = [.grow]
            face.appearanceDuration = 1
            face.duration = 4
            face.characterSize =  150
            face.startPoint = center
            face.disappearanceDuration = 1
            face.disappearanceAnimation = [.fadeOut]
            
            let crown = AnimationOptions()
            crown.characters = ["👑"]
            crown.quantity = 1
            crown.appearanceAnimation = [.hidden]
            crown.appearanceDuration = 1
            crown.duration = 1.5
            crown.characterSize =  90
            crown.startPoint = CGPoint(x: center.x, y: -50);
            crown.endPoint = CGPoint(x: center.x, y: center.y - 90);
            crown.disappearanceDuration = 3.5
            crown.disappearanceAnimation = [.hidden]
            
            return [face, crown]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["🎈"], animationOptions:{
            let balloon = AnimationOptions.oneMovesLeftToRight("🎈", y: center.y + bounds.height*0.25)
            balloon.durationAnimation = [.vertical]
            balloon.duration = 3

            let runner = AnimationOptions.oneMovesLeftToRight("🏃", y: bounds.height - 30)
            runner.appearanceDuration = 0.4
            runner.duration = 3
            
            return [balloon, runner]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["😡"], animationOptions:{
            let face = AnimationOptions()
            face.characters = ["😡"]
            face.quantity = 1
            face.appearanceAnimation = [.grow]
            face.appearanceDuration = 1
            face.duration = 2
            face.durationAnimation = [.pulse]
            face.characterSize =  150
            face.startPoint = center
            face.disappearanceDuration = 1
            face.disappearanceAnimation = [.fadeOut]
            
            let fire = AnimationOptions()
            fire.characters = ["🔥"]
            fire.quantity = 30
            fire.appearanceAnimation = [.fadeIn]
            fire.appearanceDuration = 1
            fire.duration = 1.5
            fire.durationAnimation = [.wobble, .pulse]
            fire.characterSize =  80
            fire.startRect = CGRect(x: 0, y: bounds.height - 50, width: bounds.width, height: 20);
            fire.disappearanceDuration = 1
            fire.disappearanceAnimation = [.fadeOut]
            fire.staggered = true
            fire.staggeredPeriod = 1
            
            return [face, fire]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())

        lib.append({(key: ["😈"], animationOptions:{
            let face = AnimationOptions()
            face.characters = ["😈"]
            face.quantity = 1
            face.appearanceAnimation = [.grow]
            face.appearanceDuration = 1
            face.duration = 2
            face.durationAnimation = [.wobble, .pulse]
            face.characterSize =  150
            face.startPoint = center
            face.disappearanceDuration = 1
            face.disappearanceAnimation = [.fadeOut]
            
            let fire = AnimationOptions()
            fire.characters = ["🔥"]
            fire.quantity = 30
            fire.appearanceAnimation = [.fadeIn]
            fire.appearanceDuration = 1
            fire.duration = 1.5
            fire.durationAnimation = [.wobble, .pulse]
            fire.characterSize =  80
            fire.startRect = CGRect(x: 0, y: bounds.height - 50, width: bounds.width, height: 20);
            fire.disappearanceDuration = 1
            fire.disappearanceAnimation = [.fadeOut]
            fire.staggered = true
            fire.staggeredPeriod = 1
            
            return [face, fire]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())

        lib.append({(key: ["👿"], animationOptions:{
            let face = AnimationOptions()
            face.characters = ["👿"]
            face.quantity = 1
            face.appearanceAnimation = [.grow]
            face.appearanceDuration = 1
            face.duration = 2
            face.durationAnimation = [.wobble, .pulse]
            face.characterSize =  150
            face.startPoint = center
            face.disappearanceDuration = 1
            face.disappearanceAnimation = [.fadeOut]
            
            let fire = AnimationOptions()
            fire.characters = ["🔥"]
            fire.quantity = 30
            fire.appearanceAnimation = [.fadeIn]
            fire.appearanceDuration = 1
            fire.duration = 1.5
            fire.durationAnimation = [.wobble, .pulse]
            fire.characterSize =  80
            fire.startRect = CGRect(x: 0, y: bounds.height - 50, width: bounds.width, height: 20);
            fire.disappearanceDuration = 1
            fire.disappearanceAnimation = [.fadeOut]
            fire.staggered = true
            fire.staggeredPeriod = 1
            
            return [face, fire]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["💸"], animationOptions:{

            let cash = AnimationOptions.manyFloatUp(["💸"])
                
            cash.duration = 4.5
            cash.quantity = 10
            cash.characterSizeRange = (60, 80)
            cash.staggeredPeriod = 3
            cash.durationAnimation = [.wobble]
            
            return [cash]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["💯"], animationOptions:{
            
            let hundred = AnimationOptions.manyFloatUp(["💯"])

            hundred.quantity = 25
            hundred.durationAnimation = [.wobble]
            
            return [hundred]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["💵"], animationOptions:{
            
            let money = AnimationOptions.manyFloatDown(["💵"])
            
            money.quantity = 25
            money.durationAnimation = [.wobble]
            
            return [money]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["🎓"], animationOptions:{
            
            let capUp = AnimationOptions.manyFloatUp(["🎓"])
            capUp.quantity = 15
            capUp.durationAnimation = [.wobble]
            capUp.duration = 3
            
            let template = AnimationOptions()
            template.characterSize = 35
            template.appearanceDuration = 1
            template.appearanceAnimation = [.grow]
            template.duration = 6
            template.disappearanceAnimation = [.shrink]
            template.disappearanceDuration = 1
            template.durationAnimation = [.wobble]
            
            let congrats = AnimationOptions.row("CONGRATS".characters.map { String($0) }, center: center, templateOptions: template)
            
            let capDown = AnimationOptions.manyFloatDown(["🎓"])
            capDown.appearanceAnimation = [.hidden]
            capDown.appearanceDuration =  5
            capDown.quantity = 15
            capDown.durationAnimation = [.wobble]
            capDown.duration = 3

            
            return congrats+[capUp, capDown]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["📝"], animationOptions:{
            
            let face = AnimationOptions.oneAppearsCenter("😲")
            
            let homework = AnimationOptions.manyFloatDown(["📄","📝","📚","📓","📈","📖","📔","📒"])
            
            return [homework, face]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["🐴", "👌"], animationOptions:{
            
            let horse = AnimationOptions.oneAppearsCenter("🐴")
            horse.startPoint = CGPoint(x: center.x - 50, y: center.y)
            let hole = AnimationOptions.oneAppearsCenter("👌")
            hole.startPoint = CGPoint(x: center.x + 50, y: center.y)

            
            let template = AnimationOptions()
            template.characterSize = 35
            template.appearanceDuration = 1
            template.appearanceAnimation = [.grow]
            template.duration = 6
            template.disappearanceAnimation = [.shrink]
            template.disappearanceDuration = 1
            
            let asshole = AnimationOptions.row("ASSH💥LE".characters.map { String($0) }, center: CGPoint(x: center.x, y: center.y +  100), templateOptions: template)
            
            return [horse, hole]+asshole
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["🚔"], animationOptions:{
            
            let cops = AnimationOptions.manyFloatDown(["🚔"])
            cops.quantity = 5
            cops.characterSize = 60
            cops.staggeredPeriod = 1
            
            let car = AnimationOptions.oneFloatsDown("🚘", x: center.y)
            car.quantity = 1
            car.staggered = false
            car.characterSize = 60
            
            return [car, cops]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        lib.append({(key: ["💔"], animationOptions:{
            
            let heart = AnimationOptions.oneAppearsCenter("❤️")
            heart.characterSize = 100
            heart.startPoint = CGPoint(x: center.x - 30, y: center.y)
            heart.disappearanceDuration = 0
            
            let broken = AnimationOptions.oneAppearsCenter("💔")
            broken.characterSize = 100
            broken.startPoint = CGPoint(x: center.x - 32, y: center.y)
            broken.appearanceAnimation = [.hidden]
            broken.appearanceDuration = 3

            
            let hammer = AnimationOptions.oneAppearsCenter("🔨")
            hammer.characterSize = 100
            hammer.startPoint = CGPoint(x: center.x + 30, y: center.y)
            hammer.durationAnimation = [.wobble]
            hammer.duration = 4

            
            return [heart, broken, hammer]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        lib.append({(key: ["👅", "💦"], animationOptions:{
            
            let tongue = AnimationOptions.oneAppearsCenter("👅")
            tongue.characterSize = 100
            
            let jizz = AnimationOptions.oneAppearsCenter("💦")
            jizz.characterSize = 50
            jizz.startPoint = CGPoint(x: center.x, y: center.y + 12)
            jizz.durationAnimation = [.wobble]
            
            
            
            return [tongue, jizz]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        lib.append({(key: ["😘"], animationOptions:{
            
            let kiss = AnimationOptions.manyAppearRandomly(["💋"])
            kiss.characterSize = 100
            kiss.quantity = 3
            kiss.durationAnimation = []
            
            
            
            return [kiss]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["😍"], animationOptions:{
            
            let hearts = AnimationOptions.manyFloatUp(["❤️"])
            
            
            
            return [hearts]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["😴"], animationOptions:{
            
            let face = AnimationOptions.oneAppearsCenter("😴")
            face.durationAnimation = [.pulse]
            face.duration += 1
            let zzz = AnimationOptions.manyFloatUp(["💤"])
            zzz.quantity = 8
            zzz.durationAnimation = [.wobble]
            
            
            
            return [zzz, face]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        
        lib.append({(key: ["😂"], animationOptions:{
            
            let face = AnimationOptions.oneAppearsCenter("😂")
            face.durationAnimation = [.vertical]
            face.duration += 1
            let lol = AnimationOptions.manyAppearRandomly(["HAHA","LOL"])
            lol.quantity = 20
            lol.durationAnimation = [.wobble]
            
            
            return [lol, face]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["😒"], animationOptions:{
            
            let face = AnimationOptions.oneAppearsCenter("😒")
            face.durationAnimation = [.wobble]
            face.duration += 1
            let warning = AnimationOptions.manyAppearRandomly(["⚠️"])
            warning.quantity = 20
            warning.characterSizeRange = (20, 30)
            warning.durationAnimation = [.spin]
            
            
            return [warning, face]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["💃"], animationOptions:{
            
            let dancer = AnimationOptions.oneAppearsCenter("💃")
            dancer.durationAnimation = [.horizontal]

            let notes = AnimationOptions.manyAppearRandomly(["🎵"])
            notes.quantity = 30
            notes.characterSize = 30
            notes.durationAnimation = [.wobble]
            
            
            return [notes, dancer]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        lib.append({(key: ["👾"], animationOptions:{
            
            let a = AnimationOptions()
            a.characters = ["👾"]
            a.quantity = 10
            a.characterSize = 40
            a.appearanceDuration = 0.5
            a.appearanceAnimation = [.grow]
            a.duration = 3
            a.durationAnimation = [.horizontal]
            a.startRect = CGRect(x: 50, y: 100, width: bounds.width - 100, height: 300);
            a.endRect = CGRect(x: 50, y: 300, width: bounds.width - 100, height: 200);
            a.disappearanceAnimation = [.fadeOut, .shrink]
            a.disappearanceDuration = 0.5
            
            let rocket = AnimationOptions()
            rocket.characters = ["🚀"]
            rocket.quantity = 1
            rocket.characterSize = 40
            rocket.appearanceDuration = 0.5
            rocket.appearanceAnimation = [.grow]
            rocket.duration = 3
            rocket.durationAnimation = [.wobble]
            rocket.startPoint = CGPoint(x: bounds.width/2, y: bounds.height - 100)
            rocket.disappearanceAnimation = [.fadeOut, .shrink]
            rocket.disappearanceDuration = 0.5

            return [a, rocket]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.dark)}())
        
        lib.append({(key: ["💜"], animationOptions:{
            
            let heart = AnimationOptions.manyFloatUp(["💜"])
            return [heart]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["💛"], animationOptions:{
            
            let heart = AnimationOptions.manyFloatUp(["💛"])
            return [heart]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["💚"], animationOptions:{
            
            let heart = AnimationOptions.manyFloatUp(["💚"])
            return [heart]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["💙"], animationOptions:{
            
            let heart = AnimationOptions.manyFloatUp(["💙"])
            return [heart]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["😋"], animationOptions:{
            
            let face = AnimationOptions.oneAppearsCenter("😋")
            let food = AnimationOptions.manyAppearRandomly(["🍔","🍕","🍰","🍦","🍗"])
            return [food, face]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["😇"], animationOptions:{
            
            let face = AnimationOptions.oneAppearsCenter("😇")
            let hands = AnimationOptions.oneAppearsCenter("🙏")
            hands.characterSize = 60
            hands.startPoint = CGPoint(x: center.x, y: center.y + 60)
            hands.durationAnimation = [.vertical]

            return [face, hands]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.append({(key: ["☀️"], animationOptions:{
            
            let cloud = AnimationOptions()
            cloud.characters = ["☁️"]
            cloud.quantity = 1
            cloud.appearanceDuration = 0.5
            cloud.appearanceAnimation = [.grow]
            cloud.duration = 0.5
            cloud.characterSize =  300
            cloud.startPoint = CGPoint(x: center.x + 20, y: center.y - 50)
            cloud.disappearanceDuration = 0.5
            cloud.disappearanceAnimation = [.hidden]
            
            let sun = AnimationOptions()
            sun.characters = ["☀️"]
            sun.quantity = 1
            sun.appearanceDuration = 0.5
            sun.appearanceAnimation = [.grow]
            sun.duration = 0.5
            sun.durationAnimation = [.vertical]
            sun.characterSize =  150
            sun.startPoint = CGPoint(x: center.x, y: center.y - 20)
            sun.disappearanceDuration = 0.5
            sun.disappearanceAnimation = [.shrink]
            
            return [sun, cloud]
            
            }() as [AnimationOptions], style: UIBlurEffectStyle.light)}())
        
        lib.contains(where: {
            print($0.key)
            return false})

    }

    
    
    
    

    func animationExistsForMessage(_ message:[String]) -> Bool {
        print(message)
        return lib.contains(where: {message == $0.key})
    }

    func animationForMessage(_ message:[String]) -> (animationOptions:[AnimationOptions], style: UIBlurEffectStyle, id:NSInteger)?{
        
        if self.animationExistsForMessage(message) {
        
            let id = lib.index(where: { message == $0.key })!
            return (lib[id].animationOptions, lib[id].style, id)
            
        } else {
                    
            return ([AnimationOptions.defaultAnimation(message.first!)],UIBlurEffectStyle.light, -1)
        }
        
        return nil

    }

    func animationForIdentifier(_ id:NSInteger) -> (animationOptions:[AnimationOptions], style: UIBlurEffectStyle) {
        assert(0 <= id && id < lib.count, "`id` is not a valid index")
        return (lib[id].animationOptions, lib[id].style)
    }
}
