//
//  DetailVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var item: Item
    
    private var listener: ListenerRegistration?
    
    private var originalBottomValue: CGFloat = 0
    
    private var comments = [Comment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var isFavorite = false {
        didSet {
            if isFavorite {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            } else {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            }
        }
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tp = UITapGestureRecognizer()
        tp.addTarget(self, action: #selector(dismissKeyboard))
        return tp
    }()
    
    init?(coder: NSCoder, item: Item) {
        self.item = item 
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = item.itemName
        commentTF.delegate = self
        tableView.dataSource = self
        
        // custom view for the table view
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
        originalBottomValue = bottomConstraint.constant
        view.addGestureRecognizer(tapGesture)
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        registerKeyboardNotification()
        
        listener = Firestore.firestore().collection(DatabaseServices.itemsCollection).document(item.itemId).collection(DatabaseServices.commentsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail", message: "\(error.localizedDescription)")
                }
                
            } else if let snapshot = snapshot {
                let comments = snapshot.documents.map { Comment(dictonary: $0.data()) }
                self?.comments = comments.sorted {$0.commentDate.dateValue() > $1.commentDate.dateValue() } // new on top
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotification()
        listener?.remove()
    }
    
    private func updateUI() {
        // check if item is favorited
        DatabaseServices.shared.isFav(item: item) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try again", message: "\(error.localizedDescription)")
                }
            case .success(let success):
                if success {
                    self?.isFavorite = true
                } else {
                    self?.isFavorite = false
                }
            }
        }
    }
    
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
            return
        }
        bottomConstraint.constant = -(keyboardFrame.height - view.safeAreaInsets.bottom)
    }
    
    @objc
    private func keyboardWillHide(notification: Notification) {
        dismissKeyboard()
    }
    
    @objc
    private func dismissKeyboard() {
        bottomConstraint.constant = originalBottomValue
        commentTF.resignFirstResponder()
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        
        dismissKeyboard()
        
        guard let comment = commentTF.text, !comment.isEmpty else {
            showAlert(title: "Missing", message: "Need comment")
            return
        }
        
        postComment(text: comment)
    }
    
    private func postComment(text: String) {
        DatabaseServices.shared.postComment(comment: text, item: item) { [weak self] (result) in
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail", message: "Couldnt add comment")
                }
            case .success(_):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Success", message: "Comment posted")
                }
            }
        }
    }
    
    
    @IBAction func favPressed(_ sender: UIBarButtonItem) {
        
        if isFavorite {  // already fav
            DatabaseServices.shared.removeFav(item: item) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Fail", message: "Couldnt favorite: \(error.localizedDescription)")
                    }
                case .success(_):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Success", message: "item removed")
                        self?.isFavorite = false 
                    }
                }
            }
        } else {  // not in fav
            DatabaseServices.shared.addToFav(item: item) { [weak self](result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Fail", message: "Couldnt favorite: \(error.localizedDescription)")
                    }
                case .success(_):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Success", message: nil)
                        self?.isFavorite = true
                    }
                }
            }
        }
        
    }
}

extension DetailVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let aComment = comments[indexPath.row]
        let dateString = aComment.commentDate.dateValue().dateString()
        cell.textLabel?.text = aComment.comment
        cell.detailTextLabel?.text = aComment.commentedBy + " " + dateString
        return cell
    }
}

extension DetailVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
