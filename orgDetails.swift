//
//  orgDetails.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 1/27/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

import UIKit

class orgDetails: UIViewController {
    
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var orgName: UILabel!
    
    @IBOutlet weak var orgType: UILabel!
    
    //@IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var studentID: UILabel!
    
    let dbc: DatabaseConnector = DatabaseConnector()
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var org: NSDictionary!
    
    @IBAction func accepted(_ sender: UIButton) {
        dbc.approveOrg(orgID: org["key"] as! String)
        self.performSegue(withIdentifier: "backHome", sender: self)
    }
    
    
    @IBAction func rejected(_ sender: UIButton) {
        dbc.declineOrg(orgID: org["key"] as! String)
        self.performSegue(withIdentifier: "backHome", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        org = self.appDelegate.selectedOrg!
        
        orgName.text = org["display_name"] as? String
        orgType.text = org["orgType"] as? String
        image.image = self.appDelegate.profPics[org["key"] as! String]
        studentID.text = org["id"] as? String
        //email.
        
        
        
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
