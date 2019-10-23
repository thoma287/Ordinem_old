//
//  CheckInCell.swift
//  
//
//  Created by Drew Thomas on 3/11/17.
//
//

import UIKit

class CheckInCell: UITableViewCell {

    @IBOutlet var checkInName: UILabel?
    @IBOutlet var profPicImage: UIImageView?
    
    
    
    public var eventID: String?
    public var UserID: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
