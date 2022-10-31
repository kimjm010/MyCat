//
//  APILogger.swift
//  MyCat
//
//  Created by Chris Kim on 10/31/22.
//

import Foundation
import Alamofire
import RxAlamofire

final class ApiLogger: EventMonitor {
    
    let queue = DispatchQueue(label: "MyCat")
    
    // Event called when any type of Request is resumed.
    func requestDidResume(_ request: Request) {
        print("ApiLogger - requestDidResume() called - request = \(request)")
    }
    
    // Event called whenever a DataRequest has parsed a response.
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        print("ApiLogger - request() - called - response = \(response)")
        
        if let error = response.error {
            print("ApiLogger - request() - if let error = \(error)")
            switch error {
            case .sessionTaskFailed(let error):
                print("ApiLogger - request() - error - .sessionTaskFailed - error = \(error)")
//                if error._code == NSURLErrorTimedOut {
//                    print("ApiLogger - request() - error - .sessionTaskFailed - [API 타임아웃 테스트] Time out occurs! !!!!!")
//                    // 타임아웃 에러 팝업을 띄운다.
//                    self.sendRequestTimeoutNotification()
//                }
            case .explicitlyCancelled:
                print("ApiLogger - request() - error - .explicitlyCancelled")
            default:
                print("ApiLogger - request() - error - default")
            }
        }
        debugPrint(response)
        
    }
}

//MARK: - Notification
extension ApiLogger {
    
    /// 리퀘스트 타임아웃 에러 보내기
    fileprivate func sendRequestTimeoutNotification(){
        print("ApiLogger - sendRequestTimeoutNotification() called")
        
        let data = ["msg" : "requestTimeout"]
        
//        NotificationCenter.default.post(name: .RequestTimeOut, object: nil, userInfo: nil)
        
    }
}
