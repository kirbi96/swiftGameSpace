//
//  GameScene.swift
//  swiftGame
//
//  Created by user on 14.10.2021.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var gameTimer: Timer!
    var fireTimer: Timer!
    var aliens: [String] = ["alien", "alien2", "alien3"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0
    
    var swipe: UIPanGestureRecognizer!
    var xSwipePosition: CGFloat = 0
    var ySwipePosition: CGFloat = 0
    
   
    override func didMove(to view: SKView) {
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: 0, y: 1472)
        starField.advanceSimulationTime(10)
        self.addChild(starField)
        
        starField.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: 0, y: -300)
        player.setScale(1.75)
        
        self.addChild(player)
        
        swipe = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(_:)))
        self.view!.addGestureRecognizer(swipe)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "AmericanTyperited-Bold"
        scoreLabel.fontSize = 56
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: -200, y: 550)
        
        score = 0
        
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        fireTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireBullet), userInfo: nil, repeats: true)
       
    }
    

    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        } else {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        
        if (firstBody.categoryBitMask & alienCategory) != 0 && (secondBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: secondBody.node as! SKSpriteNode, alienNode: firstBody.node as! SKSpriteNode)
        }
    }
    
    func collisionElements(bulletNode: SKSpriteNode, alienNode: SKSpriteNode) {
        let expression = SKEmitterNode(fileNamed: "Vzriv")
        expression?.position = alienNode.position
        
        self.addChild(expression!)
        
        self.run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false ))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            expression?.removeFromParent()
        }
        
        score += 1
    }
    
    @objc func handlePanFrom(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state != .changed {
            return
        }

        let translation = recognizer.translation(in: recognizer.view!)
        
        self.xSwipePosition += translation.x * 0.1
       
        self.ySwipePosition -= translation.y * 0.09
    }
    
    override func didSimulatePhysics() {
        player.position.x += xSwipePosition
        player.position.y += ySwipePosition
        
        if player.position.x < -350 {
            player.position = CGPoint(x: 350, y: player.position.y)
        } else if player.position.x > 350 {
            player.position = CGPoint(x: -350, y: player.position.y)
        }
              
        
        if player.position.y < -650 {
            player.position = CGPoint(x: player.position.x, y: -650)
        } else if player.position.y > 650 {
            player.position = CGPoint(x: player.position.x, y: -650)
        }
        
        self.xSwipePosition = 0
        self.ySwipePosition = 0
    }
  
    @objc func addAlien() {
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0])
        let randomPosition = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        let position = CGFloat(randomPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: 800)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.setScale(1.75)
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animDuration:TimeInterval = 6
        var actions = [SKAction]()
        
        actions.append(SKAction.move(to: CGPoint(x: position, y: -800), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
    }
    
    
    
    @objc func fireBullet() {
//        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += 5
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration:TimeInterval = 1
        var actions = [SKAction]()
        
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: 800), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
