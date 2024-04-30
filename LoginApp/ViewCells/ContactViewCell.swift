//
//  ContactTableViewCell.swift
//  LoginApp
//
//  Created by Mañanas on 30/4/24.
//

import UIKit

class ContactViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var profileImageView: UIImageView!
    
    // MARK: Data
    
    func render(user: User) {
        titleLabel.text = user.fullName()
        subtitleLabel.text = user.username 
        let profileImage = user.profileImageUrl
        if profileImage != nil && !profileImage!.isEmpty {
            self.profileImageView.loadFrom(url: profileImage!)
        } else {
            self.profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.roundCorners()
    }
}
