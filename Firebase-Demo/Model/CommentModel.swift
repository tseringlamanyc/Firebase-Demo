//
//  CommentModel.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    let commentDate: Timestamp
    let commentedBy: String
    let itemId: String
    let itemName: String
    let sellerName: String
    let comment: String
}

extension Comment {
    init(dictonary: [String: Any]) {
        self.commentDate = dictonary["commentDate"] as? Timestamp ?? Timestamp(date: Date())
        self.commentedBy = dictonary["commentedBy"] as? String ?? "no commentedBy"
        self.itemId = dictonary["itemId"] as? String ?? "no itemId"
        self.itemName = dictonary["itemName"] as? String ?? "no itemName"
        self.sellerName = dictonary["sellerName"] as? String ?? "no sellerName"
        self.comment = dictonary["comment"] as? String ?? "no commemnt"
    }
}
