//
//  GameScene.swift
//  SpaceInvader
//
//  Created by Davis Hoang on 12/10/18.
//  Copyright © 2018 Davis Hoang. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    var player:SKSpriteNode?
    var enemy:SKSpriteNode?
    var item:SKSpriteNode?
    var label:SKLabelNode?
    var fireRate:TimeInterval = 1.0
    var timeSinceFire:TimeInterval = 0
    var lastTime:TimeInterval = 0
    var possibleAliens = ["enemy1", "enemy2", "enemy3", "enemy4"]
    var score:Int = 0
    let noCategory:UInt32 = 0
    let laserCategory:UInt32 = 0b1
    let playerCategory:UInt32 = 0b1 << 1
    let enemyCategory:UInt32 = 0b1 << 2
    let itemCategory:UInt32 = 0b1 << 3
    
    var gameTimer:Timer!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        label = self.childNode(withName: "score") as? SKLabelNode
        player = self.childNode(withName: "player") as? SKSpriteNode
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = noCategory
        player?.physicsBody?.contactTestBitMask = enemyCategory | itemCategory
        
        item = self.childNode(withName: "item") as? SKSpriteNode
        item?.physicsBody?.categoryBitMask = itemCategory
        item?.physicsBody?.collisionBitMask = noCategory
        item?.physicsBody?.contactTestBitMask = playerCategory
        
        enemy = self.childNode(withName: "enemy") as? SKSpriteNode
        enemy?.physicsBody?.categoryBitMask = enemyCategory
        enemy?.physicsBody?.collisionBitMask = noCategory
        enemy?.physicsBody?.contactTestBitMask = playerCategory | laserCategory
        
        gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)

    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let cA:UInt32 = contact.bodyA.categoryBitMask
        let cB:UInt32 = contact.bodyB.categoryBitMask
        if cA == playerCategory || cB == playerCategory {
            let otherNode:SKNode = (cA == playerCategory) ? contact.bodyB.node! : contact.bodyA.node!
            playerDidCollide(with: otherNode)
        }
        else {
            let explosion:SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = contact.bodyA.node!.position
            self.addChild(explosion)
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    func playerDidCollide(with other:SKNode) {
        if other.parent == nil {
            return
        }
        let otherCategory = other.physicsBody?.categoryBitMask
        if otherCategory == itemCategory{
            let points:Int = other.userData?.value(forKey: "points") as! Int
            score += points
            label?.text = "Score: \(score)"
            other.removeFromParent()
            player?.removeFromParent()
        }
        if otherCategory == enemyCategory {
            other.removeFromParent()
            player?.removeFromParent()
        }
    }
    
    @objc func addAlien () {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: -100, highestValue: 500)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: 0, y: self.frame.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = itemCategory
        alien.physicsBody?.contactTestBitMask = enemyCategory
        alien.physicsBody?.collisionBitMask = playerCategory
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 15
    
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position - 250, y: -750), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
        
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        checkLaser(currentTime - lastTime)
        lastTime = currentTime
    }
    
    func checkLaser(_ frameRate:TimeInterval) {
        // add time to timer
        timeSinceFire += frameRate
        
        // return if it hasn't been enough time to fire laser
        if timeSinceFire < fireRate {
            return
        }
        
        //spawn laser
        spawnLaser()
        
        // reset timer
        timeSinceFire = 0
    }
    
    func spawnLaser() {
        // see if there's an existing laser
        let scene:SKScene = SKScene(fileNamed: "Laser")!
        let laser = scene.childNode(withName: "laser")
        laser?.position = player!.position
        laser?.move(toParent: self)
        laser?.physicsBody?.categoryBitMask = laserCategory
        laser?.physicsBody?.collisionBitMask = noCategory
        laser?.physicsBody?.contactTestBitMask = enemyCategory
        
        let waitAction = SKAction.wait(forDuration: 1.0)
        let removeAction = SKAction.removeFromParent()
        laser?.run(SKAction.sequence([waitAction,removeAction]))
    }
    
}
