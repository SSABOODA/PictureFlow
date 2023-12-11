//
//  Router.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import UIKit
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
    case postList(accessToken: String, next: String? = "", limit: String? = "", product_id: String? = "") // 게시글 조회
    case postUpdate(accessToken: String, postId: String, model: PostWriteRequest) // 게시글 수정
    case postDelete(accessToken: String, postId: String) // 게시글 삭제
    
    
    // Comment
    case commentCreate(postId: String, accessToken: String, model: CommentCreateRequest) // 댓글 작성
    case commentUpdate(accessToken: String, postId: String, commentId: String, model: CommentUpdateRequest) // 댓글 수정
    case commentDelete(accessToken: String, postId: String, commentId: String) // 댓글 삭제
    
    // Like
    case like(accessToken: String, postId: String)
    
    // User Profile
    case userProfileRetrieve(accessToken: String) // 유저 프로필 조회
    case userProfileUpdate(accessToken: String, model: UserProfileUpdateRequest)
    
    
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
        case .postUpdate(_, let postId, _): return "post/\(postId)"
        case .postDelete(_, let postId): return "post/\(postId)"
            
        // comment
        case .commentCreate(let postId, _, _): return "post/\(postId)/comment"
        case .commentUpdate(_, let postId, let commentId, _): return "post/\(postId)/comment/\(commentId)"
        case .commentDelete(_, let postId, let commentId): return "post/\(postId)/comment/\(commentId)"
            
        // like
        case .like(_, let postId): return "post/like/\(postId)"
            
        // user profile
        case .userProfileRetrieve: return "profile/me"
        case .userProfileUpdate: return "profile/me"
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
        case .postUpdate(let accessToken, _, _):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
        case .postDelete(let accessToken, _):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
            
        // comment
        case .commentCreate(_, let accessToken, _):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
        case .commentUpdate(let accessToken, _, _, _):
            defaultHeader[APIConstants.authorization] = accessToken
            return defaultHeader
        case .commentDelete(let accessToken, _, _):
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
        case .userProfileUpdate(let accessToken, _):
            defaultHeader[APIConstants.authorization] = accessToken
            defaultHeader["Content-Type"] = "multipart/form-data"
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
        case .postUpdate: return .put
        case .postDelete: return .delete
            
        // comment
        case .commentCreate: return .post
        case .commentUpdate: return .put
        case .commentDelete: return .delete
            
        // like
        case .like: return .post
            
        // user profile
        case .userProfileRetrieve: return .get
        case .userProfileUpdate: return .put
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
        case .postUpdate: return nil
        case .postDelete: return nil
        
        // like
        case .like: return nil
            
        // comment
        case .commentCreate(_, _, let model):
            return [
                "content": model.content
            ]
        case .commentUpdate(_, _, _, let model):
            return [
                "content": model.content
            ]
        case .commentDelete: return nil
            
        // user profile
        case .userProfileRetrieve: return nil
        
        default: return nil
        }
    }
    
//    private var query: [String: String]? { return ["": ""] }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        print("url: \(url)")

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
            let params: [String: Any] = [
                "title": model.title,
                "product_id": model.productId,
                "content": model.content,
                "content1": model.content1,
                "content2": model.content2,
                "content3": model.content3,
                "content4": model.content4,
                "content5": model.content5,
                "file": model.file
            ]
            return makeMultipartFormdata(params: params)
        case .postUpdate(_, _, let model):
            let params: [String: Any] = [
                "title": model.title,
                "product_id": model.productId,
                "content": model.content,
                "content1": model.content1,
                "content2": model.content2,
                "content3": model.content3,
                "content4": model.content4,
                "content5": model.content5,
                "file": model.file
            ]
            return makeMultipartFormdata(params: params)
            
        case .userProfileUpdate(_, let model):
            let params: [String: Any] = [
                "nick": model.nick,
                "phoneNum": model.phoneNum,
                "birthDay": model.birthDay,
                "profile": model.profile,
            ]
            return makeMultipartFormdata(params: params)
            
        default: return MultipartFormData()
        }
    }
    
    func makeMultipartFormdata(params: [String:Any]) -> MultipartFormData {
        
        let multipartFormData = MultipartFormData()
        
        for (key, value) in params {
            if let temp = value as? String {
                multipartFormData.append(temp.data(using: .utf8)!, withName: key)
            }
            if let temp = value as? Int {
                multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
            }
            if let temp = value as? NSArray {
                temp.forEach({ element in
                    let keyObj = key + "[]"
                    if let string = element as? String {
                        multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                    } else
                    if let num = element as? Int {
                        let value = "\(num)"
                        multipartFormData.append(value.data(using: .utf8)!, withName: keyObj)
                    }
                })
            }
            
            if let temp = value as? [UIImage] {
                for image in temp {
                    print("multipart image: \(image)")
                    multipartFormData.append(image.jpegData(compressionQuality: 0.1) ?? Data(),
                                             withName: "file",
                                             fileName: "image.jpeg",
                                             mimeType: "image/jpeg")
                }
            }
        }
        
        return multipartFormData
    }
}


/*
 //            let multipartFormData = MultipartFormData()
 //
 //            multipartFormData.append(Data(model.title.utf8), withName: "title")
 //            multipartFormData.append(Data(model.productId.utf8), withName: "product_id")
 //            multipartFormData.append(Data(model.content.utf8), withName: "content")
 //            multipartFormData.append(Data(model.content1.utf8), withName: "content1")
 //            multipartFormData.append(Data(model.content2.utf8), withName: "content2")
 //            multipartFormData.append(Data(model.content3.utf8), withName: "content3")
 //            multipartFormData.append(Data(model.content4.utf8), withName: "content4")
 //            multipartFormData.append(Data(model.content5.utf8), withName: "content5")
 //
 //            for image in model.file {
 //                print("multipart image: \(image)")
 //                multipartFormData.append(image.jpegData(compressionQuality: 0.1) ?? Data(),
 //                                         withName: "file",
 //                                         fileName: "image.jpeg",
 //                                         mimeType: "image/jpeg")
 //            }
 //            return multipartFormData
 */
