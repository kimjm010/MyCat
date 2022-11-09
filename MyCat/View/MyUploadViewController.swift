//
//  MyUploadViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import NSObject_Rx
import ProgressHUD
import Kingfisher
import RxSwift
import RxCocoa


class MyUploadViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Vars
    private let viewModel = UploadViewModel()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        Network.shared.fetchMyUploadImages { (catList) in
            print(#fileID, #function, #line, "-fetchMyUploadImages: \(catList.count)")
        }
        #endif
        
        bindUI()
        controlCollectionViewEvent()
        
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
    
    
    /// Control CollectionView Select Event
    private func controlCollectionViewEvent() {
        collectionView.rx.modelSelected(Cat.self)
            .subscribe(onNext: { [weak self] (uploadedCat) in
                guard let self = self else { return }
                self.alertDeleteToUser(title: "Alert",
                                       message: "Do you want to delete selected image?")
                .subscribe(onNext: {
                    switch $0 {
                    case .ok:
                        guard let uploadImageId = uploadedCat.id else { return }
                        self.viewModel.imageActionSubject.onNext(.delete(uploadImageId))
                        ProgressHUD.showSuccess("Complete to delete selected image!")
                        #warning("Todo: - 컬렉션 뷰 리로드")
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
extension MyUploadViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let bounds = collectionView.bounds
        var width = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
        width = (width - layout.minimumInteritemSpacing) / 2
        return CGSize(width: width, height: 100)
    }
}
