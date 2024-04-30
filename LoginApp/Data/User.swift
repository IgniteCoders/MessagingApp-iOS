//
//  User.swift
//  LoginApp
//
//  Created by Mañanas on 23/4/24.
//

import Foundation

struct User: Codable {
    
    var id: String
    var username: String
    var firstName: String
    var lastName: String
    var gender: Gender
    var birthday: Date?
    var provider: LoginProvider
    var profileImageUrl: String?
    
    init(id: String, username: String, firstName: String, lastName: String, gender: Gender, birthday: Date?, provider: LoginProvider, profileImageUrl: String?) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.birthday = birthday
        self.provider = provider
        self.profileImageUrl = profileImageUrl
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.username = try values.decode(String.self, forKey: .username)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.gender = try Gender(rawValue: values.decode(String.self, forKey: .gender))!
        self.birthday = try? Date(timeIntervalSince1970: values.decode(Double.self, forKey: .birthday))
        self.provider = try LoginProvider(rawValue: values.decode(String.self, forKey: .provider))!
        self.profileImageUrl = try? values.decode(String.self, forKey: .profileImageUrl)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(gender.rawValue, forKey: .gender)
        try container.encode(birthday?.timeIntervalSince1970, forKey: .birthday)
        try container.encode(provider.rawValue, forKey: .provider)
        try container.encode(profileImageUrl, forKey: .profileImageUrl)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName
        case lastName
        case gender
        case birthday
        case provider
        case profileImageUrl
    }
}

enum Gender: String {
    case male
    case female
    case other
    case unspecified
}
