//
//  PrivateRequestCell.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 3/24/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class PrivateRequestCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet var acceptButton: UIButton?
    @IBOutlet var rejectButton: UIButton?
    @IBOutlet var profileImage: UIImageView?
    
    var userID: String?
    var userDictionary: NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
