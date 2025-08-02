//
//  Item.swift
//  flowerme
//
//  Created by 1234 on 7/4/25.
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
