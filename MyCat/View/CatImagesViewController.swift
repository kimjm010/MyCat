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
import RxCocoa
import RxSwift


class CatImagesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    
    // MARK: - Vars
    private let viewModel = CatImagesViewModel()
    private let disposeBag = DisposeBag()
    
    var catList = [Cat]()
    
    var page = 0
    
    private var refreshControl = UIRefreshControl()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCatImages(page: page)
        
        imageCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        bindUI()
        controllCollectionViewEvent()
        
        imageCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
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
            .disposed(by: disposeBag)
    }
    
    
    /// Control ImageCollectionView Select Event
    /// Ask whether add to favorite folder
    private func controllCollectionViewEvent() {
        imageCollectionView.rx.modelSelected(Cat.self)
            .subscribe(onNext: { [weak self] (cat) in
                guard let self = self else { return }
                self.viewModel.selectedImageSubject.onNext(cat)
                self.alertToUser(title: "Alert", message: "Do you want to add in favorite image folder?")
                    .subscribe(onNext: {
                        switch $0 {
                        case .ok:
                           
                            #warning("Todo: - 이미지 추가 -> ViewModel에서 추가하는 로직 작성")
                            if let catId = cat.id {
                                self.viewModel.uploadFavImage(imageId: catId)
                                print(#fileID, #function, #line, "- uploadFavImage: \(cat.id) \(cat.url)")
                            }
                        default:
                            break
                        }
                    })
                    .disposed(by: self.disposeBag)
                print(#fileID, #function, #line, "- \(cat)")
            })
            .disposed(by: disposeBag)
    }
    
    
    @objc
    /// 당겨서 imageCollectionView를 새로고침
    ///
    /// - Parameter sender: CatImagesViewController
    private func pullToRefresh(_ sender: Any) {
        Network.shared.fetchRandomCatImages(page: 1) { [weak self] (data) in
            guard let self = self else { return }
            
            do {
                let result = try JSONDecoder().decode([Cat].self, from: data)
                self.catList = result
                self.imageCollectionView.reloadData()
            } catch {
                ProgressHUD.showFailed("Cannot reload Cat images. Please try later.")
            }
        }
        
    }
    
    
    /// Refresh Control 동작을 멈춤
    ///
    /// - Parameters:
    ///   - scrollView: imageCollectionView
    ///   - decelerate: scrolling을 계속 할 것인지 여부
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (refreshControl.isRefreshing) {
            refreshControl.endRefreshing()
        }
    }
    
    
    /// Fetch Cat Random Image
    /// - Parameter page: page of images
    private func fetchCatImages(page: Int) {
        self.page += 1
        viewModel.fetchCatImage(page: self.page)
    }
    
    
    /// Upload Image to Favorite folder
    /// - Parameter imageId: selected imageId
    private func uploadFavImage(imageId: String) {
        viewModel.uploadFavImage(imageId: imageId)
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




// MARK: - UICollectionView DataSource Prefetching

extension CatImagesViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        guard indexPaths.contains(where: { $0.row >= self.catList.count - 8 }) else { return }
        
//        getRandomPic(page: page)
        #warning("Todo: - 이미지 가져오기")
    }
}
