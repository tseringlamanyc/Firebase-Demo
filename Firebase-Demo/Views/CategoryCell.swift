//
//  CategoryCell.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    public func configureCell(category: Category) {
        let colorImage = category.image.withTintColor(UIColor.generateRandomColor(), renderingMode: .alwaysOriginal)
        itemImage.image = colorImage
        categoryLabel.text = category.name
    }
    
}

extension UIColor {
  static func generateRandomColor() -> UIColor {
      let redValue = CGFloat.random(in: 0...1)
      let greenValue = CGFloat.random(in: 0...1)
      let blueValue = CGFloat.random(in: 0...1)
      let randomColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
      return randomColor
  }
}
