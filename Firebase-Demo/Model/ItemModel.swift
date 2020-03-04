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
}
