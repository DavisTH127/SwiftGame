//
//  GameScene.swift
//  SpaceInvader
//
//  Created by Davis Hoang on 12/10/18.
//  Copyright © 2018 Davis Hoang. All rights reserved.
//
import UIKit
import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene,SKPhysicsContactDelegate {

    var player:SKSpriteNode?
    var enemy:SKSpriteNode?
    var item:SKSpriteNode?
    var label:SKLabelNode?
    var fireRate:TimeInterval = 1.0
    var timeSinceFire:TimeInterval = 0
    var lastTime:TimeInterval = 0
    var possibleAliens = ["enemy1", "enemy2", "enemy3", "enemy4"]
    var scoreLabel:SKLabelNode!
    var score:Int = 0{
        didSet{
            scoreLabel.text = "Score:\(score)"
        }
    }
    
    var lifeArray:[SKSpriteNode]!
    
    let alienCategory:UInt32 = 0b1 << 1
    let photonCategory:UInt32 = 0b1 << 0
    
    var gameTimer:Timer!
    
    override func didMove(to view: SKView) {
        
        addLife()
        
        player = SKSpriteNode(imageNamed: "ship")
        player?.position = CGPoint(x: 25, y: -200 )
        self.addChild(player!)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x:-150, y:550)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 76
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)

    }
    
    
    @objc func addAlien () {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: -100, highestValue: 500)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 15
    
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position - 250, y: -750), duration: animationDuration))
        
        actionArray.append(SKAction.run {
            if self.lifeArray.count > 0 {
                let lifeNode = self.lifeArray.first
                lifeNode!.removeFromParent()
                self.lifeArray.removeFirst()
                
                if self.lifeArray.count == 0 {
                    let gameOver:GameOver = GameOver(fileNamed: "GameOver")!
                    gameOver.scaleMode = .aspectFill
                    gameOver.score = self.score
                    let transition:SKTransition = SKTransition.crossFade(withDuration: 1.0)
                    self.view?.presentScene(gameOver, transition: transition)
                }
            }
        })
        
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
        
    }
    
    func addLife(){
        lifeArray = [SKSpriteNode]()
        
        for life in 1 ... 3 {
            let lifeNode = SKSpriteNode(imageNamed: "spaceShip")
            lifeNode.position = CGPoint(x: self.frame.size.width - CGFloat(4 - life) * lifeNode.size.width, y: self.frame.size.height - 60)
            self.addChild(lifeNode)
            lifeArray.append(lifeNode)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireLaser()
    }
    
    func fireLaser(){
        let lazer = SKSpriteNode(imageNamed: "lazer")
        lazer.position = (player?.position)!
        lazer.position.y = (player?.zPosition)! - 400
        lazer.physicsBody = SKPhysicsBody(circleOfRadius:lazer.size.width/2)
        lazer.physicsBody?.isDynamic = true
        
        lazer.physicsBody?.categoryBitMask = photonCategory
        lazer.physicsBody?.contactTestBitMask = alienCategory
        lazer.physicsBody?.collisionBitMask = 0
        lazer.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(lazer)
        let animationDuration: TimeInterval = 1
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x:(player?.position.x)! , y: self.frame.size.height + 5), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        lazer.run(SKAction.sequence(actionArray))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
            lazerCollide(lazer: firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
        }
    }
    
    func lazerCollide(lazer:SKSpriteNode, enemy: SKSpriteNode){
        let explosions = SKEmitterNode(fileNamed: "Explosion")
        explosions?.position = enemy.position
        self.addChild(explosions!)
        
        lazer.removeFromParent()
        enemy.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explosions?.removeFromParent()
        }
        
        score += 10
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        player?.position = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        player?.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        player?.position = pos
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
    
    }
   
}
