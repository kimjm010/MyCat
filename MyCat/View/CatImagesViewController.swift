//
//  CatImagesViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import UIKit
import Alamofire
import Kingfisher
import ProgressHUD
import NSObject_Rx
import RxCocoa
import RxSwift


class CatImagesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    // MARK: - Vars
    private let viewModel = CatImagesViewModel()
    private var refreshControl = UIRefreshControl()
    var page = 0
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCatImages(page: page)
        
        imageCollectionView.refreshControl = refreshControl

        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print(#fileID, #function, #line, "- valueChanged: \($0)")
                self.viewModel.refreshCatImages()
            })
            .disposed(by: rx.disposeBag)
        
        #warning("Todo: - Prefetch시 계속 바뀌지 않고 데이터가 누적되도록 하려면 어떻게 할까??")
        imageCollectionView.rx.prefetchItems
            .map { $0.map { $0.count} }
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print(#fileID, #function, #line, "- \($0)")
                if $0.count <= 6 {
                    self.fetchCatImages(page: self.page)
                }
            })
            .disposed(by: rx.disposeBag)
        
        bindUI()
        controllCollectionViewEvent()
        
        imageCollectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    
    /// Bind ViewModel to ImageCollectionView
    private func bindUI() {
        viewModel.catImagesSubject
            .bind(to: imageCollectionView.rx.items(cellIdentifier: ImagesCollectionViewCell.identifier, cellType: ImagesCollectionViewCell.self)) { (row, cat, cell) in
                guard let urlStr = cat.url else { return }
                let url = URL(string: urlStr)
                cell.catImageView.kf.setImage(with: url,
                                              placeholder: UIImage(named: "zoo"),
                                              options: [.transition(.fade(0.3))])
            }
            .disposed(by: rx.disposeBag)
    }
    
    
    /// Control ImageCollectionView Select Event
    /// Ask whether add to favorite folder
    private func controllCollectionViewEvent() {
        imageCollectionView.rx.modelSelected(Cat.self)
            .subscribe(onNext: { [weak self] (cat) in
                guard let self = self else { return }
                self.viewModel.selectedImageSubject.onNext(cat)
                self.alertToUser(title: "Alert",
                                 message: "Do you want to add in favorite image folder?")
                    .subscribe(onNext: {
                        switch $0 {
                        case .ok:
                            if let catId = cat.id {
                                self.viewModel.uploadFavImage(imageId: catId)
                            }
                        default:
                            break
                        }
                    })
                    .disposed(by: self.rx.disposeBag)
                print(#fileID, #function, #line, "- \(cat)")
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    /// Fetch Cat Random Image
    /// - Parameter page: page of images
    private func fetchCatImages(page: Int) {
        self.page += 1
        viewModel.fetchCatImage(page: self.page)
    }
}




// MARK: - UICollectionView Delegate FlowLayout
extension CatImagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let bounds = collectionView.bounds
        var width = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
        width = (width - layout.minimumInteritemSpacing) / 2
        return CGSize(width: width, height: 100)
    }
}
