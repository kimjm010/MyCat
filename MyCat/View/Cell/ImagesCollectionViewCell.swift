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
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    override func awakeFromNib() {
        favoriteButton.setTitle("", for: .normal)
    }
}
