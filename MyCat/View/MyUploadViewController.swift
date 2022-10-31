//
//  MyUploadViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import UIKit
import ProgressHUD
import RxSwift
import RxCocoa
import NSObject_Rx
import Kingfisher


class MyUploadViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Vars
    private let viewModel = UploadViewModel()
    var catList = [Cat]()
    static var reloadData: (() -> Void)?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUPloadedImages()
        bindUI()
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    
    /// Bind ViewModel Subject to CollectionView
    private func bindUI() {
        viewModel.uploadedCatListSubject
            .bind(to: collectionView.rx.items(cellIdentifier: MyUploadsCollectionViewCell.identifier, cellType: MyUploadsCollectionViewCell.self)) { (row, uploadedImage, cell) in
                
                guard let imageUrlStr = uploadedImage.url else { return }
                let url = URL(string: imageUrlStr)
                cell.imageView.kf.setImage(with: url,
                                           placeholder: UIImage(named: "zoo"),
                                           options: [.transition(.fade(0.3))])
            }
            .disposed(by: rx.disposeBag)
    }
    
    
    // MARK: - Get Upload Images
    private func getUPloadedImages() {
        Network.shared.fetchMyUploadImages { [weak self] (data) in
            guard let self = self else { return }
            
            do {
                let result = try JSONDecoder().decode([Cat].self, from: data)
                if self.catList != result {
                    self.catList = result
                    UIView.animate(withDuration: 1.0) {
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                ProgressHUD.showFailed("Fail to fetch My Uploaded Images. Please try again later.")
            }
        }
    }
}




//// MARK: - UICollectionView DataSource
//
//extension MyUploadViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return catList.count
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyUploadsCollectionViewCell",
//                                                      for: indexPath) as! MyUploadsCollectionViewCell
//
//        let target = catList[indexPath.item]
//        guard let imageUrlStr = target.url else { return UICollectionViewCell() }
//        let url = URL(string: imageUrlStr)
//        cell.imageView.kf.setImage(with: url)
//
//        return cell
//    }
//}




// MARK: - UICollectionView Delegate

extension MyUploadViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = catList[indexPath.item]
    
        alert(title: "알림", message: "해당 이미지를 삭제하시겠습니까?") { [weak self] _ in
            guard let self = self,
                  let catId = target.id else { return }
            
            Network.shared.deleteMyCatImage(imageId: catId) {
                self.catList.remove(at: indexPath.item)
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            ProgressHUD.showSuccess("이미지가 삭제되었습니다.")
            #warning("Todo: - 삭제 후 collection reload기능 확인!")
        }
    }
}




// MARK: - UICollectionView Delegate FlowLayout

extension MyUploadViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let bounds = collectionView.bounds
        var width = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
        width = (width - layout.minimumInteritemSpacing) / 2
        return CGSize(width: width, height: 100)
    }
}
