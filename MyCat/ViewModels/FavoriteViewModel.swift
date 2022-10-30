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
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Inputs
    
    
    // MARK: - Outputs
    var favoriteCatListSubject = BehaviorSubject<[FavoriteCat]>(value: [])
    
    
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
    
    
    func deleteFavCatImage() {
    
    }
}
