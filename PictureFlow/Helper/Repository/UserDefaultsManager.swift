//
//  UserDefaultsManager.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/12/23.
//

import Foundation

@propertyWrapper
struct CustomDefaults<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
}

enum UserDefaultsManager {
    enum Key: String {
        case isLoggedIn
        case userID
    }
    
    @CustomDefaults(key: Key.isLoggedIn.rawValue, defaultValue: false) static var isLoggedIn
    @CustomDefaults(key: Key.userID.rawValue, defaultValue: "") static var userID
}
