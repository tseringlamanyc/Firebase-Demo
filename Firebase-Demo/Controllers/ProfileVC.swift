//
//  ProfileVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

enum ViewState {
    case myItems
    case myFav
}

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var displayNameTF: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
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
    
    private var refreshControl: UIRefreshControl!
    
    private let storageService = StorageServices()
    
    private var viewState: ViewState = .myItems {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var myFav = [Favorite]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private var myItems = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTF.delegate = self
        updateUI()
        loadAllData()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadAllData), for: .valueChanged)
    }
    
    private func updateUI() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        // user - displayName, email, phonenumber, photoURL
        emailLabel.text = user.email
        displayNameTF.text = user.displayName
        profileImage.kf.setImage(with: user.photoURL)
    }
    
    @objc
    private func fetchUserItems() {
        
        guard let user = Auth.auth().currentUser else {
            refreshControl.endRefreshing()
            return
        }
        
        DatabaseServices.shared.fetchUserItems(userId: user.uid) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail", message: "\(error.localizedDescription)")
                }
            case .success(let items):
                self?.myItems = items
            }
        }
    }
    
    @objc
    private func fetchUserFav() {
        
        DatabaseServices.shared.fetchUsersFav { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail", message: "\(error.localizedDescription)")
                }
            case .success(let favs):
                self?.myFav = favs
            }
        }
    }
    
    @objc
       private func loadAllData() {
           fetchUserFav()
           fetchUserItems()
       }
    
    @IBAction func updatedProfile(_ sender: UIButton) {
        // change the users display name
        // make a request to change
        guard let displayName = displayNameTF.text, !displayName.isEmpty, let selectedImage = selectedImage else {
            print("missing fields")
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // resize image before uploading
        let resizeImage = UIImage.resizeImage(originalImage: selectedImage, rect: profileImage.bounds)
        
        print("\(resizeImage)")
        
        storageService.uploadPhoto(userId: user.uid, image: resizeImage) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error updating", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                
                self?.updateDataBaseUser(displayName: displayName, photoURL: url.absoluteString)
                
                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                
                request?.displayName = displayName
                
                request?.photoURL = url
                
                request?.commitChanges(completion: { [unowned self] (error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Error", message: "Couldnt commit changes: \(error.localizedDescription)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Success", message: "Changes commited")
                        }
                    }
                })
            }
        }
    }
    
    private func updateDataBaseUser(displayName: String, photoURL: String) {
        DatabaseServices.shared.updateDataBaseUser(displayName: displayName, photoURL: photoURL) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(_):
                print("success")
            }
        }
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
        do {
            try Auth.auth().signOut()
            UIViewController.showVC(storyboard: "LoginView", VCid: "LoginViewController")
        } catch {
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Couldnt signout \(error.localizedDescription)")
            }
        }
    }
    
    
    @IBAction func segmentedPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewState = .myItems
        case 1:
            viewState = .myFav
        default:
            break
        }
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

extension ProfileVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewState == .myItems {
            return myItems.count
        } else {
            return myFav.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError()
        }
        if viewState == .myItems {
            let aItem = myItems[indexPath.row]
            cell.configureCell(item: aItem)
        } else {
            let aFav = myFav[indexPath.row]
            cell.configureCell(for: aFav)
        }
        return cell
    }
}

extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
