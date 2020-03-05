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
    @IBOutlet weak var itemImage: UIImageView!
    
    private var category: Category
    
    private let dbService = DatabaseServices()
    
    private var selectedImage: UIImage? {
        didSet {
            itemImage.image = selectedImage
        }
    }
    
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(showPhotoOptions))
        return gesture
    }()
    
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
        itemImage.isUserInteractionEnabled = true
        itemImage.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    private func showPhotoOptions() {
        let alertController = UIAlertController(title: "Choose option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let photoLibrary = UIAlertAction(title: "Library", style: .default) { alertAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
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
    
    extension CreateItemVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                fatalError()
            }
            selectedImage = image
            dismiss(animated: true)
        }
}
