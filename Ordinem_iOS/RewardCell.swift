//
//  RewardCell.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/5/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import Foundation
import UIKit

class RewardCell: UITableViewCell {

    @IBOutlet weak var rewardName: UILabel!
    @IBOutlet weak var rewardType: UILabel!
    @IBOutlet weak var amountLeft: UILabel!
    @IBOutlet weak var costForReward: UILabel!
    @IBOutlet weak var rewardImage: UIImageView!
    
    public var rewardID: String?
    public var adminID: Int?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
