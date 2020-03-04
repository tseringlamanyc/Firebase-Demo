//
//  CreateItemVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateItemVC: UIViewController {
    
    @IBOutlet weak var itemNameTF: UITextField!
    @IBOutlet weak var itemPriceTF: UITextField!
    
    private var category: Category
    
    private let dbService = DatabaseServices()
    
    init?(coder: NSCoder, category: Category) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category.name
    }
    
    @IBAction func createPressed(_ sender: UIBarButtonItem) {
        guard let itemName = itemNameTF.text, !itemName.isEmpty, let priceText = itemPriceTF.text, !priceText.isEmpty, let price = Double(priceText) else {
            showAlert(title: "Missing Fields", message: "All fields are required")
            return
        }
        
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Complete proile")
            return
        }
        
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self](result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Couldnt create item:\(error.localizedDescription)")
                }
            case .success:
                DispatchQueue.main.async {
                    self?.showAlert(title: nil, message: "Successfully listed the item")
                }
            }
        }
    }
}
