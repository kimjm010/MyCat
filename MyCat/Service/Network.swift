//
//  Network.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//

import Foundation
import Alamofire
import ProgressHUD
import UniformTypeIdentifiers


class Network {
    
    static let shared = Network()
    private init() { }
    
    private let apiKey = "live_VDbo6jETe6lCzngQkV0xS1cEkrVbAjvc3I3pgjosl9UIEJHPZECTBKIaccQ3Ojna"
    
    private var baseURL: String {
        return "https://api.thecatapi.com/"
    }
    
    
    // MARK: - RandomImage
    
    func fetchRandomCatImages(page: Int, completion: @escaping (_ result: Data) -> Void) {
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
                    ProgressHUD.showFailed("Fail to get random cat images. Please try again later.")
                }
            }
    }
    
    
    // MARK: - Upload Cat Image
    
    func uploadMyCatImage(imageData: Data, completion: @escaping (_ result: Data) -> Void) {
        
        print(#fileID, #function, #line, "- ^^")
        
        let url = "v1/images/upload"
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data",
            "x-api-key": Network.shared.apiKey
        ]
        
        let multipartEncoding: (MultipartFormData) -> Void = { multipartFormData in
            
            multipartFormData.append(imageData,
                                     withName: "file",
                                     fileName: "\(Date().timeIntervalSince1970).png",
                                     mimeType: "image/png")
        }
        
        
        AF.upload(multipartFormData: multipartEncoding, to: baseURL + url, method: .post, headers: headers)
            .responseDecodable(of: Cat.self) { (response) in
                
                switch response.result {
                case .success(_):
                    print(#fileID, #function, #line, "- \(self.baseURL + url)")
                    completion(response.data!)
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to upload cat image. Please try again later./n \(error.localizedDescription)")
                }
            }
    }
    
    
    // MARK: - Fetch My Uploaded Images
    
    func fetchMyUploadImages(completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/?limit=100"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(baseURL + url, method: .get, headers: headers)
            .responseDecodable(of: [Cat].self) { (response) in
                switch response.result {
                case .success(_):
                    print(#fileID, #function, #line, "- \(self.baseURL + url)")
                    completion(response.data!)
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to get my uploaded cat image. Please try again later.")
                    
#if DEBUG
                    print(error.localizedDescription)
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
                    ProgressHUD.showFailed("Fail to upload favorite cat image. Please try again later.")
                    
#if DEBUG
                    print(error.localizedDescription)
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
                    ProgressHUD.showFailed("Fail to get favorite cat image. Please try again later.")
                    
#if DEBUG
                    print(error.localizedDescription)
#endif
                }
            })
    }
    
    
    // MARK: - Delete Favorite Image
    
    func deleteFavoriteImage(imageId: Int, completion: @escaping () -> Void) {
        let url = "v1/favourites/\(imageId)"
        print(#fileID, #function, #line, "- \(baseURL)\(url)")
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        
        AF.request(baseURL + url, method: .delete, headers: headers)
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    completion()
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to delete favorite cate image. Please try again later.")
                    
#if DEBUG
                    print(error.localizedDescription)
#endif
                }
            })
    }
    
    
    // MARK: - Delete Cat Image
    
    func deleteMyCatImage(imageId: String, completion: @escaping () -> Void) {
        let url = "v1/images/\(imageId)"
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(baseURL + url, method: .delete, headers: headers)
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    print(#fileID, #function, #line, "- \(self.baseURL + url)")
                    completion()
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to delete cat image. Please try again later.")
                    
#if DEBUG
                    print(error.localizedDescription)
#endif
                }
            })
    }
}
