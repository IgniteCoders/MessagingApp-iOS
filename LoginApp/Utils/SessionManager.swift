//
//  SessionManager.swift
//  LoginApp
//
//  Created by Mañanas on 18/4/24.
//

import Foundation

class SessionManager {
    
    static func setSession(forUser username: String, andPassword password: String, withProvider provider: LoginProvider) {
        self.username(username)
        self.password(password)
        self.provider(provider)
        self.isLoggedIn(true)
    }
    
    static func isLoggedIn() -> Bool {
        UserDefaults.standard.bool(forKey: "IS_LOGGED_IN")
    }
    
    static func isLoggedIn(_ loggedIn: Bool) {
        UserDefaults.standard.setValue(loggedIn, forKey: "IS_LOGGED_IN")
    }
    
    static func username() -> String? {
        UserDefaults.standard.string(forKey: "USERNAME")
    }
    
    static func username(_ username: String) {
        UserDefaults.standard.setValue(username, forKey: "USERNAME")
    }
    
    static func password() -> String? {
        UserDefaults.standard.string(forKey: "PASSWORD")
    }
    
    static func password(_ password: String) {
        UserDefaults.standard.setValue(password, forKey: "PASSWORD")
    }
    
    static func provider() -> LoginProvider? {
        LoginProvider(rawValue: UserDefaults.standard.string(forKey: "LOGIN_PROVIDER") ?? "basic")
    }
    
    static func provider(_ provider: LoginProvider) {
        UserDefaults.standard.setValue(provider.rawValue, forKey: "LOGIN_PROVIDER")
    }
    
}
