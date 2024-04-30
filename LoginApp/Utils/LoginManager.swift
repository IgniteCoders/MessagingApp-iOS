//
//  LoginProvider.swift
//  LoginApp
//
//  Created by Mañanas on 22/4/24.
//

import Foundation

class LoginManager {
    
    /*static func getCurrentUser() throws -> User {
        switch SessionManager.provider() {
            
        case .basic:
            <#code#>
        case .google:
            <#code#>
        default:
            throw fatalError("No sign in provider found")
        }
    }*/
    
    func singIn () {
        
    }
    
    func singOut () {
        
    }
}

enum LoginProvider: String {
    case basic
    case google
    case apple
    case facebook
}
