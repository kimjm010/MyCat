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
    
    static var session: Session = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [:]
        config.httpAdditionalHeaders?["Accept"] = "application/json"
        return Session(configuration: config)
    }()
    
    
    func getRandomCatImages(page: Int, completion: @escaping (_ result: Data) -> Void) {
        let url = "v1/images/search?page=\(page)&api_key=\(Network.shared.apiKey)&format=json&limit=20"
        Network.session.request(baseURL + url, method: .get).responseDecodable(of: [Cat].self) { (response) in
            switch response.result {
            case .success(_):
                completion(response.data!)
            case .failure(let error):
                print(error)
                print(response.data!)
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
}
