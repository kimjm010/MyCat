//
//  FavoriteViewModel.swift
//  MyCat
//
//  Created by Chris Kim on 10/30/22.
//

import NSObject_Rx
import ProgressHUD
import Kingfisher
import Alamofire
import RxCocoa
import RxSwift
import UIKit


class FavoriteViewModel {
    
    // Favorite ViewModel Actions
    enum FavoriteAction {
        case delete(_ imageId: Int)
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Inputs
    let selectedImageSubject = PublishSubject<FavoriteCat>()
    let imageActionSubject = PublishSubject<FavoriteAction>()
    
    // MARK: - Outputs
    var favoriteCatListSubject = BehaviorSubject<[FavoriteCat]>(value: [])
    
    init() {
        imageActionSubject
            .bind(onNext: handleFavoriteAction(_:))
            .disposed(by: disposeBag)
    }
    
    
    /// Fetch Favorite Cat Images
    func fetchFavImages() {
        Network.shared.fetchFavImages()
            .subscribe { [weak self] in
                guard let self = self else { return }
                
                do {
                    let result = try JSONDecoder().decode([FavoriteCat].self, from: $0)
                    self.favoriteCatListSubject.onNext(result)
                } catch {
                    ProgressHUD.showFailed("Cannot load Favorite Cat images. Please try later.")
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    /// Handle Favorite Action
    /// - Parameter action: FavoriteAction
    fileprivate func handleFavoriteAction(_ action: FavoriteAction) {
        switch action {
        case .delete(let imageId):
            deleteFavCatImage(imageId: imageId)
        }
    }
    
    
    /// Delete favorite image
    /// - Parameter imageId: image Id
    fileprivate func deleteFavCatImage(imageId: Int) {
        Network.shared.deleteFavImage(imageId: imageId)
            .subscribe {
                print(#fileID, #function, #line, "-deleteFavCatImage \(imageId) \($0)")
            }
            .disposed(by: disposeBag)
    }
}
