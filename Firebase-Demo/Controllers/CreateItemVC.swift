//
//  CreateItemVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateItemVC: UIViewController {
    
    @IBOutlet weak var itemNameTF: UITextField!
    @IBOutlet weak var itemPriceTF: UITextField!
    @IBOutlet weak var itemImage: UIImageView!
    
    private var category: Category
    
    private let dbService = DatabaseServices()
    
    private let storageService = StorageServices()
    
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
        guard let itemName = itemNameTF.text, !itemName.isEmpty, let priceText = itemPriceTF.text, !priceText.isEmpty, let price = Double(priceText), let selectedImage = selectedImage else {
            showAlert(title: "Missing Fields", message: "All fields are required including a photo")
            return
        }
        
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Complete profile")
            return
        }
        
        let resizeImage = UIImage.resizeImage(originalImage: selectedImage, rect: itemImage.bounds)
        
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self](result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Couldnt create item:\(error.localizedDescription)")
                }
            case .success(let documenId):
                // upload photo to storage
                self?.uploadPhoto(image: resizeImage, documentId: documenId)
            }
        }
    }
    
    private func uploadPhoto(image: UIImage, documentId: String) {
        storageService.uploadPhoto(itemId: documentId, image: image) { [weak self](result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Fail to upload \(error.localizedDescription)")
                }
            case .success(let url):
                self?.updateItemURL(url: url, documendId: documentId)
            }
        }
    }
    
    private func updateItemURL(url: URL, documendId: String) {
        // update an existing document on firebase
        Firestore.firestore().collection(DatabaseServices.itemsCollection).document(documendId).updateData(["imageURL" : url.absoluteString]) { [weak self] (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Failed to update item \(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
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
