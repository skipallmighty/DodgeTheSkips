//
//  GameScene.swift
//  DodgeTheSkips
//
//  Created by Skip Wilson on 11/5/14.
//  Copyright (c) 2014 Skip Wilson. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var hero:Hero!
    var touchLocation = CGFloat()
    var gameOver = false
    var badGuys:[BadGuy] = []
    var endOfScreenRight = CGFloat()
    var endOfScreenLeft = CGFloat()
    var score = 0
    var scoreLabel = SKLabelNode()
    var refresh = SKSpriteNode(imageNamed: "refresh")
    var timer = NSTimer()
    var countDownText = SKLabelNode(text: "5")
    var countDown = 5
    
    enum ColliderType:UInt32 {
        case Hero = 1
        case BadGuy = 2
    }
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1)
        endOfScreenRight = self.size.width / 2
        addBG()
        addJeff()
        addBadGuys()
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position.y = -(self.size.height/4)
        addChild(scoreLabel)
        addChild(refresh)
        addChild(countDownText)
        countDownText.hidden = true
        refresh.name = "refresh"
        refresh.hidden = true
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        hero.emit = true
        gameOver = true
        refresh.hidden = false
    }
    
    func addBG() {
        let bg = SKSpriteNode(imageNamed: "bg")
        addChild(bg)
    }
    
    func reloadGame() {
        countDownText.hidden = false
        hero.guy.position.y = 0
        hero.guy.position.x = 0
        refresh.hidden = true
        score = 0
        scoreLabel.text = "0"
        for badGuy in badGuys {
            resetBadGuy(badGuy.guy, yPos: badGuy.yPos)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if countDown > 0 {
            countDown--
            countDownText.text = String(countDown)
        } else {
            countDown = 5
            countDownText.text = String(countDown)
            countDownText.hidden = true
            gameOver = false
            timer.invalidate()
        }
    }
    
    func addJeff() {
        let jeff = SKSpriteNode(imageNamed: "jeff")
        jeff.physicsBody = SKPhysicsBody(circleOfRadius: jeff.size.width/2)
        jeff.physicsBody!.affectedByGravity = false
        jeff.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
        jeff.physicsBody!.contactTestBitMask = ColliderType.BadGuy.rawValue
        jeff.physicsBody!.collisionBitMask = ColliderType.BadGuy.rawValue
        let heroParticles = SKEmitterNode(fileNamed: "HitParticle.sks")
        heroParticles.hidden = true
        hero = Hero(guy: jeff, particles: heroParticles)
        jeff.addChild(heroParticles)
        addChild(jeff)
    }
    
    func addBadGuys() {
        addBadGuy(named: "natasha", speed: 1.0, yPos: CGFloat(self.size.height/4))
        addBadGuy(named: "boris", speed: 1.5, yPos: CGFloat(0))
        addBadGuy(named: "paul", speed: 3.0, yPos: CGFloat(-(self.size.height/4)))
    }
    
    func addBadGuy(#named:String, speed:Float, yPos:CGFloat) {
        var badGuyNode = SKSpriteNode(imageNamed: named)
        
        badGuyNode.physicsBody = SKPhysicsBody(circleOfRadius: badGuyNode.size.width/2)
        badGuyNode.physicsBody!.affectedByGravity = false
        badGuyNode.physicsBody!.categoryBitMask = ColliderType.BadGuy.rawValue
        badGuyNode.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue
        badGuyNode.physicsBody!.collisionBitMask = ColliderType.Hero.rawValue
        
        var badGuy = BadGuy(speed: speed, guy: badGuyNode)
        badGuys.append(badGuy)
        resetBadGuy(badGuyNode, yPos: yPos)
        badGuy.yPos = badGuyNode.position.y
        addChild(badGuyNode)
    }
    
    func resetBadGuy(badGuyNode:SKSpriteNode, yPos:CGFloat) {
        badGuyNode.position.x = endOfScreenRight
        badGuyNode.position.y = yPos
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        for touch: AnyObject in touches {
            if !gameOver {
                touchLocation = (touch.locationInView(self.view!).y * -1) + (self.size.height/2)
            } else {
                let location = touch.locationInNode(self)
                var sprites = nodesAtPoint(location)
                for sprite in sprites {
                    if let spriteNode = sprite as? SKSpriteNode {
                        if spriteNode.name != nil {
                            if spriteNode.name == "refresh" {
                                reloadGame()
                            }
                        }
                    }
                }
            }
        }
        
        let moveAction = SKAction.moveToY(touchLocation, duration: 0.5)
        moveAction.timingMode = SKActionTimingMode.EaseOut
        hero.guy.runAction(moveAction) {
            //not do anything
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if !gameOver {
            updateBadGuysPosition()
        }
        updateHeroEmitter()
    }
    
    func updateHeroEmitter() {
        if hero.emit && hero.emitFrameCount < hero.maxEmitFrameCount {
            hero.emitFrameCount++
            hero.particles.hidden = false
        } else {
            hero.emit = false
            hero.particles.hidden = true
            hero.emitFrameCount = 0
        }

    }
    
    
    func updateBadGuysPosition() {
        for badGuy in badGuys {
            if !badGuy.moving {
                badGuy.currentFrame++
                if badGuy.currentFrame > badGuy.randomFrame {
                    badGuy.moving = true
                }
            } else {
                badGuy.guy.position.y = CGFloat(Double(badGuy.guy.position.y) + sin(badGuy.angle) * badGuy.range)
                badGuy.angle += hero.speed
                if badGuy.guy.position.x > endOfScreenLeft {
                    badGuy.guy.position.x -= CGFloat(badGuy.speed)
                } else {
                    badGuy.guy.position.x = endOfScreenRight
                    badGuy.currentFrame = 0
                    badGuy.setRandomFrame()
                    badGuy.moving = false
                    badGuy.range += 0.1
                    updateScore()
                }
            }
        }
    }
    
    func updateScore() {
        score++
        scoreLabel.text = String(score)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
