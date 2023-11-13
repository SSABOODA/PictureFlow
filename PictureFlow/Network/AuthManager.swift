//
//  AuthManager.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/12/23.
//

import Foundation
import Alamofire


final class AuthManager: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        guard urlRequest.url?.absoluteString.hasPrefix(BaseURL.baseURL) == true,
              let accessToken = KeyChain.read(key: APIConstants.accessToken) else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue("\(APIConstants.authorization) " + accessToken, forHTTPHeaderField: "\(APIConstants.authorization)")
        completion(.success(urlRequest))
}

    // 토큰 만료 확인되면 refresh api 호출해서 토큰 갱신함.
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        guard let accessToken = KeyChain.read(key: APIConstants.accessToken), let refreshToken = KeyChain.read(key: APIConstants.refreshToken) else { return }
        
        // token 재발급 로직
        Network.shared.requestConvertible(
            type: TokenResponse.self,
            router: .refresh(accessToken: accessToken, refreshToken: refreshToken)) { response in
                switch response {
                case .success(let data):
                    print(data.token)
                    KeyChain.create(key: APIConstants.accessToken, token: data.token)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
        }
        
    }
}
