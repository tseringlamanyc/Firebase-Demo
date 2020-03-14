//
//  SellerVC.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/14/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

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
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
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
