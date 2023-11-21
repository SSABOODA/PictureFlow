//
//  Extension+Date.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/13/23.
//

import Foundation

/*
 Convert Date Format
 */

enum DateFormatType {
    case compact
    case full
    
    var description: String {
        switch self {
        case .compact:
            return "yyyyMMdd"
        case .full:
            return "yyyy-MM-dd'T'HH:mm:ss.SZ"
        }
    }

}

enum LocaleIdentifierType {
    case ko_KR
    case en_US_POSIX
    
    var description: String {
        switch self {
        case .ko_KR:
            return "ko_KR"
        case .en_US_POSIX:
            return "en_US_POSIX"
        }
    }
}

extension Date {
    func convertDateToString(
        format: DateFormatType,
        localeType: LocaleIdentifierType
    ) -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = format.description
        formmater.locale = Locale(identifier: "ko_KR")
        return formmater.string(from: self)
    }
}

extension String {
    func convertStringToDate(
        format: DateFormatType,
        localeType: LocaleIdentifierType
    ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: localeType.description)
        dateFormatter.dateFormat = format.description
        return dateFormatter.date(from: self)
    }
}




/*
 enum FormatType {
     case full
     case year
     case day
     case month
     case second
     case time
     case calendar
     case calendarTime
     case calendarWithMonth
     case noticeDay
     
     var description: String {
         switch self {
         case .full:
             return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
         case .year:
             return "yyyy-MM-dd"
         case .day:
             return "M월 d일 EEEE"
         case .month:
             return "M월"
         case .second:
             return "HH:mm:ss"
         case .time:
             return "a h:mm"
         case .calendar:
             return "yyyy년 MM월 dd일"
         case .calendarTime:
             return "a HH:mm"
         case .calendarWithMonth:
             return "yyyy년 M월"
         case .noticeDay:
             return "yyyy.MM.dd"
         }
     }
 }
 */
