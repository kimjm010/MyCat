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
                print(response.data!)
                #endif
            }
        }
    }
    
    
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
    
    
    func fetchMyUploadImages(completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(baseURL + url, method: .get, headers: headers).responseDecodable(of: [Cat].self) { (response) in
            switch response.result {
            case .success(_):
                completion(response.data!)
            case .failure(let error):
                #if DEBUG
                print(error)
                print(response.data!)
                #endif
            }
        }
    }
    
    
    func deleteMyCatImage(imageId: String, completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/"
        var resultUrl: String {
            return url + "\(imageId)"
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": Network.shared.apiKey
        ]
        
        AF.request(baseURL + resultUrl, method: .delete, headers: headers)
            .responseDecodable(of: Cat.self) { (response) in
                switch response.result {
                case .success(_):
                    print(#function)
                    completion(response.data!)
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            }
    }
}
