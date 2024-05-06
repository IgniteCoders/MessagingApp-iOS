//
//  ChatViewCell.swift
//  LoginApp
//
//  Created by Mañanas on 26/4/24.
//

import UIKit
import FirebaseAuth

class ChatViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet weak var messagesLabel: UILabel!
    
    // MARK: Data
    
    func render(chat: Chat) {
        titleLabel.text = chat.name
        //titleLabel.sizeToFit()
        
        let user = chat.getOtherUser()
        self.titleLabel.text = user.fullName()
        let profileImage = user.profileImageUrl
        if profileImage != nil && !profileImage!.isEmpty {
            self.profileImageView.loadFrom(url: profileImage!)
        } else {
            self.profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        var lastMessageText = ""
        if chat.lastMessage != nil {
            lastMessageText = chat.lastMessage!.message
        }
        self.subtitleLabel.text = lastMessageText
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.roundCorners()
    }
}
