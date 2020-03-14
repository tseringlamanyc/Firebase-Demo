//
//  ItemFeedVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ItemFeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    
    private let storageService = StorageServices()
    
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
        tableView.delegate = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError()
        }
        let aItem = items[indexPath.row]
        cell.configureCell(item: aItem)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            // Create a reference to the file to delete
            let item = items[indexPath.row]
            DatabaseServices.shared.deleteItem(item: item) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error", message: "Couldnt delete \(error.localizedDescription)")
                    }
                case .success(_):
                    print("deleted yerrr......")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.row]
        
        guard let user = Auth.auth().currentUser else {return false}
        
        if item.sellerId != user.uid {
            return false
        } else {
            return true
        }
    }
}

extension ItemFeedVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "MainView", bundle: nil)
        let item = items[indexPath.row]
        let detailVC = storyboard.instantiateViewController(identifier: "DetailVC") { (coder)  in
            return DetailVC(coder: coder, item: item)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension ItemFeedVC: ItemCellDelegate {
    
    func didTapName(itemCell: ItemCell, item: Item) {
        print("")
    }
}
