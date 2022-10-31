//
//  UploadViewModel.swift
//  MyCat
//
//  Created by Chris Kim on 10/31/22.
//

import NSObject_Rx
import ProgressHUD
import Alamofire
import RxCocoa
import RxSwift
import UIKit


class UploadViewModel {
    
    // MARK: - Upload Action
    enum UploadAction {
        case upload(_ imageData: Data)
        case fetch
    }
    
    // MARK: - Inputs
    let selectedImageSubject = PublishSubject<Cat>()
    let imageActionSubject = PublishSubject<UploadAction>()
    
    // MARK: - Outputs
    var uploadedCatListSubject = BehaviorSubject<[Cat]>(value: [])
    
    // MARK: - Vars
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    init() {
        fetchUploadedImages()
        uploadImage()
    }
    
    
    /// Fetch Uploaded Cat Images
    fileprivate func fetchUploadedImages() {
        Network.shared.fetchUploadedImages()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                do {
                    let result = try JSONDecoder().decode([Cat].self, from: $0)
                    self.uploadedCatListSubject.onNext(result)
                } catch {
                    ProgressHUD.showFailed("Cannot load Uploaded Cat images. Please try later.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    fileprivate func uploadImage() {
        
    }
}
