//
//  UploadViewModel.swift
//  MyCat
//
//  Created by Chris Kim on 10/31/22.
//

import ProgressHUD
import RxCocoa
import RxSwift


class UploadViewModel {
    
    // MARK: - Upload Action
    enum ImageAction {
        case delete(_ imageId: String)
    }
    
    // MARK: - Inputs
    let imageActionSubject = PublishSubject<ImageAction>()
    
    // MARK: - Outputs
    var uploadedCatListSubject = BehaviorSubject<[Cat]>(value: [])
    
    // MARK: - Vars
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    init() {
        fetchUploadedImages()
        
        imageActionSubject
            .bind(onNext: handleUploadAction(_:))
            .disposed(by: disposeBag)
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
    
    
    /// Handle upload action
    /// - Parameter action: UploadAction
    fileprivate func handleUploadAction(_ action: ImageAction) {
        switch action {
        case .delete(let imageId):
            deleteImage(imageId: imageId)
        }
    }
    
    
    /// Delete Cat Image
    /// - Parameter imageId: image Id
    fileprivate func deleteImage(imageId: String) {
        Network.shared.deleteCatImage(imageId: imageId)
            .subscribe(onNext: { 
                print(#fileID, #function, #line, "-deleteFavCatImage \(imageId) \($0)")
            })
            .disposed(by: disposeBag)
    }
}
