//
//  MessageTableViewCell.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/17/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import Foundation
import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func style(color: UIColor?, isSender: Bool, textWidth: CGFloat) {
        var finalColor = color
        if color == nil {
            finalColor = tintColor
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let maxWidth = screenWidth * 0.25
        var width = maxWidth
        
        if textWidth < (screenWidth * 0.75) {
            let newWidth = (screenWidth * 0.90) - textWidth
            width = newWidth
        }
        
        
        containerViewLeadingConstraint.constant = 10.0
        containerViewTrailingConstraint.constant = 10.0
        if isSender {
            containerViewLeadingConstraint.constant = width
        } else {
            containerViewTrailingConstraint.constant = width
        }

        self.containerView.layoutIfNeeded()

        containerView.backgroundColor = finalColor
        containerView.layer.cornerRadius = 14
        bodyTextLabel.backgroundColor = finalColor
    }
    
}
