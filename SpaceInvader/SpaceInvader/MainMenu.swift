//
//  MainMenu.swift
//  SpaceInvader
//
//  Created by Davis Hoang on 12/10/18.
//  Copyright © 2018 Davis Hoang. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let game:GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .aspectFill
        let transition:SKTransition = SKTransition.crossFade(withDuration: 1.0)
        self.view?.presentScene(game, transition: transition)
    }
}
