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
    case postDelete(accessToken: String, postId: String) // 게시글 삭제
    
    // Comment
    case commentCreate(postId: String, accessToken: String, model: CommentCreateRequest) // 댓글 작성
    
    // Like
    case like(accessToken: String, postId: String)
    
    // User Profile
    case userProfileRetrieve(accessToken: String)
    
    
    /* baseURL */
    private var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    /* path */
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
        case .postDelete(_, let postId): return "post/\(postId)"
            
        // comment
        case .commentCreate(let postId, _, _): return "post/\(postId)/comment"
            
        // like
        case .like(_, let postId): return "post/like/\(postId)"
            
        // user profile
        case .userProfileRetrieve: return "profile/me"
        }
    }
    
    /* header */
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
        case .postDelete(let accessToken, _):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
            
        // comment
        case .commentCreate(_, let accessToken, _):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
            
        // like
        case .like(let accessToken, _):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
            
        // user profile
        case .userProfileRetrieve(let accessToken):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
        }
    }
    
    /* method */
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
        case .postDelete: return .delete
            
        // comment
        case .commentCreate: return .post
            
        // like
        case .like: return .post
            
        // user profile
        case .userProfileRetrieve: return .get
        }
    }
    
    /* parameters */
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
        case .refresh: return nil
        case .withdraw: return nil
            
        // post
        case .post: return nil // 게시글 작성
        case .postList(_, let next, let limit, let product_id): // 게시글 조회
            return [
                "next": next ?? "",
                "limit": limit ?? "",
                "product_id": product_id ?? "",
            ]
        case .postDelete: return nil
        
        // like
        case .like: return nil
            
        // comment
        case .commentCreate(_, _, let model):
            return [
                "content": model.content
            ]
            
        // user profile
        case .userProfileRetrieve: return nil
        }
    }
    
//    private var query: [String: String]? { return ["": ""] }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
//        print("url: \(url)")

        var request = URLRequest(url: url)
        request.headers = header
        request.method = method
        
//        let re = try URLEncoding.default.encode(request, with: parameters)
//        print("re: \(re)")
//        print("method: \(re.httpMethod)")
//        print("header: \(re.headers)")
//        print("parameter: \(parameters)")
        return try URLEncoding.default.encode(request, with: parameters)
    }
}

extension Router {
    var multipart: MultipartFormData {
        switch self {
        case .post(_, let model):
            let multipartFormData = MultipartFormData()
//            print("multipart model: \(model)")
            
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

/*
 for (key, value) in params {
     if let temp = value as? String {
         multiPart.append(temp.data(using: .utf8)!, withName: key)
     }
     if let temp = value as? Int {
         multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
     }
     if let temp = value as? NSArray {
         temp.forEach({ element in
             let keyObj = key + "[]"
             if let string = element as? String {
                 multiPart.append(string.data(using: .utf8)!, withName: keyObj)
             } else
             if let num = element as? Int {
                 let value = "\(num)"
                 multiPart.append(value.data(using: .utf8)!, withName: keyObj)
             }
         })
     }
 }
 multiPart.append(image, withName: "newsletter_image", fileName: "\(self.tfTitle.text ?? "")_logo.png", mimeType: "image/jpeg")

  */


