//
//  DataProvider.swift
//  LoginApp
//
//  Created by Mañanas on 6/5/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DataManager {
    
    // MARK: Properties
    
    static let db = Firestore.firestore()
    
    // MARK: Get
    
    /// Get users excluding current user from Firestore
    static func getUsers() async -> [User] {
        let userID = Auth.auth().currentUser!.uid
        var users = [User]()
        
        do {
            let querySnapshot = try await db.collection("Users").whereField("id", isNotEqualTo: userID).getDocuments()
            
            for document in querySnapshot.documents {
                let user = try document.data(as: User.self)
                users.append(user)
            }
        } catch {
            print("Error reading users from Firestore: \(error)")
        }
        
        return users
    }
    
    /// Get chats where current user participate from Firestore
    static func getChats() async -> [Chat] {
        let userID = Auth.auth().currentUser!.uid
        var chats = [Chat]()
        
        do {
            let querySnapshot = try await db.collection("ChatUsers").whereField("userId", isEqualTo: userID).getDocuments()
            
            for document in querySnapshot.documents {
                let chatUser = try document.data(as: ChatUser.self)
                var chat = try await db.collection("Chats").document(chatUser.chatId).getDocument(as: Chat.self)
                
                chat.participants = await getUsers(byChatId: chat.id)
                chat.lastMessage = await getLastMessage(byChatId: chat.id)
                
                chats.append(chat)
            }
        } catch {
            print("Error reading chats from Firestore: \(error)")
        }
        
        return chats
    }
    
    /// Get chats where current user participate from Firestore
    static func getChatsListener(completion: @escaping ([Chat]) -> Void) -> ListenerRegistration {
        let userID = Auth.auth().currentUser!.uid
        
        let listener = db.collection("ChatUsers").whereField("userId", isEqualTo: userID).addSnapshotListener({ querySnapshot, error in
            Task {
                var chats = [Chat]()
                do {
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(error!)")
                        return
                    }
                    
                    for document in documents {
                        let chatUser = try document.data(as: ChatUser.self)
                        var chat = try await db.collection("Chats").document(chatUser.chatId).getDocument(as: Chat.self)
                        
                        chat.participants = await getUsers(byChatId: chat.id)
                        chat.lastMessage = await getLastMessage(byChatId: chat.id)
                        
                        chats.append(chat)
                    }
                } catch {
                    print("Error reading chats from Firestore: \(error)")
                }
                completion(chats)
            }
        })
        return listener
    }
    
    /// Get chat by id from Firestore
    static func getChat(byId chatId: String) async -> Chat? {
        do {
            var chat = try await db.collection("Chats").document(chatId).getDocument(as: Chat.self)
            
            chat.participants = await getUsers(byChatId: chat.id)
            chat.lastMessage = await getLastMessage(byChatId: chat.id)
            
            return chat
        } catch {
            print("Error reading chats from Firestore: \(error)")
            return nil
        }
    }
    
    /// Get users that participate in the chat by the chat id from Firestore
    static func getUsers(byChatId chatId: String) async -> [User] {
        var participants = [User]()
        
        do {
            let querySnapshot = try await db.collection("ChatUsers").whereField("chatId", isEqualTo: chatId).getDocuments()
            
            for document in querySnapshot.documents {
                let chatUser = try document.data(as: ChatUser.self)
                let user = try await db.collection("Users").document(chatUser.userId).getDocument(as: User.self)
                participants.append(user)
            }
        } catch {
            print("Error reading users of chat from Firestore: \(error)")
        }
        
        return participants
    }
    
    /// Get messages by the chat id from Firestore
    static func getMessages(byChatId chatId: String) async -> [Message] {
        var messages = [Message]()
        
        do {
            let querySnapshot = try await db.collection("Messages").whereField("chatId", isEqualTo: chatId).order(by: "date").getDocuments()
            
            for document in querySnapshot.documents {
                let message = try document.data(as: Message.self)
                messages.append(message)
            }
        } catch {
            print("Error reading messages from Firestore: \(error)")
        }
        
        return messages
    }
    
    /// Get messages by the chat id from Firestore
    static func getMessagesListener(byChatId chatId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        
        let listener = db.collection("Messages").whereField("chatId", isEqualTo: chatId).order(by: "date").addSnapshotListener({ querySnapshot, error in
            
            var messages = [Message]()
            do {
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                for document in documents {
                    let message = try document.data(as: Message.self)
                    messages.append(message)
                }
            } catch {
                print("Error reading messages from Firestore: \(error)")
            }
            completion(messages)
        })
        return listener
    }
    
    /// Get last message in the chat by the chat id from Firestore
    static func getLastMessage(byChatId chatId: String) async -> Message? {
        var messages = [Message]()
        
        do {
            let querySnapshot = try await db.collection("Messages").whereField("chatId", isEqualTo: chatId).order(by: "date").limit(toLast: 1).getDocuments()
            
            for document in querySnapshot.documents {
                let message = try document.data(as: Message.self)
                messages.append(message)
            }
        } catch {
            print("Error reading messages from Firestore: \(error)")
        }
        
        return messages.first
    }
    
    // MARK: Put
    
    /// Write the message in Firestore
    static func createChat(withUser user: User) async -> Chat? {
        do {
            let docRef = try await db.collection("Chats").addDocument(data: [:])
            try await docRef.setData(["id" : docRef.documentID], merge: true)
            
            let userID = Auth.auth().currentUser!.uid
            let chatUser = ChatUser(userId: user.id, chatId: docRef.documentID)
            let chatUser2 = ChatUser(userId: userID, chatId: docRef.documentID)
            try db.collection("ChatUsers").addDocument(from: chatUser)
            try db.collection("ChatUsers").addDocument(from: chatUser2)
            
            guard let chat = await getChat(byId: docRef.documentID) else {
                return nil
            }
            
            return chat
        } catch {
            print("Error writing chat to Firestore: \(error)")
            return nil
        }
    }
    
    /// Write the message in Firestore
    static func createMessage(_ message: Message) {
        do {
            try db.collection("Messages").addDocument(from: message)
        } catch {
            print("Error writing message to Firestore: \(error)")
        }
    }
}
