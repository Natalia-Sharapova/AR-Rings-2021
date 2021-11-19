//
//  ScorePoint2Init.swift
//  ARRings
//
//  Created by Наталья Шарапова on 18.11.2021.
//

import ARKit
import UIKit

final class ScorePoint2Init: SCNNode {
    
    override init() {
        super.init()
        initialisation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialisation()
    }
    
    private func initialisation() {
        
        let scorePoint2 = SCNSphere(radius: 0.002)
        
        self.geometry = scorePoint2
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: self))
        
        //Add physicsBody to get contact 
        self.physicsBody?.categoryBitMask = CollisionCategory.scorePoint2.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.scorePoint.rawValue
        
    }
}
