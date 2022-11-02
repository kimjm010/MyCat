//
//  SelectImageViewModel.swift
//  MyCat
//
//  Created by Chris Kim on 11/2/22.
//

import ProgressHUD
import RxCocoa
import RxSwift


class SelectImageViewModel {
    
    // MARK: - Select Image Action
    enum SelectImageAction {
        case upload(_ imageData: Data)
    }
    
    // MARK: - Inputs
    let selectImageActionSubject = PublishSubject<SelectImageAction>()
    
    // MARK: - Vars
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    init() {
        selectImageActionSubject
            .bind(onNext: handleSelectImageAction(_:))
            .disposed(by: disposeBag)
    }
    
    
    /// Handle Select Image Action
    /// - Parameter action: Select Image Action
    fileprivate func handleSelectImageAction(_ action: SelectImageAction) {
        switch action {
        case .upload(let imageData):
            uploadImage(imageData: imageData)
        }
    }
    
    
    /// Upload cat image
    /// - Parameter imageData: Cat image data
    fileprivate func uploadImage(imageData: Data) {
        Network.shared.uploadCatImage(imageData: imageData)
            .debug()
            .subscribe(onNext: { _  in })
            .disposed(by: self.disposeBag)
    }
}
