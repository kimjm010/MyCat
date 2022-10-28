//
//  Network.swift
//  MyCat
//
//  Created by Chris Kim on 9/13/22.
//


import UniformTypeIdentifiers
import ProgressHUD
import RxAlamofire
import Foundation
import Alamofire
import RxSwift


class Network {
    
    // MARK: - Singleton
    
    static let shared = Network()
    private init() { }
    
    
    // MARK: - Vars
    
    let apiKey = Bundle.main.infoDictionary?["MY_CAT_API_KEY"] ?? ""
    
    private var baseURL: String {
        return "https://api.thecatapi.com/"
    }
    
    
    // MARK: - Fetch Random Cat Image
    
    func fetchRandomCatImages(page: Int, completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/search?page=\(page)&limit=20"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
        ]
        
        AF.request(baseURL + url, method: .get, headers: headers)
            .responseDecodable(of: [Cat].self) { (response) in
                switch response.result {
                case .success(_):
                    completion(response.data!)
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to get random cat images. Please try again later.\n \(error.localizedDescription)")
                }
            }
    }
    
    
    // MARK: - Fetch My Uploaded Images
    
    func fetchMyUploadImages(completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/?limit=100"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
        ]
        
        AF.request(baseURL + url, method: .get, headers: headers)
            .responseDecodable(of: [Cat].self) { (response) in
                switch response.result {
                case .success(_):
                    print(#fileID, #function, #line, "- \(self.baseURL + url)")
                    completion(response.data!)
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to get my uploaded cat image. Please try again later.\n \(error.localizedDescription)")
                }
            }
    }
    
    
    // MARK: - Fetch Favorite Images
    
    func fetchFavoriteImages(completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/favourites"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
        ]
        
        AF.request(baseURL + url, method: .get, headers: headers)
            .responseDecodable(of: [FavoriteCat].self, completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    completion(response.data!)
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to get favorite cat image. Please try again later.\n \(error.localizedDescription)")
                }
            })
    }
    
    
    // MARK: - Post Cat Image
    
    func postMyCatImage(imageData: Data, completion: @escaping () -> Void) {
        let url = "v1/images/upload"
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data",
            "x-api-key": apiKey as! String
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
                    completion()
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to upload cat image. Please try again later./n \(error.localizedDescription)")
                }
            }
    }
    
    
    // MARK: - Post Favorite Image
    
    func postFavoriteImage(imageId: String, completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/favourites"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
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
                    ProgressHUD.showFailed("Fail to upload favorite cat image. Please try again later.\n \(error.localizedDescription)")
                }
            }
    }
    
    
    // MARK: - Delete Favorite Image
    
    func deleteFavoriteImage(imageId: Int, completion: @escaping () -> Void) {
        let url = "v1/favourites/\(imageId)"
        print(#fileID, #function, #line, "- \(baseURL)\(url)")
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
        ]
        
        
        AF.request(baseURL + url, method: .delete, headers: headers)
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    completion()
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to delete favorite cate image. Please try again later.\n \(error.localizedDescription)")
                }
            })
    }
    
    
    // MARK: - Delete Cat Image
    
    func deleteMyCatImage(imageId: String, completion: @escaping () -> Void) {
        let url = "v1/images/\(imageId)"
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
        ]
        
        AF.request(baseURL + url, method: .delete, headers: headers)
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    print(#fileID, #function, #line, "- \(self.baseURL + url)")
                    completion()
                case .failure(let error):
                    ProgressHUD.showFailed("Fail to delete cat image. Please try again later.\n \(error.localizedDescription)")
                }
            })
    }
}
