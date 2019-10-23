//
//  DetailAboutUserForRequest.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 3/24/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class DetailAboutUserForRequest: UIViewController {

    @IBOutlet var profileImage: UIImageView?
    @IBOutlet var name: UILabel?
    @IBOutlet var email: UILabel?
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        
        
    }
    
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBAction func rejectButtonPressed(_ sender: UIButton) {
        
        
    }
    
    
    let dbc: DatabaseConnector = DatabaseConnector()
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var user: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
