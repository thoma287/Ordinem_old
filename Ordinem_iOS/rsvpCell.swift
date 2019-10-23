//
//  rsvpCell.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/11/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import Foundation


class rsvpCell: UITableViewCell {

    
    @IBOutlet var name: UILabel?
    @IBOutlet var userProfileImage: UIImageView!
    
    
    public var eventID: String?
    public var userID: Int?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }



}
