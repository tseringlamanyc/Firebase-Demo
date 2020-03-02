//
//  VC + Navigation .swift
//  Firebase-Demo
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public static func resetWindow (rootVC: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first, let sceneDelegate = scene.delegate as? SceneDelegate, let window = sceneDelegate.window else {
            fatalError("couldnt set window")
        }
        window.rootViewController = rootVC
    }
    
    public static func showVC(storyboard: String, VCid: String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let newVC = storyboard.instantiateViewController(identifier: VCid)
        resetWindow(rootVC: newVC)
    }
}
