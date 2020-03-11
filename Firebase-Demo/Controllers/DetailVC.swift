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
    
    private var item: Item
    
    private let db = DatabaseServices()
    
    private var listener: ListenerRegistration?
    
    private var comments = [Comment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
       let tp = UITapGestureRecognizer()
//        tp.addTarget(self, action: <#T##Selector#>)
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
        tableView.dataSource = self
        // custom view for the table view
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listener = Firestore.firestore().collection(DatabaseServices.itemsCollection).document(item.itemId).collection(DatabaseServices.commentsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail", message: "\(error.localizedDescription)")
                }
            } else if let snapshot = snapshot {
                let comments = snapshot.documents.map { Comment(dictonary: $0.data()) }
                self?.comments = comments.sorted {$0.commentDate.dateValue() < $1.commentDate.dateValue() }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove()
    }
    
    
    @IBAction func sendButton(_ sender: UIButton) {
        
        guard let comment = commentTF.text, !comment.isEmpty else {
            showAlert(title: "Missing", message: "Need comment")
            return
        }
        postComment(text: comment)
    }
    
    private func postComment(text: String) {
        db.postComment(comment: text, item: item) { [weak self] (result) in
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
    
}

extension DetailVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let aComment = comments[indexPath.row]
        cell.textLabel?.text = aComment.comment
        cell.detailTextLabel?.text = aComment.commentedBy
        return cell
    }
}
