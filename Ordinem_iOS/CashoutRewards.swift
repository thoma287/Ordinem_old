//
//  CashoutRewards.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/21/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class CashoutRewards: UITableViewCell {

    @IBOutlet weak var rewardTitle: UILabel!
    
    public var rewardID : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
