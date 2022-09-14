//
//  Network.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import Foundation
import Alamofire

class Network {
    
    static let shared = Network()
    private init() { }
    
    private let apiKey = "live_VDbo6jETe6lCzngQkV0xS1cEkrVbAjvc3I3pgjosl9UIEJHPZECTBKIaccQ3Ojna"
    
    private var baseURL: String {
        return "https://api.thecatapi.com/"
    }
    
    
    // MARK: - RandomImage
    
    func getRandomCatImages(page: Int, completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/search?page=\(page)&limit=20"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(baseURL + url, method: .get, headers: headers)
            .responseDecodable(of: [Cat].self) { (response) in
            switch response.result {
            case .success(_):
                completion(response.data!)
            case .failure(let error):
                #if DEBUG
                print(error)
                #endif
            }
        }
    }
    
    
    // MARK: - Upload Cat Image
    
    func uploadMyCatImage(imageData: Data, completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/upload"
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data",
            "x-api-key": Network.shared.apiKey
        ]
        
        let multipartEncoding: (MultipartFormData) -> Void = { multipartFormData in
            multipartFormData.append(imageData, withName: "file", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
        }
        
        AF.upload(multipartFormData: multipartEncoding, to: baseURL + url, method: .post, headers: headers)
        .responseDecodable(of: [Cat].self) { (response) in
            debugPrint(response)
            switch response.result {
            case .success(_):
                completion(response.data!)
            case .failure(let error):
                print(error)
                print(response.data!)
            }
        }
    }
    
    // MARK: - Fetch My Uploaded Images
    
    func fetchMyUploadImages(completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(baseURL + url, method: .get, headers: headers)
            .responseDecodable(of: [Cat].self) { (response) in
            switch response.result {
            case .success(_):
                completion(response.data!)
            case .failure(let error):
                #if DEBUG
                print(error)
                #endif
            }
        }
    }
    
    
    // MARK: - Post Favorite Image
    
    func postFavoriteImage(imageId: String, completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/favourites"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        let parameters: [String: String] = [
            "image_id": "\(imageId)"
        ]
        
        AF.request(baseURL + url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .responseData { (response) in
                switch response.result {
                case .success(_):
                    completion(response.data!)
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            }
    }
    
    
    // MARK: - Fetch Favorite Images
    
    func fetchFavoriteImages(completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/favourites"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(baseURL + url, method: .get, headers: headers)
            .responseDecodable(of: [FavoriteCat].self, completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    completion(response.data!)
                case .failure(let error):
                    #if DEBUG
                    print(error, "여기")
                    #endif
                }
            })
    }
    
    
    // MARK: - Delete Favorite Image
    
    func deleteFavoriteImage(imageId: Int, completion: @escaping (_ result: Data) -> Void) {
        let urlStr = "v1/images/\(imageId)"
        var url = URL(string: baseURL + urlStr)!
        url.appendPathComponent("\(imageId)")
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(url, method: .delete, headers: headers)
            .responseData { (response) in
                switch response.result {
                case .success(let data):
                    print(#function)
                    print(data)
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            }
    }
    
    
    // MARK: - Delete
    
    func deleteMyCatImage(imageId: String, completion: @escaping (_ result: Data) -> Void) {
        let urlStr = "v1/images/\(imageId)"
        var url = URL(string: baseURL + urlStr)!
        url.appendPathComponent(imageId)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(url, method: .delete, headers: headers)
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let data):
                    print(#function)
                    print(data)
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            })
    }
}
