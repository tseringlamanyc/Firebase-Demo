//
//  SellItemVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class SellItemVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var categories = Category.getCategories()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension SellItemVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            fatalError()
        }
        let aCategory = categories[indexPath.row]
        cell.configureCell(category: aCategory)
        return cell
    }
}

extension SellItemVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxSize: CGSize = UIScreen.main.bounds.size
        let spaceBetween: CGFloat = 11
        let numerOfItems: CGFloat = 3
        let totalSpacing: CGFloat = (2 * spaceBetween) + (numerOfItems - 1) * spaceBetween
        let itemWidth: CGFloat = (maxSize.width - totalSpacing) / numerOfItems
        let itemHeight: CGFloat = maxSize.height * 0.20
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
}
