//
//  Network.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation
import Alamofire

enum NetworkError: Int, Error, LocalizedError {
    case missingParameter = 420
    case doesNotExistUser = 401
    case existUserInfo = 409
    case expiredToken = 419
    case overRequest = 429
    case badRequest = 444
    case invalidServer = 500
    
    var errorDescription: String {
        switch self {
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
    
    typealias NetworkCompletion<T> = (Result<T, NetworkError>) -> Void
    
    func requestConvertible<T: Decodable>(
        type: T.Type? = nil,
        router: Router,
        completion: @escaping NetworkCompletion<T>
    ) {
        AF.request(router)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(_):
                let statusCode = response.response?.statusCode ?? 500
                guard let error = NetworkError(rawValue: statusCode) else { return }
                completion(.failure(error))
            }
        }
    }
}

