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
    
    
    // MARK: - IBActions
    
    @IBAction func selectFavorite(_ sender: Any) {
        print(#function)
        alert(title: "알림", message: "즐겨찾기에 추가하시겠습니까?") { _ in
            #warning("Todo: - 즐겨찾기에 해당 Cat 추가하기")
        }
    }
    
    
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
        getRandomPic(page: 1)
        #warning("Todo: - 새로고침하면 새로운 데이터를 불러올 것")
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
        
        Network.shared.getRandomCatImages(page: self.page) { data in
            do {
                let res = try JSONDecoder().decode([Cat].self, from: data)
                self.catList.append(contentsOf: res)
                self.imageCollectionView.reloadData()
            } catch {
                #if DEBUG
                print(error)
                #endif
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
        cell.catImageView.kf.setImage(with: url)
        
        return cell
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
