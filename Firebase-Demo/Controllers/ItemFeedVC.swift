//
//  ItemFeedVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemFeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // snapshot completion handler,, automatic updates // .addSnapshotListener
        // .getDocuments for one time update ,, not live
        listener = Firestore.firestore().collection(DatabaseServices.itemsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Firestore Error", message: "Coudlnt recieve data: \(error.localizedDescription)")
                }
            } else if let snapshot = snapshot {
                let items = snapshot.documents.map {Item(dictonary: $0.data())}
                self?.items = items
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove()
    }
}

extension ItemFeedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let aItem = items[indexPath.row]
        cell.textLabel?.text = aItem.itemName
        let price = String(format: "%.2f", aItem.price)
        cell.detailTextLabel?.text = "@\(aItem.sellerName) price: $\(price)"
        return cell
    }
}
