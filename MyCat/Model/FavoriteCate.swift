//
//  FavoriteCate.swift
//  MyCat
//
//  Created by Chris Kim on 9/16/22.
//

import Foundation


struct FavoriteCat: Codable {
    let id: Int?
    let user_id: String?
    let image_id: String?
    let sub_id: String?
    let created_at: String?
    
    struct Image: Codable {
        let id: String?
        let url: String?
    }
    
    let image: Image
}
