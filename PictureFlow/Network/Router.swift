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
    case post(accessToken: String, model: PostWriteRequest) // 게시글 작성
    case postList(
        accessToken: String,
        next: String? = "",
        limit: String? = "",
        product_id: String? = ""
    ) // 게시글 조회
    
    private var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
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
        var defaultHeader: HTTPHeaders = [
            APIConstants.apiKey: Router.key,
        ]
        switch self {
        case .join:
            return defaultHeader
        case .validation:
            return defaultHeader
        case .login(_):
            return defaultHeader
        case .refresh(let accessToken, let refreshToken):
            defaultHeader[APIConstants.authorization] = accessToken
            defaultHeader["Refresh"] = refreshToken
            return defaultHeader
        case .withdraw(let accessToken):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
            
        // post
        case .post(let accessToken, _):
            defaultHeader[APIConstants.authorization] = accessToken
            defaultHeader["Content-Type"] = "multipart/form-data"
            return defaultHeader
        case .postList(let accessToken, _, _, _):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
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
    
    var parameters: Parameters? {
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
            return nil
            return [
                "title": model.title,
                "content": model.content,
                "file": model.file,
                "product_id": model.productId,
                "content1": model.content1,
                "content2": model.content2,
                "content3": model.content3,
                "content4": model.content4,
                "content5": model.content5
            ]
        case .postList(_, let next, let limit, let product_id):
            return [
                "next": next ?? "",
                "limit": limit ?? "",
                "product_id": product_id ?? "",
            ]
        }
    }
    
//    private var query: [String: String]? { return ["": ""] }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        print("url: \(url)")

        var request = URLRequest(url: url)
        request.headers = header
        request.method = method
        
        let re = try URLEncoding.default.encode(request, with: parameters)
        print("re: \(re)")
        print("method: \(re.httpMethod)")
        print("header: \(re.headers)")
        print("parameter: \(parameters)")
        return try URLEncoding.default.encode(request, with: parameters)
    }
}


extension Router {
    var multipart: MultipartFormData {
        switch self {
        case .post(_, let model):
            let multipartFormData = MultipartFormData()
            
            print("multipart model: \(model)")
            
            multipartFormData.append(Data(model.title.utf8), withName: "title")
            multipartFormData.append(Data(model.productId.utf8), withName: "product_id")
            multipartFormData.append(Data(model.content.utf8), withName: "content")
            multipartFormData.append(Data(model.content1.utf8), withName: "content1")
            multipartFormData.append(Data(model.content2.utf8), withName: "content2")
            multipartFormData.append(Data(model.content3.utf8), withName: "content3")
            multipartFormData.append(Data(model.content4.utf8), withName: "content4")
            multipartFormData.append(Data(model.content5.utf8), withName: "content5")
            
            for image in model.file {
                print("multipart image: \(image)")
                multipartFormData.append(image.jpegData(compressionQuality: 0.1) ?? Data(),
                                         withName: "file",
                                         fileName: "image.jpeg",
                                         mimeType: "image/jpeg")
            }
            return multipartFormData
        default: return MultipartFormData()
        }
    }
}
