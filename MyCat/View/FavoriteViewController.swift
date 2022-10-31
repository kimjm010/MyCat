//
//  FavoriteViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import UIKit
import ProgressHUD
import NSObject_Rx
import RxSwift
import RxCocoa


class FavoriteViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Vars
    private let viewModel = FavoriteViewModel()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        controlCollectionViewEvent()
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    
    /// Bind ViewModel to ViewController
    private func bindUI() {
        viewModel.favoriteCatListSubject
            .bind(to: collectionView.rx.items(cellIdentifier: FavoriteCollectionViewCell.identifier, cellType: FavoriteCollectionViewCell.self)) { (row, favoriteCat, cell) in
                guard let urlStr = favoriteCat.image.url else { return }
                let url = URL(string: urlStr)
                cell.imageView.kf.setImage(with: url,
                                           placeholder: UIImage(named: "zoo"),
                                           options: [.transition(.fade(0.3))])
            }
            .disposed(by: rx.disposeBag)
    }
    
    
    /// Control CollectionView Select Event
    private func controlCollectionViewEvent() {
        collectionView.rx.modelSelected(FavoriteCat.self)
            .subscribe(onNext: { [weak self] (favoriteCat) in
                guard let self = self else { return }
                self.viewModel.selectedImageSubject.onNext(favoriteCat)
                self.alertDeleteToUser(title: "Alert",
                                       message: "Do you want to delete selected favorite image?")
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    switch $0 {
                    case .ok:
                        guard let favoriteCatId = favoriteCat.id else { return }
                        self.viewModel.imageActionSubject.onNext(.delete(favoriteCatId))
                        ProgressHUD.showSuccess("Complete to delete selected image!")
                        #warning("Todo: - 삭제 후 컬렉션뷰 리로드")
                        //self.collectionView.reloadData()
                    default:
                        break
                    }
                })
                .disposed(by: self.rx.disposeBag)
            })
            .disposed(by: rx.disposeBag)
    }
}




// MARK: - UICollectionView Delegate FlowLayout
extension FavoriteViewController: UICollectionViewDelegateFlowLayout {
    
    /// Set  CollectionView Cell Size
    /// - Parameters:
    ///   - collectionView: CollectionView
    ///   - collectionViewLayout: CollectionView layout object
    ///   - indexPath: CollectionView's indexPath
    /// - Returns: CGSize of CollectionView Cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let bounds = collectionView.bounds
        var width = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
        width = (width - layout.minimumInteritemSpacing) / 2
        return CGSize(width: width, height: 100)
    }
}
