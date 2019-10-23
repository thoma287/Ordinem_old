//
//  ProfileDetailView.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/19/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ProfileDetailView: UIViewController {
    
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var eventTitle: UILabel?
    @IBOutlet var eventDescription: UITextView?
    @IBOutlet weak var hostName: UILabel?
    @IBOutlet weak var eventDateTime: UILabel?
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var points: UILabel?
    @IBOutlet weak var qr_code: UIImageView?
    @IBOutlet weak var eventTime: UILabel?
    @IBOutlet weak var rsvpNum: UILabel?
    @IBOutlet weak var eventType: UILabel?
    @IBOutlet weak var editEvent: UIButton?
    @IBOutlet weak var reportEvent: UIButton?
    
    
    private var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    
    @IBOutlet weak var rsvpButton: UIButton!
    
    
    @IBAction func backToProfileDetails(segue: UIStoryboardSegue) {
        
    }
    
    
    
    @IBAction func rsvpButtonPressed(_ sender: UIButton) {
        let cUser = self.appDelegate.mainUser
        
        //RSVP Connection
        //TODO IMAGE
        //let databaseRef = FIRDatabase.database().reference()
        
        let b = self.appDelegate.selectedEvent!["key"] as! String
        
      /*  let count = (self.appDelegate.selectedEvent!["numRSVPs"] as! Int) + 1
        var rsvpStr: String = " RSVPs"
        if count == 1 {
            rsvpStr = "RSVP"
        }
        self.rsvpNum?.text = "\(count) \(rsvpStr)"*/
        
        //PROFILE IMG FROM FACEBOOK OR SAVED FROM STORAGE
        dbc.addRSVPUser(eventID: (b), user: (cUser)!)
        
        
        rsvpButton.isEnabled = false
        
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.eventTitle?.text = self.appDelegate.selectedEvent!["eventTitle"] as? String
        
        self.eventDescription?.text = self.appDelegate.selectedEvent!["additionalInfo"] as? String
        
        self.hostName?.text = self.appDelegate.selectedEvent!["orgName"] as? String
        
        self.eventDateTime?.text = self.appDelegate.selectedEvent!["startDate"] as? String
        
        self.eventTime?.text = (self.appDelegate.selectedEvent!["startTime"] as! String) + " - " + (self.appDelegate.selectedEvent!["endDate"] as! String)
        
        self.eventType?.text = self.appDelegate.selectedEvent!["eventType"] as? String
        
        self.location?.text = self.appDelegate.selectedEvent!["location"] as? String
        
        self.points?.text = "\(self.appDelegate.selectedEvent!["ptsForAttending"] as! Int)"
        
        if self.appDelegate.profPics[self.appDelegate.selectedEvent!["key"] as! String] != nil {
            self.image.image = self.appDelegate.profPics[self.appDelegate.selectedEvent!["key"] as! String]
        } else {
            do {
                try self.image.image = UIImage(data: Data(contentsOf: URL(string: self.appDelegate.selectedEvent!["picURL"] as! String)!))
            } catch {
                print("error")
            }
            FIRAnalytics.logEvent(withName: "detail_event_selected_after_rsvping", parameters: ["Organization" : ((self.appDelegate.selectedEvent!["orgName"] as? String) as Any as! NSObject),"Event_ID" : ((self.appDelegate.selectedEvent!["key"] as? String) as Any as! NSObject),"Event_Type" : ((self.appDelegate.selectedEvent!["eventType"] as? String) as Any as! NSObject),"Points_Offered" : ((self.appDelegate.selectedEvent!["ptsForAttending"] as? Int) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
        }
        
        if self.appDelegate.mainUser!.displayName == "org" && (self.appDelegate.selectedEvent!["orgID"] as! String) == self.appDelegate.mainUser!.uid {
            let qrCode = QRCode(self.appDelegate.selectedEvent!["key"] as! String)
            qr_code?.image = qrCode!.image!
            qr_code?.alpha = 1
            self.editEvent?.isEnabled = true
            self.editEvent?.isHidden = false
            
        } else {
            self.editEvent?.isEnabled = false
            self.editEvent?.isHidden = true
            self.reportEvent?.isHidden = false
            self.reportEvent?.isEnabled = true
        }
        self.image.layer.cornerRadius = 64
        self.image.layer.masksToBounds = true
        if appDelegate.rsvpIds.contains(self.appDelegate.selectedEvent!["key"] as! String) {
            self.rsvpButton.isEnabled = false
        }
        let count = (self.appDelegate.selectedEvent!["numRSVPs"] as! Int)
        var rsvpStr: String = " RSVPs"
        if count == 1 {
            rsvpStr = "RSVP"
        }
        self.rsvpNum?.text = "\(count) \(rsvpStr)"
        
        appDelegate.numRSVPS = count
        //code
    }
    
    override public func loadView() {
        super.loadView()
        //code
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //code
    }

}
