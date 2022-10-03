//
//  UIVIewController+Alert.swift
//  MyCat
//
//  Created by Chris Kim on 9/14/22.
//

import Foundation
import UIKit



extension UIViewController {
    
    func alert(title: String, message: String, okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: okHandler)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func alertNoImage(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        
        
        present(alert, animated: true, completion: nil)
    }
}
