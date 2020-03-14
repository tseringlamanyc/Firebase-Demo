//
//  SellerVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/14/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SellerVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var item: Item
    
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        fetchItems()
        getUserPhoto()
    }
    
    private func fetchItems() {
        DatabaseServices.shared.fetchUserItems(userId: item.sellerId) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail to get", message: "\(error.localizedDescription)")
                }
            case .success(let items):
                self?.items = items
            }
        }
    }
    
    private func getUserPhoto() {
        Firestore.firestore().collection(DatabaseServices.userCollection).document(item.sellerId).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail", message: error.localizedDescription)
                }
            } else if let snapshot = snapshot {
                if let imageURL = snapshot.data()?["photoURL"] as? String {
                    DispatchQueue.main.async {
                        self?.tableView.tableHeaderView = HeaderView(imageURL: imageURL)
                    }
                }
            }
        }
    }
}

extension SellerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError()
        }
        let aItem = items[indexPath.row]
        cell.configureCell(item: aItem)
        return cell
    }
}

extension SellerVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
