//
//  UIViewController+RxAlert.swift
//  MyCat
//
//  Created by Chris Kim on 10/28/22.
//

import Foundation
import RxSwift


enum AlertActionType {
    case ok
    case cancel
}


extension UIViewController {
    
    /// Show AlertController
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    /// - Returns: AlertActionType Observable
    func alertToUser(title: String? = nil, message: String? = nil) -> Observable<AlertActionType> {
        return Observable.create{ (observer) in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Add", style: .default) { _ in
                observer.onNext(.ok)
                observer.onCompleted()
            }
            alert.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    /// Show Delete AlertController
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    /// - Returns: AlertActionType Observable
    func alertDeleteToUser(title: String? = nil, message: String? = nil) -> Observable<AlertActionType> {
        return Observable.create{ (observer) in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Delete", style: .default) { _ in
                observer.onNext(.ok)
                observer.onCompleted()
            }
            alert.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
