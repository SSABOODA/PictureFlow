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
    
    // UserVerification
    case join(model: SignUpReqeust) // 회원가입
    case validation(model: ValidationRequest) // 이메일 유효성 검증
    case login(model: LoginRequest) // 로그인
    case refresh(accessToken: String, refreshToken: String) // 리프레쉬 토큰
    case withdraw(accessToken: String) // 회원탈퇴
    
    // Post
    case post(accessToken: String, model: PostRequest) // 게시글 작성
    case postList(
        accessToken: String,
        next: String? = "",
        limit: String? = "",
        product_id: String? = ""
    ) // 게시글 조회
    
    private var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
//        switch self {
//        case .join(_):
//            return URL(string: BaseURL.baseAuthURL)!
//        case .validation(_):
//            return URL(string: BaseURL.baseAuthURL)!
//        case .login(_):
//            return URL(string: BaseURL.baseAuthURL)!
//        case .refresh(_,_):
//            return URL(string: BaseURL.baseAuthURL)!
//        case .withdraw(_):
//            return URL(string: BaseURL.baseAuthURL)!
//        case .post(_,_):
//            return URL(string: BaseURL.baseURL)!
//        case .postList(_,_,_,_):
//            return URL(string: BaseURL.baseURL)!
//        }
    }
    
    private var path: String {
        switch self {
        case .join: return "join"
        case .validation: return "validation/email"
        case .login: return "login"
        case .refresh: return "refresh"
        case .withdraw: return "withdraw"
            
        // post
        case .post: return "post"
        case .postList: return "post"
        }
    }
    
    private var header: HTTPHeaders {
        switch self {
        case .join:
            return [
                APIConstants.apiKey: Router.key,
            ]
        case .validation:
            return [
                APIConstants.apiKey: Router.key,
            ]
        case .login(_):
            return [
                APIConstants.apiKey: Router.key,
            ]
        case .refresh(let accessToken, let refreshToken):
            return [
                APIConstants.apiKey: Router.key,
                APIConstants.authorization: accessToken,
                "Refresh": refreshToken,
            ]
        case .withdraw(let accessToken):
            return [
                APIConstants.apiKey: Router.key,
                APIConstants.authorization: accessToken,
            ]
            
        // post
        case .post(let accessToken, _):
            return [
                APIConstants.apiKey: Router.key,
                APIConstants.authorization: accessToken,
            ]
        case .postList(let accessToken, _, _, _):
            return [
                APIConstants.apiKey: Router.key,
                APIConstants.authorization: accessToken,
            ]
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        case .join: return .post
        
        case .validation: return .post
        case .login: return .post
        case .refresh: return .get
        case .withdraw: return .post
            
            // post
        case .post: return .post
        case .postList: return .get
        }
    }
    
    private var parameters: Parameters? {
        switch self {
        case .join(let model):
            return [
                "email": model.email,
                "password": model.password,
                "nick": model.nickname,
                "phoneNum": model.phoneNumber ?? "",
                "birthDay": model.birthday ?? ""
            ]
        case .validation(let model):
            return [
                "email": model.email
            ]
        case .login(let model):
            return [
                "email": model.email,
                "password": model.password
            ]
        case .refresh:
            return nil
        case .withdraw:
            return nil
            
        // post
        case .post(_, let model):
            return [
                "title": model.title,
                "content": model.content,
                "file": model.file,
                "product_id": model.product_id,
                "content1": model.content1 ?? "",
                "content2": model.content2 ?? "",
                "content3": model.content3 ?? "",
                "content4": model.content4 ?? "",
                "content5": model.content5 ?? ""
            ]
        case .postList(_, let next, let limit, let product_id):
            return [
                "next": next ?? "",
                "limit": limit ?? "",
                "product_id": product_id ?? "",
//                "product_id": product_id ?? ""
            ]
        }
    }
    
//    private var query: [String: String]? {
//        switch self {
//        case .join: return nil
//        case .validation: return nil
//        case .login: return nil
//        case .refresh: return nil
//        case .withdraw: return nil
//        }
//    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        print("url: \(url)")

        var request = URLRequest(url: url)
        request.headers = header
        request.method = method
        
        let re = try URLEncoding.default.encode(request, with: parameters)
//        print("re: \(re)")
//        print("method: \(re.httpMethod)")
//        print("header: \(re.headers)")
//        print("parameter: \(parameters)")
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
