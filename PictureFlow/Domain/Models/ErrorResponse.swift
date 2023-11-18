//
//  ErrorResponse.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/16/23.
//

import Foundation

struct ErrorResponse: Error, Decodable {
    var message: String
}

struct CustomErrorResponse: Error {
    var statusCode: Int
    var message: String
}
