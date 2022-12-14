//
//  CatImagesViewModel.swift
//  MyCat
//
//  Created by Chris Kim on 10/24/22.
//

import ProgressHUD
import RxSwift
import RxCocoa


class CatImagesViewModel {
    
    // MARK: - Outputs to ViewController
    var catImagesSubject = BehaviorSubject<[Cat]>(value: [])
    
    // MARK: - Vars
    private let disposeBag = DisposeBag()
    
    
    /// Fetch cat images
    /// - Parameter page: page value
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
    
    
    /// Refresh Cat Images
    func refreshCatImages() {
        Network.shared.fetchCatImages(page: 1)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                do {
                    let result = try JSONDecoder().decode([Cat].self, from: $0)
                    self.catImagesSubject.onNext(result)
                } catch {
                    ProgressHUD.showFailed("Cannot refresh Cat images. Please try later.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    /// Upload cat image to faovirte folder
    /// - Parameter imageId: selected imageId
    func uploadFavImage(imageId: String) {
        Network.shared.uploadFavoriteImage(imageId: imageId)
            .subscribe(onNext: { _ in })
            .disposed(by: disposeBag)
    }
}
