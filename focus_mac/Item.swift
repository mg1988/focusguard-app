//
//  Item.swift
//  focus_mac
//
//  Created by Genwei Mi on 2026/4/12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
