//
//  ProfileVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var displayNameTF: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    private lazy var imagePickerController: UIImagePickerController = {
       let ip = UIImagePickerController()
        ip.delegate = self
       return ip
    }()
    
    private var selectedImage: UIImage? {
        didSet {
            profileImage.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTF.delegate = self
        updateUI()
    }
    
    private func updateUI() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        // user - displayName, email, phonenumber, photoURL
        emailLabel.text = user.email
        displayNameTF.text = user.displayName
    }
    
    
    @IBAction func updatedProfile(_ sender: UIButton) {
        // change the users display name
        // make a request to change
        guard let displayName = displayNameTF.text, !displayName.isEmpty else {
            print("missing fields")
            return
        }
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = displayName
        request?.commitChanges(completion: { [unowned self] (error) in
            if let error = error {
                self.showAlert(title: "Error", message: "Couldnt commit changes: \(error)")
            } else {
                self.showAlert(title: "Success", message: "Changes commited")
            }
        })
    }
    
    @IBAction func editPhoto(_ sender: UIButton) {
        let alterController = UIAlertController(title: "Photo Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let photoLibrary = UIAlertAction(title: "Library", style: .default) { alterAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alterController.addAction(cameraAction)
        }
        alterController.addAction(photoLibrary)
        alterController.addAction(cancelAction)
        present(alterController, animated: true)
    }
    
    @IBAction func signOutPressed(_ sender: UIButton) {

    }
}

extension ProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        selectedImage = image
        dismiss(animated: true)
    }
}
