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
    case overRequest = 429
    case badRequest = 444
    case invalidServer = 500
    
    var errorDescription: String {
        switch self {
        case .missingParameter:
            return "해당 키값을 다시확인하거나, 잘못된 요청입니다."
        case .overRequest:
            return "과호출입니다."
        case .badRequest:
            return "해당 url을 확인하거나, 잘못된 요청입니다."
        case .invalidServer:
            return "서버 에러"
        }
    }
}
