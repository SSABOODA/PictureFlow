//
//  Date.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/21/23.
//

import Foundation

// 60초 이하 -> 초로 표시
// 60분 이하 -> 분으로 표시
// 24시간 이하 -> 시간으로 표사
// 30일 이하 -> 일로 표시
// 12개월 이하 -> 월로 표시
// 나머지 년으로 표시

final class DateTimeInterval {
    static let shared = DateTimeInterval()
    private init() {}
    
    func calculateDateTimeInterval(createdTime: String) -> String {
        guard let createdTime = createdTime.convertStringToDate(format: .full, localeType: .en_US_POSIX) else { return "" }
        let currentTime = Date()
        
        let components = Calendar.current.dateComponents(
            [.second, .minute, .hour, .day, .month, .year],
            from: createdTime,
            to: currentTime
        )
        
        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)개월 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else if let second = components.second, second > 0 {
            return "\(second)초 전"
        } else {
            return "방금 전"
        }
    }
    
    func makeDateComponents(_ date: Date?) -> DateComponents? {
        guard let date else { return nil }
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }
    
    
}
