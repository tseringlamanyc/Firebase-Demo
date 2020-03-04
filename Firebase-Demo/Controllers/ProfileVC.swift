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
    
    
    @IBAction func signOutPressed(_ sender: UIButton) {
    }
}

extension ProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
