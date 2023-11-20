//
//  UserDefaultsManager.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/12/23.
//

import Foundation

struct CustomDefaults<T> {
    let key: String
    let defaultValue: T
    
    var value: T {
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
    }
    
    static var isLoggedIn = CustomDefaults(key: Key.isLoggedIn.rawValue, defaultValue: false)
}
