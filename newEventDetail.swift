//
//  newEventDetail.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/27/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class newEventDetail: UIViewController {

    @IBOutlet weak var eventImageDetails: UIImageView!
    
    @IBOutlet weak var orgNameDetails: UILabel!
    
    @IBOutlet weak var eventTitle: UILabel!
    
    @IBOutlet weak var Date: UILabel!
    
    @IBOutlet weak var Time: UILabel!
    
    @IBOutlet weak var information: UILabel!
  
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var pts4Attending: UILabel!
    
    @IBAction func accepted(_ sender: UIButton) {
    }
    
    
    
    private var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.eventTitle?.text = self.appDelegate.selectedEvent![1] as? String
        self.information?.text = self.appDelegate.selectedEvent![2] as? String
        self.orgNameDetails?.text = self.appDelegate.selectedEvent![3] as? String
        //This will need some adjustments
        self.Date?.text = (self.appDelegate.selectedEvent![4] as! String) + " " + (self.appDelegate.selectedEvent![5] as! String)
        self.location?.text = self.appDelegate.selectedEvent![6] as? String
        self.pts4Attending?.text = self.appDelegate.selectedEvent![7] as? String
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
