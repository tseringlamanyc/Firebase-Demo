//
//  ItemModel.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct Item {
    let itemName: String
    let price: Double
    let itemId: String  // document Id
    let listedDate: Date
    let sellerName: String
    let sellerId: String
    let category: String
    let imageURL: String
}

extension Item {
    init(dictonary: [String: Any]) {
        self.itemName = dictonary["itemName"] as? String ?? "no itemName"
        self.price = dictonary["price"] as? Double ?? 0.0
        self.itemId = dictonary["itemId"] as? String ?? "no itemId"
        self.listedDate = dictonary["listedDate"] as? Date ?? Date()
        self.sellerName = dictonary["sellerName"] as? String ?? "no sellerName"
        self.sellerId = dictonary["sellerId"] as? String ?? "no sellerId"
        self.category = dictonary["category"] as? String ?? "no category name"
        self.imageURL = dictonary["imageURL"] as? String ?? "no imageURL"
    }
}
