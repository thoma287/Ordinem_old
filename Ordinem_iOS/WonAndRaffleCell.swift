//
//  WonAndRaffleCell.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/22/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class WonAndRaffleCell: UITableViewCell {
    @IBOutlet weak var rewardName: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var pointCost: UILabel!
    @IBOutlet weak var wonImage: UIImageView!

    
    public var rewardID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
