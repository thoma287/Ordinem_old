//
//  DetailView.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 12/14/16.
//  Copyright © 2016 Ordinem. All rights reserved.
//

import Foundation
import UIKit
import Firebase

public class DetailView: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet var eventTitle: UILabel?
    @IBOutlet var eventDescription: UITextView?
    @IBOutlet var hostName: UILabel?
    @IBOutlet var eventDateTime: UILabel?
    @IBOutlet var location: UILabel?
    @IBOutlet var points: UILabel?
    @IBOutlet var qr_code: UIImageView?
    @IBOutlet var eventTime: UILabel?
    @IBOutlet var rsvpNum: UILabel?
    @IBOutlet var eventType: UILabel?
    @IBOutlet var editEvent: UIButton?
    @IBOutlet var reportEvent: UIButton?
    @IBOutlet var rsvpLabel: UILabel?
    @IBOutlet var qrCodeButtonToCheckedIn: UIButton?
    
    @IBOutlet var orgNameProf: UIButton?
    
    @IBAction func toOrgProfile(_ sender: UIButton) {
        self.appDelegate.selectedOrg = self.appDelegate.selectedEvent
        
        self.performSegue(withIdentifier: "orgProfileSegue", sender: self)
        
    }
    
    
    
    private var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()

    @IBOutlet var rsvpButton: UIButton!
    
    var isHomeDetail: Bool = true
    
    @IBAction func backButtonPressed(sender: UIButton) {
        if isHomeDetail {
            self.performSegue(withIdentifier: "backToHome", sender: self)
        } else {
            self.performSegue(withIdentifier: "backToProfile", sender: self)
        }
    }
    
    @IBAction func backToDetails(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func rsvpButtonPressed(_ sender: UIButton) {
        var offset: Int!
        if self.rsvpLabel!.text == "CANCEL RSVP" {
            self.rsvpLabel!.text = "TAP TO RSVP"
            self.appDelegate.selectedCell!.hasRSVPd = false
            offset = -1
            
            DispatchQueue.global(qos: .background).async {
                sleep(1)
                DispatchQueue.main.async {
                    self.rsvpButton.isEnabled = true
                }
            }
        } else {
            self.rsvpLabel!.text = "CANCEL RSVP"
            self.appDelegate.selectedCell!.hasRSVPd = true
            offset = 1
            
            DispatchQueue.global(qos: .background).async {
                sleep(1)
                DispatchQueue.main.async {
                    self.rsvpButton.isEnabled = true
                }
            }
        }
        
        self.appDelegate.homeView?.didSelectRSVPButton(originCell: self.appDelegate.selectedCell!, state: self.appDelegate.rsvpIds.contains(self.appDelegate.selectedEvent!["key"] as! String))
        
        //let count = (self.appDelegate.selectedEvent!["numRSVPs"] as! Int) + offset
        
        //var rsvpStr: String = " RSVPs"
        
        //if count == 1 {
        //    rsvpStr = "RSVP"
        //}
        //self.rsvpNum?.text = "\(count) \(rsvpStr)"
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
            
        }
        
        if self.appDelegate.mainUser!.displayName == "user" {
            FIRAnalytics.logEvent(withName: "detail_event_selected", parameters: ["Org_ID" : ((self.appDelegate.selectedEvent!["orgID"] as! String) as Any as! NSObject), "Event_ID" : ((self.appDelegate.selectedEvent!["key"] as! String) as Any as! NSObject),"Event_Type" : ((self.appDelegate.selectedEvent!["eventType"] as! String) as Any as! NSObject),"Points_Offered" : ((self.appDelegate.selectedEvent!["ptsForAttending"] as! Int) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails!["studentID"] as! String) as Any as! NSObject)])
        }


        if (self.appDelegate.mainUser!.displayName == "org" && (self.appDelegate.selectedEvent!["orgID"] as! String) == self.appDelegate.mainUser!.uid) {
            self.editEvent?.isEnabled = true
            self.editEvent?.isHidden = false
            self.reportEvent?.isHidden = true
            self.reportEvent?.isEnabled = false
            
            
            if self.appDelegate.liveEvents.contains(self.appDelegate.selectedEvent!["key"] as! String) {
                let qrCode = QRCode("event:\(self.appDelegate.selectedEvent!["key"] as! String)")
                qr_code?.image = qrCode!.image!
                qr_code?.alpha = 1
                qrCodeButtonToCheckedIn?.isEnabled = true
                qrCodeButtonToCheckedIn?.isHidden = true
            }
        }
        else{
            self.editEvent?.isEnabled = false
            self.editEvent?.isHidden = true
            self.reportEvent?.isHidden = false
            self.reportEvent?.isEnabled = true
            
        }
        self.image.layer.cornerRadius = self.image.frame.width/2
        self.image.layer.masksToBounds = true
        
        if self.appDelegate.rsvpIds.contains(self.appDelegate.selectedEvent!["key"] as! String) {
            self.rsvpLabel!.text = "CANCEL RSVP"
        } else {
            self.rsvpLabel!.text = "TAP TO RSVP"
        }
        
        /*let count = (self.appDelegate.selectedEvent!["numRSVPs"] as! Int)
        var rsvpStr: String = " RSVPs"
        if count == 1 {
            rsvpStr = "RSVP"
        }*/
        self.rsvpNum?.text = "SEE WHO'S GOING"
        
        //appDelegate.numRSVPS = count
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
