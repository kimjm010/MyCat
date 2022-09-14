//
//  MyUploadViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import UIKit


class MyUploadViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - Vars
    
    var catList = [Cat]()
    
    var selectedCat: Cat?
    

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUPloadedImages()
    }
    
    
    // MARK: - Get Upload Images
    
    private func getUPloadedImages() {
        Network.shared.fetchMyUploadImages { [weak self] (data) in
            guard let self = self else { return }
            
            do {
                let result = try JSONDecoder().decode([Cat].self, from: data)
                self.catList.append(contentsOf: result)
                
                #if DEBUG
                print(self.catList.count)
                #endif
                
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

extension MyUploadViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catList.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyUploadsCollectionViewCell", for: indexPath) as! MyUploadsCollectionViewCell
        
        let target = catList[indexPath.item]
        guard let imageUrlStr = target.url else { return UICollectionViewCell() }
        let url = URL(string: imageUrlStr)
        cell.imageView.kf.setImage(with: url)
        
        return cell
    }
}




// MARK: - UICollectionView Delegate

extension MyUploadViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        #warning("Todo: - 이미지 삭제 기능 확인하기")
        let target = catList[indexPath.item]
        alert(title: "알림", message: "해당 이미지를 삭제하시겠습니까?") { [weak self] _ in
            guard let self = self else { return }
            guard let catId = target.id else { return }

            Network.shared.deleteMyCatImage(imageId: catId) { response in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    print(response, self.catList.count, "^^")
                }
            }
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
