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
        titleLabel.sizeToFit()
        chat.users { users in
            let users = users.filter { user in
                user.id != Auth.auth().currentUser?.uid
            }
            let profileImage = users.first?.profileImageUrl
            if profileImage != nil && !profileImage!.isEmpty {
                self.profileImageView.loadFrom(url: profileImage!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.roundCorners()
    }
}
