//
//  ScorePointInit.swift
//  ARRings
//
//  Created by Наталья Шарапова on 18.11.2021.
//

import ARKit
import UIKit

final class ScorePointInit: SCNNode {
    
    override init() {
        super.init()
        initialisation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialisation()
    }
    
    private func initialisation() {
        
        let scorePoint = SCNPlane(width: 0.3, height: 0.3)
        self.geometry = scorePoint
        
        self.opacity = 0
        
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: self))
        
        //Add physicsBody to get contact 
        self.physicsBody?.categoryBitMask = CollisionCategory.scorePoint.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.scorePoint2.rawValue
    }
}
