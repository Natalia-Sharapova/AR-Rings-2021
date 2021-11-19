//
//  RingInit.swift
//  ARRings
//
//  Created by Наталья Шарапова on 18.11.2021.
//

import UIKit
import ARKit

final class RingInit: SCNNode {
    
    override init() {
        super.init()
        initialisation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialisation()
    }
    
    private func initialisation() {

        //Ring geometry
        let ring = SCNTorus(ringRadius: 0.20, pipeRadius: 0.01)
        ring.firstMaterial?.diffuse.contents = UIImage(named: "gold")
        
        //Get node
        self.geometry = ring
        
        //Get physics body
        self.physicsBody = SCNPhysicsBody(type: .dynamic,
                                              shape: SCNPhysicsShape(
                                              node: self,
                                              options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        //Add BitMasks to the Ball
        self.physicsBody?.categoryBitMask = CollisionCategory.ring.rawValue
        self.physicsBody?.collisionBitMask = CollisionCategory.area.rawValue | CollisionCategory.pin.rawValue
    }

}
