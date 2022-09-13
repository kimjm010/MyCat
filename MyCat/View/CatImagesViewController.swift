//
//  CatImagesViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import UIKit
import Alamofire

class CatImagesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    
    // MARK: - Vars
    
    var catList = [Cat]()
    
    private var refreshControl = UIRefreshControl()

    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.refreshControl = refreshControl
        imageCollectionView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
      getRandomPic()
    }
    
    // MARK: - Refresh Collection View
    
    @objc
    /// 당겨서 imageCollectionView를 새로고침
    /// - Parameter sender: CatImagesViewController
    private func pullToRefresh(_ sender: Any) {
        getRandomPic()
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
    
    private func getRandomPic() {

        Network.shared.getRandomCatImages { data in
            do {
                let res = try JSONDecoder().decode([Cat].self, from: data)
                self.catList.append(contentsOf: res)
                print(self.catList.count)
                
                DispatchQueue.main.async {
                    self.imageCollectionView.reloadData()
                }
                
            } catch {
                print(error)
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
        let data = NSData(contentsOf: NSURL(string: target.url!)! as URL)
        var image: UIImage?
        if (data != nil) {
            image = UIImage(data: data! as Data)
            cell.catImageView.image = image
        }
        
        return cell
    }
}




// MARK: - UICollectionView Delegate
extension CatImagesViewController: UICollectionViewDelegate {
    
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



extension CatImagesViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(#function)
        
        guard indexPaths.contains(where: { $0.row >= self.catList.count - 10 }) else { return }
        
        getRandomPic()
    }
    
    
}
