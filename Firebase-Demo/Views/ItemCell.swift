//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    public func configureCell(item: Item) {
        itemLabel.text = item.itemName
        sellerName.text = item.sellerName
        dateLabel.text = item.listedDate.description
        let priceFormat = String(format: "%.2f", item.price)
        priceLabel.text = "$ \(priceFormat)"
        itemImage.kf.setImage(with: URL(string: item.imageURL))
    }
    
}
