//
//  Model.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import Foundation


struct Cat: Codable {
    let id: String?
    let url: String?
    let width: Int?
    let height: Int?
}



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

