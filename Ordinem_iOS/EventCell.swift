//
//  EventCell.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 12/12/16.
//  Copyright © 2016 Ordinem. All rights reserved.
//

import Foundation
import UIKit

public class EventCell: UITableViewCell {
    @IBOutlet var orgPic: UIImageView?
    @IBOutlet var eventName: UILabel?
    @IBOutlet var orgName: UILabel?
    @IBOutlet var rsvp: UIImageView?
    @IBOutlet var eventTime: UILabel?
    @IBOutlet var eventPoints: UILabel?
    
    @IBOutlet var rsvpButton: UIButton!
    
    public var eventID: String?
    public var orgID: Int?
    //public var numRSVPs: Int?
    public var rsvpID: String?
    
    var hasRSVPd: Bool = false
    
    var eventData: NSDictionary?
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func rsvpPressed(sender: UIButton) {
        self.appDelegate.homeView?.didSelectRSVPButton(originCell: self, state: hasRSVPd)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.eventName!.adjustsFontSizeToFitWidth = true
        self.eventName!.minimumScaleFactor = 0.7
        //initialization code
    }
}
