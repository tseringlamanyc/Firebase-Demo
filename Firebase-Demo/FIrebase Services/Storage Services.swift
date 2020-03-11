//
//  Storage Services.swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageServices {
    // 2 photos: profileVC and createitemVC
    // 2 buckets: userphotos, itemsphotos
    // reference to firebasestorage
    
    private let storageRef = Storage.storage().reference()
    
    public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping(Result<URL, Error>) -> ()) {
        
        // convert UIImage to data to store it to firebase
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // need to decide which bucket to save into
        var photoReference: StorageReference!
        
        if let userId = userId {
            photoReference = storageRef.child("UserProfilePhotos/\(userId).jpg")
        } else if let itemId = itemId {
            photoReference = storageRef.child("ItemPhotos/\(itemId).jpg")
        }
        
        // configure metadata for the object being uploaded
        let metadata = StorageMetadata()  // download url
        
        metadata.contentType = "image/jpg"  // MIME type  "video/mp4"
        
        let _ = photoReference.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else if let _ = metadata {
                photoReference.downloadURL { (url, error) in   // attach to user or item 
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    }
                }
            }
        } // request object
    }
}
