//
//  UserDefaultsManager.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/12/23.
//

import Foundation

final class UserDefaultsHelper {
    static let standard = UserDefaultsHelper()
    private init() { }
    
    let userDefaults = UserDefaults.standard
    
    enum Key: String {
        case accessToken
        case refreshToken
    }
    
    var accessToken: String? {
        get {
            return userDefaults.string(forKey: Key.accessToken.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.accessToken.rawValue)
        }
    }
    
    var refreshToken: String? {
        get {
            return userDefaults.string(forKey: Key.refreshToken.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.refreshToken.rawValue)
        }
    }
}
