//
//  Router.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    private static let key = APIKey.sesacAPIKey
    
    case join // 회원가입
    case validation // 이메일 유효성 검증
    case login(model: LoginRequest) // 로그인
    case refresh(accessToken: String, refreshToken: String) // 리프레쉬 토큰
    case withdraw // 회원탈퇴
    
    private var baseURL: URL {
        return URL(string: APIKey.baseURL)!
    }
    
    private var path: String {
        switch self {
        case .join: return "join"
        case .validation: return "validation/email"
        case .login: return "login"
        case .refresh: return "refresh"
        case .withdraw: return "withdraw"
        }
    }
    
    private var header: HTTPHeaders {
        switch self {
        case .join:
            return []
        case .validation:
            return []
        case .login(let model):
            print(model)
            return []
        case .refresh(let accessToken, let refreshToken):
            return [
                "SesacKey": "\(Router.key)",
                "Authorization": accessToken,
                "Refresh": refreshToken,
            ]
        case .withdraw:
            return []
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        case .join: return .post
        case .validation: return .post
        case .login: return .post
        case .refresh: return .get
        case .withdraw: return .post
        }
    }
    
    private var parameters: Parameters? {
        switch self {
        case .join:
            return [
                "email": "",
                "password": ""
            ]
        case .validation:
            return [
                "email": "",
                "password": ""
            ]
        case .login(let model):
            return [
                "email": model.email,
                "password": model.password
            ]
        case .refresh:
            return [
                "email": "",
                "password": ""
            ]
        case .withdraw:
            return [
                "email": "",
                "password": ""
            ]
        }
        
    }
    
    private var query: [String: String] {
        switch self {
        case .join: return ["": ""]
        case .validation: return ["": ""]
        case .login: return ["": ""]
        case .refresh: return ["": ""]
        case .withdraw: return ["": ""]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        print("url: \(url)")
        var request = URLRequest(url: url)
        request.headers = header
        request.method = method
        request = try URLEncodedFormParameterEncoder(destination: .methodDependent).encode(query, into: request)
        
        return request
//        return try URLEncoding.default.encode(request, with: parameters)
    }
}
