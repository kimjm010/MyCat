//
//  SelectImageViewController.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import ProgressHUD
import NSObject_Rx
import Gallery
import RxCocoa
import RxSwift


class SelectImageViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    
    // MARK: - Vars
    private let viewModel = SelectImageViewModel()
    var gallery: GalleryController!
    var selectedImage: UIImage?
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        createBarButton()
    }
    
    
    /// Create Bar Buttons
    private func createBarButton() {
        let uploadBarButton = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(uploadCatImage))
        let imageSelectBarButton = UIBarButtonItem(title: "Image", style: .plain, target: self, action: #selector(selectImage))
        navigationItem.rightBarButtonItems = [uploadBarButton, imageSelectBarButton]
    }
    
    
    /// Upload Cat Image
    @objc private func uploadCatImage() {
        guard let imageData = selectedImage?.pngData() else { return }
        viewModel.selectImageActionSubject.onNext(.upload(imageData))
        ProgressHUD.showSuccess("고양이 이미지가 정상적으로 등록되었습니다 :)")
        self.navigationController?.popViewController(animated: true)
        #warning("Todo: - pop하면서 컬렉션뷰 리로드")
    }
    
    
    /// Select Image Action
    @objc private func selectImage() {
        actionAttach()
    }
    
    
    /// Add Gallery Action
    private func actionAttach() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.showImageGallery(camera: true)
        }
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
            self.showImageGallery(camera: false)
        }
        
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    
    /// Present Image Gallery
    ///
    /// - Parameter camera: Whether Using Camera
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        gallery.modalPresentationStyle = .fullScreen
        present(gallery, animated: true, completion: nil)
    }
}




// MARK: - Gallery Controller Delegate

extension SelectImageViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { [weak self] (image) in
                guard let self = self else { return }
                
                self.imageView.image = image
                self.selectedImage = image
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
