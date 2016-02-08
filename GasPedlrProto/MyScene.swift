//
//  MyScene.swift
//  SwiftBreakout
//
// TEST COMMENT 02/01/16
//

import UIKit
import SpriteKit
import iAd
import GameKit

protocol MySceneDelegate {
    func dead()
    func clear()
    func updateAd(spriteName: String)
}

class MyScene: SKScene, SKPhysicsContactDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var adArray = ["bannerSpa.png", "bannerStarbucks.png", "bannerHalfAcre.png", "bannerTacoBell.jpg"]
    
    var padX: Float! {
    didSet {
        if _pad != nil {
            _pad.position = CGPoint(x:CGFloat(padX), y:_pad.position.y)
        }
    }
    }
    
    var mySceneDelegate: MySceneDelegate?
    
    func reset() {
        _blocks = NSMutableSet()
        let y0 = size.height - 50
        for (color, y) in [
            (UIColor.redColor(),    y0-0),
            (UIColor.orangeColor(), y0-50),
            (UIColor.yellowColor(), y0-100),
            (UIColor.greenColor(),  y0-150),
            (UIColor.blueColor(),   y0-200),
            ] {
            let n = 10
            let blockWidth = size.width / CGFloat(n)
            let blockSize = CGSize(width:0.9*blockWidth, height:50)
            
            for i in 0..<n {
                var sprite: SKSpriteNode
                let randomNum = Int(arc4random_uniform(10) + 1)
                if (randomNum % 2 == 0) {
                //if (color == UIColor.greenColor()) {
                    //sprite = SKSpriteNode(imageNamed: "bannerHalfAcre.png")
                    //sprite.name = "test"
                    let randomIndex = Int(arc4random_uniform(UInt32(adArray.count)))
                    sprite = SKSpriteNode(imageNamed: adArray[randomIndex])
                    sprite.name = adArray[randomIndex]
                } else {
                    sprite = SKSpriteNode(color:color, size:blockSize)
                }
                sprite.position = CGPoint(x:(CGFloat(i) + 0.5) * blockWidth, y:y)
                sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
                sprite.physicsBody?.categoryBitMask = blockMask
                sprite.physicsBody?.dynamic = false
                addChild(sprite)
                _blocks.addObject(sprite)
            }
        }
    }
    
    func respawn(completion block: () -> Void) {
        _ball.runAction(SKAction.moveTo(CGPoint(x:_pad.position.x, y:20), duration:0), completion:block)
    }
    
    func fire() {
        _ball.physicsBody?.applyImpulse(CGVector(dx: CGFloat(arc4random() % 2 == 0 ? -0.5 : 0.5), dy: 0.5))
    }

    let wallMask     : UInt32 = 0b000001
    let ballMask     : UInt32 = 0b000010
    let blockMask    : UInt32 = 0b000100
    let padMask      : UInt32 = 0b001000
    let deadZoneMask : UInt32 = 0b010000

    var _blocks: NSMutableSet!
    var _ball, _pad, _deadZone: SKSpriteNode!
    var _blockSound, _padSound, _deadSound: SKAction!

    func didBeginContact(contact: SKPhysicsContact) {
        var ballBody, againstBody: SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask & ballMask) != 0 {
            ballBody = contact.bodyA
            againstBody = contact.bodyB
        } else if (contact.bodyB.categoryBitMask & ballMask) != 0 {
            ballBody = contact.bodyB
            againstBody = contact.bodyA
        } else {
            NSLog("something odd...")
            abort()
        }
        
        if (againstBody.categoryBitMask & blockMask) != 0 {
            runAction(_blockSound)
            //let textView = UITextView(frame: CGRectMake(20.0, 20.0, 800.0, 60.0))
            //textView.backgroundColor = UIColor.blackColor()
            //self.view!.addSubview(textView)
            if (againstBody.node!.name != nil) {
                mySceneDelegate?.updateAd(againstBody.node!.name!)
            }
            _blocks.removeObject(againstBody.node!)
            againstBody.node?.removeFromParent()
            let v = ballBody.velocity
            let n = hypotf(Float(v.dx), Float(v.dy))
            let av = CGVector(dx: CGFloat(0.1 * Float(v.dx) / n), dy: CGFloat(0.1 * Float(v.dy) / n))
            ballBody.applyImpulse(av)

            if _blocks.count < 1 {
                _ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                mySceneDelegate?.clear()
            }
        } else if (againstBody.categoryBitMask & padMask) != 0 {
            runAction(_padSound)
        } else if (againstBody.categoryBitMask & deadZoneMask) != 0 {
            runAction(_deadSound)
            _ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            let smokePath = NSBundle.mainBundle().pathForResource("Smoke", ofType:"sks")
            let smoke = NSKeyedUnarchiver.unarchiveObjectWithFile(smokePath!) as! SKEmitterNode
            smoke.position = _ball.position
            addChild(smoke)
            
            mySceneDelegate?.dead()
        }
    }
    
    func sendNotification() {
        let deadline = NSDate()
        let notification = UILocalNotification()
        notification.alertBody = "TEST!!!"
        print("reaching sendNoteifaiont")
        notification.fireDate = deadline
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    override init(size aSize: CGSize) {
        super.init(size: aSize)

        physicsBody = SKPhysicsBody(edgeLoopFromRect:frame)
        physicsBody?.categoryBitMask = wallMask
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        _deadZone = SKSpriteNode(color:UIColor.redColor(), size:CGSize(width:size.width, height:10))
        _deadZone.position = CGPoint(x:size.width / 2, y:_deadZone.size.height / 2)
        _deadZone.physicsBody = SKPhysicsBody(rectangleOfSize:_deadZone.size)
        _deadZone.physicsBody?.categoryBitMask = deadZoneMask
        _deadZone.physicsBody?.dynamic = false
        addChild(_deadZone)
            
        _ball = SKSpriteNode(color:UIColor.whiteColor(), size:CGSize(width:10, height:10))
        _ball.position = CGPoint(x:size.width / 2, y:20)
//        _ball.physicsBody = SKPhysicsBody(rectangleOfSize:_ball.size)
        _ball.physicsBody = SKPhysicsBody(circleOfRadius:_ball.size.width / 2)
        _ball.physicsBody?.categoryBitMask = ballMask
        _ball.physicsBody?.friction = 0.0
        _ball.physicsBody?.restitution = 1.0
        _ball.physicsBody?.linearDamping = 0.0
//        ball.physicsBody.allowsRotation = false
        _ball.physicsBody?.contactTestBitMask = blockMask|padMask|deadZoneMask
        addChild(_ball)
        
        padX = Float(size.width) / 6
   //     _pad = SKSpriteNode(color:UIColor.lightGrayColor(), size:CGSize(width:50, height:10))
        _pad = SKSpriteNode(imageNamed: "sampban.gif")

        _pad.position = CGPoint(x:CGFloat(padX), y:10)
        _pad.physicsBody = SKPhysicsBody(rectangleOfSize:_pad.size)
        _pad.physicsBody?.categoryBitMask = padMask
        _pad.physicsBody?.dynamic = false
        addChild(_pad)
      
      _blockSound = SKAction.playSoundFileNamed("Pop.caf", waitForCompletion:false)
         _padSound = SKAction.playSoundFileNamed("Ping.caf", waitForCompletion:false)
        _deadSound = SKAction.playSoundFileNamed("Basso.caf", waitForCompletion:false)
    }
}
