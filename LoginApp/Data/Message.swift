//
//  Message.swift
//  LoginApp
//
//  Created by Mañanas on 26/4/24.
//

import Foundation

struct Message: Codable {
    var message: String
    var date: Double
    var senderId: String
    var chatId: String
}
