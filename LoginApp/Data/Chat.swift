//
//  Chat.swift
//  LoginApp
//
//  Created by Mañanas on 26/4/24.
//

import Foundation
import FirebaseAuth

struct Chat: Codable {
    var id: String
    var name: String?
    var lastMessage: Message? = nil
    var participants: [User]? = nil
    var messages: [Message]? = nil
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.name = try? values.decode(String.self, forKey: .name)
    }
    
    func getOtherUser () -> User {
        let user = self.participants!.first(where: { user in
            user.id != Auth.auth().currentUser?.uid
        })
        return user!
    }
    
    mutating func lastMessage () async -> Message?{
        self.lastMessage = await DataManager.getLastMessage(byChatId: self.id)
        return self.lastMessage
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
