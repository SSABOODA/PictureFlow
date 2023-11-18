//
//  Network.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation
import Alamofire
import RxSwift

enum NetworkError: Int, Error, LocalizedError {
    case missingRequireParameter = 400
    case missingParameter = 420
    case doesNotExistUser = 401
    case existUserInfo = 409
    case expiredToken = 419
    case overRequest = 429
    case badRequest = 444
    case invalidServer = 500
    
    var errorDescription: String {
        switch self {
        case .missingRequireParameter: return "필수값이 없거나, 비밀번호가 일치하지 않습니다."
        case .missingParameter: return "해당 키값을 다시확인하거나, 잘못된 요청입니다."
        case .doesNotExistUser: return "존재하지 않는 유저입니다."
        case .existUserInfo: return "이미 가입한 유저의 이메일입니다."
        case .expiredToken: return "토큰이 만료되었습니다."
        case .overRequest: return "과호출입니다."
        case .badRequest: return "해당 url을 확인하거나, 잘못된 요청입니다."
        case .invalidServer: return "서버 에러"
        }
    }
}

final class Network {
    static let shared = Network()
    private init() {}
    
    /*
     Single
     */
    
    typealias NetworkCompletion<T> = (Result<T, CustomErrorResponse>) -> Void
    func requestConvertible<T: Decodable>(
        type: T.Type? = nil,
        router: Router,
        completion: @escaping NetworkCompletion<T>
    ) {
        AF.request(router, interceptor: AuthManager())
            .validate()
            .responseDecodable(of: T.self) { response in
                print("response: \(response)")
                switch response.result {
                case .success(let data):
                    
                    completion(.success(data))
                case .failure(_):
                    let statusCode = response.response?.statusCode ?? 500
                    guard let data = response.data else { return }
                    do {
                        let serverError = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        print("decoding error value: \(serverError)")
                        
                        let customErrorResponse = CustomErrorResponse(
                            statusCode: statusCode,
                            message: serverError.message
                        )
                        
                        completion(.failure(customErrorResponse))
                    }
                    catch {
                        print(error)
                    }
                }
            }
    }
    
    func requestObservableConvertible<T: Decodable>(
        type: T.Type,
        router: Router
    ) -> Single<Result<T, CustomErrorResponse>> {
        return Single.create { [weak self] single in
            
            self?.requestConvertible(type: T.self, router: router) { result in
                switch result {
                case .success(let success):
                    single(.success(.success(success)))
                case .failure(let error):
                    single(.success(.failure(error)))
                }
            }
            return Disposables.create()
        }
    }
}
