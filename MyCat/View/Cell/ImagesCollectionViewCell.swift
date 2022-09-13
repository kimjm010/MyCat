//
//  ImagesCollectionViewCell.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import UIKit
import Alamofire


class ImagesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var selectFavoriteButton: UIButton!
    
    
    override func awakeFromNib() {
        
        selectFavoriteButton.setTitle("", for: .normal)
    }
}
