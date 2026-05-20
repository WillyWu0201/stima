//
//  Item.swift
//  stima
//
//  Created by Willy on 2026/5/20.
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
