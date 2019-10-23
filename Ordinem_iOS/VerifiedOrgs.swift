//
//  VerifiedOrgs.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 3/20/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class VerifiedOrgs: UITableViewCell {
    
    @IBOutlet var profPic: UIImageView?
    @IBOutlet var orgName: UILabel?
    
    var orgID: String?
    
    var orgData: NSDictionary?

    
    let dbc: DatabaseConnector = DatabaseConnector()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
