//
//  MessageViewCell.swift
//  LoginApp
//
//  Created by Mañanas on 26/4/24.
//

import UIKit

class MessageViewCell: UITableViewCell {
    
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: Data
    
    func render(message: Message) {
        messageLabel.text = message.message
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageView.roundCorners(radius: 5)
    }
}
