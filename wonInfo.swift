//
//  wonInfo.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/27/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class wonInfo: UIViewController {

    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var rewardName: UILabel!
    
    @IBOutlet weak var winVsRaffle: UILabel!
    
    @IBOutlet weak var pointCost: UILabel!
    
    @IBOutlet weak var pickupLocation: UITextView!
    
    @IBOutlet weak var timeToPickUp: UITextView!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let eventer = self.appDelegate.selectedReward!
        
        image.image = self.appDelegate.rewardPics[eventer["key"] as! String]
        rewardName.text = eventer["rewardTitle"] as? String
        winVsRaffle.text = eventer["rewardType"] as? String
        timeToPickUp.text = "PICKUP BEFORE: \(eventer["closeDate"] as! String)"
        //awardsAvailable.text = "\(eventer["prizeAmount"] as! Int) Rewards Available"
        //details.text = eventer["addInfo"] as? String
        pointCost.text = "Cost: \(eventer["pointCost"] as! Int) Points"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
