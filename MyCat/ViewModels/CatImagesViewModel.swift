//
//  CatImagesViewModel.swift
//  MyCat
//
//  Created by Chris Kim on 10/24/22.
//

import ProgressHUD
import RxAlamofire
import Foundation
import RxSwift
import RxCocoa
import UIKit


class CatImagesViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Inputs from ViewController
    // 즐겨찾기선택한 이미지
    let selectedImageSubject = PublishSubject<Cat>()
    // 삭제할 이미지
    // 업로드할 이미지
    
    
    // MARK: - Outputs to ViewController
    // 고양이 이미지 배열
    var catImagesSubject = BehaviorSubject<[Cat]>(value: [])
    // 즐겨찾기한 이미지 배열
    // 업로드한 이미지 배열
    
    
    init() {
        
    }
    
    
    func fetchCatImage(page: Int) {
        Network.shared.fetchCatImages(page: page)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                do {
                    let result = try JSONDecoder().decode([Cat].self, from: $0)
                    self.catImagesSubject.onNext(result)
                } catch {
                    ProgressHUD.showFailed("Cannot load Cat images. Please try later.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    func uploadFavImage(imageId: String) {
        Network.shared.uploadFavoriteImage(imageId: imageId)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print(#fileID, #function, #line, "-uploadFavImage: \($0)")
            })
            .disposed(by: disposeBag)
    }
    
    
    
    
}
