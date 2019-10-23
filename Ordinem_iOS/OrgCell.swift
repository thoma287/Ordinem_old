//
//  OrgCell.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 2/22/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import Foundation
import UIKit

class OrgCell: UITableViewCell {
    
    @IBOutlet weak var orgTitle: UILabel!
    @IBOutlet weak var orgPic: UIImageView!
    
    var orgID: String!
    
    let dbc: DatabaseConnector = DatabaseConnector()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
