//
//  FavoriteViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import UIKit
import ProgressHUD


class FavoriteViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - Vars
    
    var catList = [FavoriteCat]()
    

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getFavImages()
    }
    
    
    private func getFavImages() {
        Network.shared.fetchFavoriteImages { [weak self] (data) in
            guard let self = self else { return }
            
            do {
                let result = try JSONDecoder().decode([FavoriteCat].self, from: data)
                self.catList = result
                print(self.catList.count)
                self.collectionView.reloadData()
            } catch {
                #if DEBUG
                print(error, "^^")
                #endif
            }
        }
    }
}




// MARK: - UICollectionView DataSource

extension FavoriteViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCollectionViewCell", for: indexPath) as! FavoriteCollectionViewCell
        
        let target = catList[indexPath.item]
        guard let urlStr = target.image.url else { return UICollectionViewCell() }
        let url = URL(string: urlStr)
        cell.imageView.kf.setImage(with: url)
        
        return cell
    }
}




// MARK: - UICollectionView Delegate

extension FavoriteViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        alert(title: "알림", message: "해당 이미지를 삭제하시겠습니까?") { [weak self] _ in
            #warning("Todo: - 삭제기능 구현")
            guard let self = self else { return }
            print(#function)
            
            let target = self.catList[indexPath.item]
            guard let catId = target.id else { return }
            let strCatId = String(catId)
            
            
            Network.shared.deleteMyCatImage(imageId: strCatId) {  (data) in
                self.collectionView.reloadData()
            }
            
            ProgressHUD.showSuccess("이미지 삭제 완료")
        }
        
    }
}




// MARK: - UICollectionView Delegate FlowLayout

extension FavoriteViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let bounds = collectionView.bounds
        var width = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
        width = (width - layout.minimumInteritemSpacing) / 2
        return CGSize(width: width, height: 100)
    }
}
