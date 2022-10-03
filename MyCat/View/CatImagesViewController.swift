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


class CatImagesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    
    // MARK: - Vars
    
    var catList = [Cat]()
    
    var page = 0
    
    private var refreshControl = UIRefreshControl()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.refreshControl = refreshControl
        imageCollectionView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        getRandomPic(page: page)
    }
    
    
    // MARK: - Refresh Collection View
    
    @objc
    /// 당겨서 imageCollectionView를 새로고침
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
    
    
    // MARK: - End RefreshControl Refreshin
    /// Refresh Control 동작을 멈춤
    /// - Parameters:
    ///   - scrollView: imageCollectionView
    ///   - decelerate: scrolling을 계속 할 것인지 여부
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (refreshControl.isRefreshing) {
            refreshControl.endRefreshing()
        }
    }
    
    
    // MARK: - Fetch Cat Image
    
    private func getRandomPic(page: Int) {
        self.page += 1
        
        Network.shared.fetchRandomCatImages(page: self.page) { [weak self] (data) in
            guard let self = self else { return }
            
            do {
                let res = try JSONDecoder().decode([Cat].self, from: data)
                self.catList.append(contentsOf: res)
                self.imageCollectionView.reloadData()
            } catch {
                ProgressHUD.showFailed("Cannot load Cat images. Please try later.")
            }
        }
    }
}




// MARK: - UICollectionView DataSource

extension CatImagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        
        let target = catList[indexPath.item]
        guard let urlStr = target.url else { return UICollectionViewCell() }
        let url = URL(string: urlStr)
        cell.catImageView.kf.setImage(with: url,
                                      placeholder: UIImage(named: "zoo"),
                                      options: [.transition(.fade(0.3))])
        return cell
    }
}




extension CatImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        alert(title: "알림", message: "즐겨찾기에 추가하시겠습니까?") { [weak self] _ in
            guard let self = self else { return }
            
            let target = self.catList[indexPath.item]
            guard let catId = target.id else { return }
            Network.shared.postFavoriteImage(imageId: catId) { _ in }
            ProgressHUD.showSuccess("즐겨찾기 추가 성공")
        }
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
        
        getRandomPic(page: page)
    }
}
