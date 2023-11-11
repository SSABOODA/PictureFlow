//
//  Router.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation
import Alamofire

enum Join {
    case join // 회원가입
    case validation // 이메일 유효성 검증
    case login // 로그인
    case refresh // 리프레쉬 토큰
    case withdraw // 회원탈퇴
}

let join: Join = .login

class APIRouter: URLRequestConvertible {
    
    enum APIType {
        case signUp
        case service
        
        var baseURL: String {
            switch self {
            case .signUp:
                switch join {
                case .join: return "join"
                case .validation: return "validation/email"
                case .login: return "login"
                case .refresh: return "refresh"
                case .withdraw: return "withdraw"
                }
            case .service:
                return ""
            }
        }
    }
    private static let key = APIKey.sesacAPIKey
    private var path: String
    private var httpMethod: HTTPMethod
    private var parameters: Data?
    private var apiType: APIType
    private var header: HTTPHeaders {
        return [
            "SesacKey": "\(APIRouter.key)"
        ]
    }
    
    init(path: String, httpMethod: HTTPMethod? = .get, parameters: Data? = nil, apiType: APIType = .service) {
        self.path = path
        self.httpMethod = httpMethod ?? .get
        self.parameters = parameters
        self.apiType = apiType
    }
    
    func asURLRequest() throws -> URLRequest {
        // 2. base URL + path
        let fullURL = apiType.baseURL + path
        let encodedURL = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var urlCompoenet = URLComponents(string: encodedURL)!
        
        // 3. get> query parmeter 추가
        if httpMethod == .get, let params = parameters {
            if let dictionary = try? JSONSerialization.jsonObject(with: params, options: []) as? [String:Any] {
                var queries = [URLQueryItem]()
                for (name, value) in dictionary {
                    let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let queryItem = URLQueryItem(name: name, value: encodedValue)
                    queries.append(queryItem)
                }
                urlCompoenet.percentEncodedQueryItems = queries
            }
        }
        
        // 4. request 생성
        var request = try URLRequest(url: urlCompoenet.url!, method: httpMethod)
        request.headers = header
        
        // 5. post> json parameter 추가
        if httpMethod == .post, let params = parameters {
            request.httpBody = params
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // 6. print to console
        print("[REQUEST]")
        print("URI: \(request.url?.absoluteString ?? "nil")")
//        print("Body: \(request.httpBody?.toPrettyPrintedString ?? NSString())")
        
        return request
    }
    
}
