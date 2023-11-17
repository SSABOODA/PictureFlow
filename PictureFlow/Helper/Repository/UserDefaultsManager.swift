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
        case isLoggedIn
    }
    
    var isLoggedIn: Bool {
        get {
            return userDefaults.bool(forKey: Key.isLoggedIn.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.isLoggedIn.rawValue)
        }
    }
}
