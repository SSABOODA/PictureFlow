//
//  Extension+Date.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/13/23.
//

import Foundation

enum DateFormatType: String {
    case compact = "yyyyMMdd"
}

extension Date {
    func convertDateToString(format: DateFormatType) -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = format.rawValue
        formmater.locale = Locale(identifier: "ko_KR")
        return formmater.string(from: self)
    }

}
