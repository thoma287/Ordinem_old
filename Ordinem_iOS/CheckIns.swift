//
//  CheckIns.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 3/11/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class CheckIns: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var source: NSDictionary = [:]
    var sourceIndex = [String]()
    
    var checkInUserIDs = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let eventID = self.appDelegate.selectedEvent!["key"] as! String
        //dbc.getPPLWhoRSVPed(eventID: eventID, sender: self)
        
        
    }
    
    
    override func loadView() {
        super.loadView()
        
        let eventIDl = self.appDelegate.selectedEvent!["key"] as! String
        
        dbc.getPPLWhoCheckedIn(eventID: eventIDl, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appDelegate.mainUser?.displayName == "org" //and live or passed
        {
            FIRAnalytics.logEvent(withName: "checkin_controller_viewed", parameters: ["Organization" : ((self.appDelegate.selectedEvent!["orgName"] as! String) as Any as! NSObject),"Event_ID" : ((self.appDelegate.selectedEvent!["key"] as! String) as Any as! NSObject),"Event_Type" : ((self.appDelegate.selectedEvent!["eventType"] as! String) as Any as! NSObject),"Points_Offered" : ((self.appDelegate.selectedEvent!["ptsForAttending"] as! Int) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as! String) as Any as! NSObject)])
        }
    }
    
    
    func loadContents(users: NSDictionary, userIDs: [String]) {
        print("RSVP Data recieved")
        print(users)
        source = users
        sourceIndex = userIDs
        tableView?.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code
        tableView.deselectRow(at: indexPath, animated: false)
        self.appDelegate.selectedUser = self.source[indexPath.row] as? NSDictionary
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.sourceIndex.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: CheckInCell = tableView.dequeueReusableCell(withIdentifier: "checkinCell") as! CheckInCell
        
        let checkinr = (self.source[sourceIndex[indexPath.row]] as! NSDictionary)
        
        
        
        cell.checkInName?.text = "\(checkinr["first_name"] as! String) \(checkinr["last_name"] as! String)"
        
        if self.appDelegate.checkInPics[checkinr["key"] as! String] != nil {
            cell.profPicImage!.image = self.appDelegate.checkInPics[checkinr["key"] as! String]
        }
        
        return cell
    }

    
    
    
    
    
    
    
    
    
    


}
