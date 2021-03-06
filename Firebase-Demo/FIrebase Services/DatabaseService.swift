//
//  DatabaseService.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseServices {
    
    static let itemsCollection = "items" // collection
    static let userCollection = "users"
    static let commentsCollection = "comments"  // sub collection on items
    static let favCollection = "favorites" // sub collection on users
    
    // Collection -> documents -> collection -> documents
    
    // Need a reference to the firebase firestore
    private let db = Firestore.firestore()
    
    private init() {}
    static let shared = DatabaseServices()
    
    public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<String, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {return}
        
        // generate document(collection) id
        let document = db.collection(DatabaseServices.itemsCollection).document() // document in the collection, autogenerated ID
        
        // create a document in items collection
        db.collection(DatabaseServices.itemsCollection).document(document.documentID).setData(["itemName" : itemName, "price": price, "itemId": document.documentID, "listedDate": Timestamp(date: Date()), "sellerName": displayName, "sellerId": user.uid, "category": category.name]) { (error) in
            if let error = error {
                print("error creating item: \(error)")
                completion(.failure(error))
            } else {
                print("item was created \(document.documentID)")
                completion(.success(document.documentID))
            }
        }
    }
    
    public func createDataBaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let email = authDataResult.user.email else {
            return
        }
        
        db.collection(DatabaseServices.userCollection).document(authDataResult.user.uid).setData(
            ["email" : email,
             "createdDate": Date(),
             "userId": authDataResult.user.uid]) { (error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
        }
    }
    
    public func updateDataBaseUser(displayName: String, photoURL: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        db.collection(DatabaseServices.userCollection).document(user.uid).updateData(["photoURL" : photoURL, "displayName": displayName]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func deleteItem(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        db.collection(DatabaseServices.itemsCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func postComment(comment: String, item: Item,completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser, let displayName = user.displayName else {
            print("missing username")
            return
        }
        
        let docRef = db.collection(DatabaseServices.itemsCollection).document(item.itemId).collection(DatabaseServices.commentsCollection).document()
        db.collection(DatabaseServices.itemsCollection).document(item.itemId).collection(DatabaseServices.commentsCollection).document(docRef.documentID).setData([
            "comment" : comment,
            "commentDate": Timestamp(date: Date()),
            "itemName": item.itemName,
            "itemId": item.itemId,
            "sellerName": item.sellerName,
            "commentedBy": displayName])
        { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func addToFav(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        db.collection(DatabaseServices.userCollection).document(user.uid).collection(DatabaseServices.favCollection).document(item.itemId).setData(
            ["itemName" : item.itemName,
             "price": item.price,
             "imageURL": item.imageURL,
             "favoritedDate": Timestamp(date: Date()),
             "itemId": item.itemId,
             "sellerName": item.sellerName,
             "sellerId": item.sellerId]) { (error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
        }
    }
    
    public func removeFav(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        db.collection(DatabaseServices.userCollection).document(user.uid).collection(DatabaseServices.favCollection).document(item.itemId).delete() { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func isFav(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // "where" to search / query collection
        // addsnapshot - continues to listen
        // getDocuments - only once
        db.collection(DatabaseServices.userCollection).document(user.uid).collection(DatabaseServices.favCollection).whereField("itemId", isEqualTo: item.itemId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let count = snapshot.documents.count
                if count > 0 {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            }
        }
    }
    
    public func fetchUserItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        
        db.collection(DatabaseServices.itemsCollection).whereField("sellerId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let items = snapshot.documents.map {Item(dictonary: $0.data())}
                completion(.success(items))
            }
        }
    }
    
    public func fetchUsersFav(completion: @escaping (Result<[Favorite], Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        db.collection(DatabaseServices.userCollection).document(user.uid).collection(DatabaseServices.favCollection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let favorites = snapshot.documents.compactMap {Favorite(dictionary: $0.data())}
                    completion(.success(favorites))
                }
            }
        }
    }
}
