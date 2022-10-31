//
//  FavoriteViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import UIKit
import ProgressHUD
import NSObject_Rx


class FavoriteViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Vars
    private let viewModel = FavoriteViewModel()
    var favCatList = [FavoriteCat]()

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFavImages()
        bindUI()
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getFavImages()
    }
    
    
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
    
    private func fetchFavImages() {
        viewModel.fetchFavImages()
    }
    
    
    private func getFavImages() {
        Network.shared.fetchFavoriteImages { [weak self] (data) in
            guard let self = self else { return }
            
            do {
                let result = try JSONDecoder().decode([FavoriteCat].self, from: data)
                self.favCatList = result
                self.collectionView.reloadData()
            } catch {
                #if DEBUG
                print(error)
                #endif
            }
        }
    }
}




// MARK: - UICollectionView DataSource

//extension FavoriteViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return favCatList.count
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCollectionViewCell", for: indexPath) as! FavoriteCollectionViewCell
//
//        let target = favCatList[indexPath.item]
//        guard let urlStr = target.image.url else { return UICollectionViewCell() }
//        let url = URL(string: urlStr)
//        cell.imageView.kf.setImage(with: url)
//
//        return cell
//    }
//}




// MARK: - UICollectionView Delegate

extension FavoriteViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        alert(title: "알림", message: "해당 이미지를 삭제하시겠습니까?") { [weak self] _ in
            guard let self = self else { return }
            let target = self.favCatList[indexPath.item]
            guard let catId = target.id else { return }
            
            Network.shared.deleteFavoriteImage(imageId: catId) {
                self.favCatList.remove(at: indexPath.item)
                self.collectionView.deleteItems(at: [indexPath])
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
