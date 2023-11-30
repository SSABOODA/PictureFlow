//
//  Network.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import UIKit
import Alamofire
import RxSwift

protocol ErrorProtocol: Error {
    var errorDescription: String { get }
}

struct APICustomError {
    
    // 공통 에러
    enum CommonError: Int, ErrorProtocol {
        
        case notExistApikey = 420 // "This service sesac memolease only"
        case overRequest = 429 // "과호출입니다."
        case badRequestURL = 444 // 돌아가 여긴 자네가 올 곳이 아니야.
        case serverInternalError = 500 // serverError
        
        var errorDescription: String {
            switch self {
            case .notExistApikey: return "notExistApikey"
            case .overRequest: return "overRequest"
            case .badRequestURL: return "badRequestURL"
            case .serverInternalError: return "serverInternalError"
            }
        }
    }
    
    // 회원가입
    enum JoinError: Int, ErrorProtocol {
        case missingParameter = 400 // 필수값을 채워주세요
        case alreadySignedUp = 409 // 이미 가입한 유저일 때 리턴
        
        var errorDescription: String {
            switch self {
            case .missingParameter: return "missingParameter"
            case .alreadySignedUp: return "alreadySignedUp"
            }
        }
    }
    
    // 이메일 유효성 체크
    enum EmailValidationError: Int, ErrorProtocol {
        case missingParameter = 400 // 필수값을 채워주세요
        case unavailableEmail = 409 // 사용이 불가한 이메일입니다.
        
        var errorDescription: String {
            switch self {
            case .missingParameter: return "missingParameter"
            case .unavailableEmail: return "unavailableEmail"
            }
        }
    }
    
    // 로그인
    enum LoginError: Int, ErrorProtocol {
        case missingParameter = 400 // 필수값을 채워주세요
        case checkAccount = 401 // 계정을 확인해주세요
        
        var errorDescription: String {
            switch self {
            case .missingParameter: return "missingParameter"
            case .checkAccount: return "checkAccount"
            }
        }
    }
    
    // AccessToken 갱신
    enum TokenRefreshError: Int, ErrorProtocol {
        case unableAuthenticateAccessToken = 401 // 인증할 수 없는 토큰 값
        case forbidden = 403 // Forbidden
        case noExpired = 409 // 액세스 토큰이 만료되지 않았습니다.
        case refreshTokenExpired = 418 // 리프레스 토큰이 만료되었습니다. 다시 로그인 해주세요
        
        var errorDescription: String {
            switch self {
            case .unableAuthenticateAccessToken: return "unableAuthenticateAccessToken"
            case .forbidden: return "forbidden"
            case .noExpired: return "noExpired"
            case .refreshTokenExpired: return "refreshTokenExpired"
            }
        }
    }
    
    // 탈퇴
    enum WithdrawError: Int, ErrorProtocol {
        case unableAuthenticateAccessToken = 401 // 인증할 수 없는 액세스 토큰입니다.
        case forbidden = 403 // Forbidden
        case accessTokenExpired = 419 // 액세스 토큰이 만료되었습니다.
        
        var errorDescription: String {
            switch self {
            case .unableAuthenticateAccessToken: return "unableAuthenticateAccessToken"
            case .forbidden: return "forbidden"
            case .accessTokenExpired: return "accessTokenExpired"
            }
        }
    }
    
    // 포스트 작성
    enum PostCreateError: Int, ErrorProtocol {
        case badRequest = 400 // 잘못된 요청입니다.
        case unableAuthenticateAccessToken = 401 // 인증할 수 없는 액세스 토큰입니다.
        case forbidden = 403
        case notExistPost = 410 // 생성된 게시글이 없습니다.
        case accessTokenExpired = 419 // 액세스 토큰이 만료되었습니다.
        
        var errorDescription: String {
            switch self {
            case .badRequest: return "badRequest"
            case .unableAuthenticateAccessToken: return "unableAuthenticateAccessToken"
            case .forbidden: return "forbidden"
            case .notExistPost: return "notExistPost"
            case .accessTokenExpired: return "accessTokenExpired"
            }
        }
    }
    
    // 포스트 조회
    enum PostReadError: Int, ErrorProtocol {
        case badRequest = 400 // 잘못된 요청입니다.
        case unableAuthenticateAccessToken = 401 // 인증할 수 없는 액세스 토큰입니다.
        case forbidden = 403
        case accessTokenExpired = 419 // 액세스 토큰이 만료되었습니다.
        
        var errorDescription: String {
            switch self {
            case .badRequest: return "badRequest"
            case .unableAuthenticateAccessToken: return "unableAuthenticateAccessToken"
            case .forbidden: return "forbidden"
            case .accessTokenExpired: return "accessTokenExpired"
            }
        }
    }
    
    // 포스트 수정
    enum PostUpdateError: Int, ErrorProtocol {
        case badRequest = 400 // 잘못된 요청입니다.
        case unableAuthenticateAccessToken = 401 // 인증할 수 없는 액세스 토큰입니다.
        case forbidden = 403
        case notExistPost = 410 // 수정할 게시글을 찾을 수 없습니다.
        case accessTokenExpired = 419 // 액세스 토큰이 만료되었습니다.
        case NoPermissionToEdit = 445 // 수정할 권한이 없습니다.
        
        var errorDescription: String {
            switch self {
            case .badRequest: return "badRequest"
            case .unableAuthenticateAccessToken: return "unableAuthenticateAccessToken"
            case .forbidden: return "forbidden"
            case .notExistPost: return "notExistPost"
            case .accessTokenExpired: return "accessTokenExpired"
            case .NoPermissionToEdit: return "NoPermissionToEdit"
            }
        }
    }
    
    // 포스트 삭제
    enum PostDeleteError: Int, ErrorProtocol {
        case unableAuthenticateAccessToken = 401 // 인증할 수 없는 액세스 토큰입니다.
        case forbidden = 403
        case notExistPost = 410 // 삭제할 게시글을 찾을 수 없습니다.
        case accessTokenExpired = 419 // 액세스 토큰이 만료되었습니다.
        case NoPermissionToDelete = 445 // 삭제할 권한이 없습니다.
        
        var errorDescription: String {
            switch self {
            case .unableAuthenticateAccessToken: return "unableAuthenticateAccessToken"
            case .forbidden: return "forbidden"
            case .notExistPost: return "notExistPost"
            case .accessTokenExpired: return "accessTokenExpired"
            case .NoPermissionToDelete: return "NoPermissionToDelete"
            }
        }
    }
}


final class Network {
    static let shared = Network()
    private init() {}
    
    // AF Request
    typealias NetworkCompletion<T> = (Result<T, CustomErrorResponse>) -> Void
    func requestConvertible<T: Decodable>(
        type: T.Type? = nil,
        router: Router,
        completion: @escaping NetworkCompletion<T>
    ) {
        AF.request(
            router,
            interceptor: AuthManager()
        )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    let statusCode = response.response?.statusCode ?? 500
                    print("statusCode : \(statusCode)")
                    let error = self.makeCustomErrorResponse(response: response, statusCode: statusCode)
                    completion(.failure(error))
                }
            }
    }
    
    // single ImageUpload
    func requestFormDataConvertible(
        router: Router
    ) -> Single<Result<Data, CustomErrorResponse>> {
        
        return Single.create { single in
            let request = AF.upload(
                multipartFormData: router.multipart,
                with: router,
                interceptor: AuthManager()
            ).responseData { response in
                print("REQUEST START", response.response?.statusCode ?? 999)
                
                switch response.result {
                case .success(let data):
                    print(data)
                    single(.success(.success(data)))
                case .failure(let error):
                    
                    let statusCode = response.response?.statusCode ?? 500
                    print(statusCode, error.localizedDescription)
                    let error = self.makeCustomErrorResponse(
                        response: response,
                        statusCode: statusCode
                    )
                    single(.success(.failure(error)))
                }
            }
        
            return Disposables.create() {
                request.cancel()
            }
        }
    }
    
    // Single Observable
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


extension Network {
    func makeCustomErrorResponse<T>(response: DataResponse<T, AFError>, statusCode: Int) -> CustomErrorResponse {
        
        var customErrorResponse = CustomErrorResponse(statusCode: 500, message: "ServerError")
        guard let data = response.data else { return customErrorResponse }
        
        do {
            let serverError = try JSONDecoder().decode(ErrorResponse.self, from: data)
            print("decoding error value: \(serverError)")
            customErrorResponse = CustomErrorResponse(
                statusCode: statusCode,
                message: serverError.message
            )
        }
        catch {
            print(error)
        }
        return customErrorResponse
    }
}



/*
 { multipartFormData in
     // 기본타입 처리
     multipartFormData.append(Data(model.title.utf8), withName: "title")
     multipartFormData.append(Data(model.productId.utf8), withName: "product_id")
     multipartFormData.append(Data(model.content.utf8), withName: "content")
     multipartFormData.append(Data(model.content1.utf8), withName: "content1")
     multipartFormData.append(Data(model.content2.utf8), withName: "content2")
     multipartFormData.append(Data(model.content3.utf8), withName: "content3")
     multipartFormData.append(Data(model.content4.utf8), withName: "content4")
     multipartFormData.append(Data(model.content5.utf8), withName: "content5")
     
     // Date 처리
//                    multipartFormData.append(Data(model.time?.toString().utf8 ?? "".utf8), withName: "time")

     for image in images {
         // UIImage 처리
         print("multipart di image: \(image)")
         multipartFormData.append(image.jpegData(compressionQuality: 1) ?? Data(),
                                  withName: "file",
                                  fileName: "image.jpeg",
                                  mimeType: "image/jpeg")
     }

     // 배열 처리
//                    let keywords =  try! JSONSerialization.data(withJSONObject: model.keywords, options: .prettyPrinted)
//                    multipartFormData.append(keywords, withName: "keywords")

 },
 */
