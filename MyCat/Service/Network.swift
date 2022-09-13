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
    
    var page = 0

    let apiKey = "live_VDbo6jETe6lCzngQkV0xS1cEkrVbAjvc3I3pgjosl9UIEJHPZECTBKIaccQ3Ojna"
    
    var baseURL: String {
        return "https://api.thecatapi.com/"
    }
    
    
    static var session: Session = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [:]
        config.httpAdditionalHeaders?["Accept"] = "application/json"
        return Session(configuration: config)
    }()
    
    func getRandomCatImages(completion: @escaping (_ result: Data) -> Void) {
        page += 1
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
}
