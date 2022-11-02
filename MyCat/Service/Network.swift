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
    private let disposeBag = DisposeBag()
    let apiKey = Bundle.main.infoDictionary?["MY_CAT_API_KEY"] ?? ""
    private var baseURL: String {
        return "https://api.thecatapi.com/"
    }
    
    
    // MARK: - Fetch Random Cat Image
    /// Fetch Cat Images
    /// - Parameter page: paging value
    /// - Returns: Observable Data
    func fetchCatImages(page: Int) -> Observable<Data> {
        let url = "v1/images/search?page=\(page)&limit=20"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
        ]
        
        return Observable.create { (observer) in
            RxAlamofire.requestData(.get, self.baseURL + url, headers: headers)
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .filter { 200..<300 ~= $0.0.statusCode }
                .subscribe(onNext: {
                    observer.onNext($0.1)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    // MARK: - Fetch My Uploaded Images
    /// Fetch Uploaded Images
    /// - Returns: Data Observable
    func fetchUploadedImages() -> Observable<Data?> {
        let url = "v1/images/?limit=100"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
        ]
        
        return Observable.create { (observer) in
            RxAlamofire
                .requestData(.get, self.baseURL + url, headers: headers)
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    observer.onNext($1)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    // MARK: - Fetch Favorite Images
    /// Fetch Favorite Images
    /// - Returns: Data Observable
    func fetchFavImages() -> Observable<Data> {
        let url = "v1/favourites"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-api-key": apiKey as! String
        ]
        
        return Observable.create { (observer) in
            RxAlamofire.requestData(.get, self.baseURL + url, headers: headers)
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .filter { 200..<300 ~= $0.0.statusCode }
                .subscribe(onNext: {
                    observer.onNext($0.1)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
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
    
    
    // MARK: - Upload Cat Image
    /// Upload Cat Image
    /// - Parameter imageData: Image's id
    /// - Returns: Void Observable
    func uploadCatImage(imageData: Data) -> Observable<Void> {
        let url = "v1/images/upload"
        guard let resultUrl = URL(string: baseURL + url) else { return Observable.empty() }
        var urlRequest = URLRequest(url: resultUrl)
        urlRequest.method = .post
        urlRequest.headers.add(.contentType("multipart/form-data"))
        urlRequest.headers.add(name: "x-api-key", value: apiKey as! String)
        
        print(#fileID, #function, #line, "- ")
        
        let multipartEncoding: (MultipartFormData) -> Void = { multipartFormData in
            
            multipartFormData.append(imageData,
                                     withName: "file",
                                     fileName: "\(Date().timeIntervalSince1970).png",
                                     mimeType: "image/png")
        }
        
        print(#fileID, #function, #line, "- ")

        return Observable.create { (observer) in
            
            RxAlamofire.upload(multipartFormData: multipartEncoding, urlRequest: urlRequest)
                .debug()
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .debug()
                .subscribe(onNext: { _ in
                    print(#fileID, #function, #line, "테스트 - uploadCatImage:")
                    observer.onNext(())
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    // MARK: - Post Favorite Image
    /// Upload Image to Favorite Folder
    /// - Parameter imageId: Image's id
    /// - Returns: Void Observable
    func uploadFavoriteImage(imageId: String) -> Observable<Void> {
        let url = "v1/favourites"
        let parameters: [String: String] = [
            "image_id": "\(imageId)"
        ]
        
        guard let resultUrl = URL(string: baseURL + url) else { return Observable.empty() }
        var urlRequst = URLRequest(url: resultUrl)
        urlRequst.method = .post
        urlRequst.headers.add(.contentType("application/json"))
        urlRequst.headers.add(name: "x-api-key", value: apiKey as! String)
        
        do {
            urlRequst.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            print(#fileID, #function, #line, "- ")
        }
        
        return Observable.create { [weak self] (observer) in
            guard let self = self else { return Disposables.create() }
            
            RxAlamofire.request(urlRequst)
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .validate(statusCode: 200..<300)
                .subscribe(onNext: { _ in
                    observer.onNext(())
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    // MARK: - Delete Favorite Image
    /// Delete Favorite Image
    /// - Parameter imageId: imageId
    /// - Returns: Empty Observable
    func deleteFavImage(imageId: Int) -> Observable<Void> {
        let url = "v1/favourites/"
        
        guard var resultUrl = URL(string: baseURL + url) else { return Observable.empty() }
        resultUrl.appendPathComponent("\(imageId)", conformingTo: .utf8TabSeparatedText)
        var urlRequest = URLRequest(url: resultUrl)
        urlRequest.method = .delete
        urlRequest.headers.add(.contentType("application/json"))
        urlRequest.headers.add(name: "x-api-key", value: apiKey as! String)
        
        
        return Observable.create { (observer) in
            RxAlamofire.request(urlRequest)
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .debug()
                .validate(statusCode: 200..<300)
                .debug()
                .subscribe(onNext: { _ in
                    print(#fileID, #function, #line, "테스트 - deleteFavImage: \(imageId)")
                    observer.onNext(())
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    // MARK: - Delete Cat Image
    /// Delete Cat Image
    /// - Parameter imageId: Cat image Id
    /// - Returns: Void Observable
    func deleteCatImage(imageId: String) -> Observable<Void> {
        let url = "v1/images/\(imageId)"
        guard let resultUrl = URL(string: baseURL + url) else { return Observable.empty() }
        var urlRequest = URLRequest(url: resultUrl)
        urlRequest.method = .delete
        urlRequest.headers.add(.contentType("application/json"))
        urlRequest.headers.add(name: "x-api-key", value: apiKey as! String)
        
        return Observable.create { (observer) in
            RxAlamofire.request(urlRequest)
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .debug()
                .subscribe(onNext: { _ in
                    print(#fileID, #function, #line, "테스트 - deleteFavImage: \(imageId)")
                    observer.onNext(())
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
