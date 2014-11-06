//
//  Hero.swift
//  DodgeTheSkips
//
//  Created by Skip Wilson on 11/5/14.
//  Copyright (c) 2014 Skip Wilson. All rights reserved.
//

import Foundation
import SpriteKit

class Hero {
    var guy:SKSpriteNode
    var speed = 0.1
    var emit = false
    var emitFrameCount = 0
    var maxEmitFrameCount = 30
    var particles:SKEmitterNode
    
    init(guy:SKSpriteNode,particles:SKEmitterNode) {
        self.guy = guy
        self.particles = particles
    }
}
