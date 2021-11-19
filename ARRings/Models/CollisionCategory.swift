//
//  CollisionCategory.swift
//  ARRings
//
//  Created by Наталья Шарапова on 17.11.2021.
//

import Foundation

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let scorePoint = CollisionCategory(rawValue: 1 << 0)
    static let scorePoint2 = CollisionCategory(rawValue: 1 << 1)
    static let pin = CollisionCategory(rawValue: 1 << 2)
    static let ring = CollisionCategory(rawValue: 1 << 3)
    static let area = CollisionCategory(rawValue: 1 << 4)
}
