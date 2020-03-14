//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

protocol ItemCellDelegate: AnyObject {
    func didTapName(itemCell: ItemCell, item: Item)
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private var currentItem: Item!
    
    weak var delegate: ItemCellDelegate?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
       let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(gesture:)))
        return gesture
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sellerName.addGestureRecognizer(tapGesture)
        sellerName.isUserInteractionEnabled = true
        sellerName.textColor = .systemBlue
    }
    
    @objc
    private func handleTap(gesture: UITapGestureRecognizer) {
        delegate?.didTapName(itemCell: self, item: currentItem)
    }
    
      public func configureCell(item: Item) {
        currentItem = item
        updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerNames: item.sellerName, date: item.listedDate, price: item.price)
      }
      
      public func configureCell(for favorite: Favorite) {
        updateUI(imageURL: favorite.imageURL, itemName: favorite.itemName, sellerNames: favorite.sellerName, date: favorite.favoritedDate, price: favorite.price)
      }
      
      private func updateUI(imageURL: String, itemName: String, sellerNames: String, date: Timestamp, price: Double) {
        itemImage.kf.setImage(with: URL(string: imageURL))
        itemLabel.text = itemName
        sellerName.text = "@\(sellerNames)"
        dateLabel.text = date.dateValue().dateString()
        let price = String(format: "%.2f", price)
        priceLabel.text = "$\(price)"
      }
}
    

