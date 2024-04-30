//
//  Chat.swift
//  LoginApp
//
//  Created by Mañanas on 26/4/24.
//

import Foundation
import FirebaseFirestore

struct Chat: Codable {
    var id: String
    var name: String
    //var participants: [User]? = nil
    //var messages: [Message]? = nil
    var participantsDocRef: [DocumentReference]
    var messagesDocRef: [DocumentReference]
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.participantsDocRef = try values.decode([DocumentReference].self, forKey: .participantsDocRef)
        self.messagesDocRef = try values.decode([DocumentReference].self, forKey: .messagesDocRef)
    }
    
    func users(completion: @escaping ([User]) -> Void) {
        Task {
            var participants = [User]()
            do {
                for docRef in participantsDocRef {
                    let user = try await docRef.getDocument(as: User.self)
                    participants.append(user)
                }
                completion(participants)
            } catch {
                print("Error reading users: \(error)")
            }
        }
    }
    
    func messages(completion: @escaping ([Message]) -> Void) {
        let db = Firestore.firestore()
        Task {
            var messages = [Message]()
            do {
                let querySnapshot = try await db.collection("Messages").whereField("chatId", isEqualTo: self.id).order(by: "date").getDocuments()
                
                for document in querySnapshot.documents {
                    let message = try document.data(as: Message.self)
                    messages.append(message)
                }
                
                completion(messages)
            } catch {
                print("Error reading messages: \(error)")
            }
        }
    }
    
    func lastMessage(completion: @escaping (Message?) -> Void) {
        messages(completion: { messages in
            if messages.isEmpty {
                completion(nil)
            } else {
                let message = messages.sorted(by: {
                    $0.date < $1.date
                }).last
                completion(message)
            }
        })
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case participantsDocRef = "participants"
        case messagesDocRef = "messages"
    }
}
