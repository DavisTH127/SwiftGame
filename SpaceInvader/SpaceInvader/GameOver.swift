//
//  GameOver.swift
//  SpaceInvader
//
//  Created by Davis Hoang on 12/19/18.
//  Copyright © 2018 Davis Hoang. All rights reserved.
//

import UIKit
import SpriteKit

class GameOver: SKScene {
    var score:Int = 0
    
    var scoreLabel:SKLabelNode!
    var playAgain:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        scoreLabel = (self.childNode(withName: "scoreLabel") as! SKLabelNode)
        scoreLabel.text = "\(score)"
        
        playAgain = (self.childNode(withName: "playAgain") as! SKSpriteNode)
        playAgain.texture = SKTexture(imageNamed: "playAgain")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            let node = self.nodes(at: location)
        
        if node[0].name == "playAgain"{
            let gameScene:GameScene = GameScene(fileNamed: "GameScene")!
            gameScene.scaleMode = .aspectFill
            let transition:SKTransition = SKTransition.crossFade(withDuration: 1.0)
            self.view?.presentScene(gameScene, transition: transition)
        }
        }
    }
}
