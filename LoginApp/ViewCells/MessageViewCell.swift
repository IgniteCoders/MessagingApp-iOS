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
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: Data
    
    func render(message: Message) {
        messageLabel.text = message.message
        
        let date = Date(timeIntervalSince1970: message.date)
        var dateFormatted: String
        if (Calendar.current.isDateInToday(date)) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatted = dateFormatter.string(from: date)
        } else if (Calendar.current.isDateInYesterday(date)) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "'Ayer' HH:mm"
            dateFormatted = dateFormatter.string(from: date)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd HH:mm"
            dateFormatted = dateFormatter.string(from: date)
        }
        dateLabel.text = dateFormatted
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageView.roundCorners(radius: 5)
    }
}
