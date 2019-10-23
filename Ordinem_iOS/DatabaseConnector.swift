//
//  DatabaseConnector.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 12/11/16.
//  Copyright © 2016 Ordinem. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

public class DatabaseConnector {
    
    var data : NSMutableData = NSMutableData()
    var dict: NSMutableDictionary = NSMutableDictionary()
    var refQuery: FIRDatabaseQuery?
    var refHandle: FIRDatabaseHandle?

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func addUser(user: FIRUser, details: [String : Any]) {
        self.appDelegate.ref?.child("chapman").child("users").child(user.uid).setValue(details)
    }
    
    func addOrg(user: FIRUser, details: [String : Any]) {
        self.appDelegate.ref?.child("chapman").child("organizations").child(user.uid).setValue(details)
    }
    
    
    func privateAccessRequest(user:FIRUser, orgID: String, userID: String, details: [String: Any]){
        self.appDelegate.ref?.child("chapman").child(orgID).child("private_Connections").child(userID).setValue(details)
    }
    
    func addReward(user: FIRUser, details: [String : Any]) {
        self.appDelegate.ref?.child("chapman").child("rewards").childByAutoId().setValue(details)
        
    }
    
    func addToWinnerTable(user: FIRUser, rewardTitle: String,  pointCost: Int, closeDate: String, pickupLocation: String, prizeAmount: Int,  eventImage: String, addInfo: String, verified: Bool) {
        
        self.appDelegate.ref?.child("chapman").child("rewards").child("Wins").childByAutoId().setValue(["rewardTitle": rewardTitle,
                                                                                                          
                                                                                                          "pointCost": pointCost,
                                                                                                          "closeDate": closeDate,
                                                                                                          "pickupLocation": pickupLocation,
                                                                                                          "prizeAmount": prizeAmount,
                                                                                                          "addInfo" : addInfo,
                                                                                                          "verified": verified
            ])
    }
    
    
    func addRSVPUser(eventID: String, user: FIRUser){
        self.appDelegate.ref?.child("chapman").child("RSVPs").childByAutoId().setValue(["eventID":eventID, "userID": user.uid])
        //self.appDelegate.ref?.child("chapman").child("events").child("public").child(eventID).child("numRSVPs").setValue(count)
    }
    
    func removeRSVPUser(eventID: String, rsvpid: String, user: FIRUser){
        self.appDelegate.ref?.child("chapman").child("RSVPs").child(rsvpid).removeValue()
        //self.appDelegate.ref?.child("chapman").child("events").child("public").child(eventID).child("numRSVPs").setValue(count)
    }
    
    
    
    func checkUserIn(user: FIRUser, eventID: String) {
        self.appDelegate.ref?.child("chapman").child("checkins").childByAutoId().setValue(["eventID":eventID, "userID": user.uid])
    }
    
    func addPointsToUser(user: FIRUser, points: Int) {
        
        //TIMER FOR IMCREMENTATION
        //let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (Selector(("animate"))), userInfo: nil, repeats: true)
        //timer.fire()
        
        
        let dataRef: FIRDatabaseReference = self.appDelegate.ref!.child("chapman").child("users").child(user.uid).child("pointBalance")
        dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                self.appDelegate.userDetails!["pointBalance"] = (value + points)
                self.appDelegate.ref?.child("chapman").child("users").child(user.uid).child("pointBalance").setValue((value + points))
                self.appDelegate.homeView?.loadUserDetails()
            } else {
                print("unable to load user details")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

    
    func getUserCheckins(user: FIRUser) {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("checkins").queryOrdered(byChild: "userID").queryEqual(toValue: user.uid)
        self.refQuery!.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
          
            if let result = snapshot.value as? NSDictionary {
                //print("checkins: \(snapshot.value)")
                var finalOutput: [String] = []
                for (_, value) in result {
                    let eventID: String = (value as! NSDictionary)["eventID"] as! String
                    finalOutput.append(eventID)
                }
                DispatchQueue.main.async {
                    print("loaded ID's of events you've checked in to")
                    self.appDelegate.checkInIDs = finalOutput
                    self.appDelegate.homeView?.loadCheckins(events: finalOutput)
                }
            } else {
                print("unable to load checkin data")
                //print(snapshot.value)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getPPLWhoRSVPed(eventID: String, sender: RSVPs) {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("RSVPs").queryOrdered(byChild: "eventID").queryEqual(toValue: eventID)
        self.refQuery!.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let result = snapshot.value as? NSDictionary {
                var finalOutput: [String] = []
                for (_, value) in result {
                    let userID: String = (value as! NSDictionary)["userID"] as! String
                    finalOutput.append(userID)
                }
                DispatchQueue.main.async {
                    print("loaded ID's of people who RSVPd")
                    //print(finalOutput)
                    self.getUsersForIDs(userIDs: finalOutput, sender: sender)
                }
            } else {
                print("unable to load rsvp data")
                //print(snapshot.value)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getPPLWhoCheckedIn(eventID: String, sender: CheckIns) {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("checkins").queryOrdered(byChild: "eventID").queryEqual(toValue: eventID)
        self.refQuery!.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let result = snapshot.value as? NSDictionary {
                var finalOutput: [String] = []
                for (_, value) in result {
                    let userID: String = (value as! NSDictionary)["userID"] as! String
                    finalOutput.append(userID)
                }
                DispatchQueue.main.async {
                    print("loaded ID's of people who RSVPd")
                    //print(finalOutput)
                    self.getUsersForIDs(userIDs: finalOutput, sender: sender)
                }
            } else {
                print("unable to load rsvp data")
                //print(snapshot.value)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func getUsersForIDs(userIDs: [String], sender: RSVPs) {
        if !userIDs.isEmpty {
            var dataRef: FIRDatabaseReference = self.appDelegate.ref!.child("chapman").child("users").child(userIDs[0])
            dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    //print("starting loop")
                    var userObjects: [String : NSDictionary] = [:]
                    var updatedIDs: [String] = userIDs
                    for key in userIDs {
                        dataRef = self.appDelegate.ref!.child("chapman").child("users").child(key)
                        dataRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                            if let userObj = snapshot2.value as? NSMutableDictionary {
                                userObj["key"] = key
                                userObjects[key] = (userObj as NSDictionary)
                                if self.appDelegate.rsvpPics[key] == nil {
                                    self.getDataFromUrl(url: URL(string: userObj["profileImageURL"] as! String)!) { (data, response, error)  in
                                        guard let data = data, error == nil else { return }
                                        //print(response?.suggestedFilename ?? URL(string: userObj["profileImageURL"] as! String)!.lastPathComponent)
                                        //print("Download Finished")
                                        DispatchQueue.main.async() { () -> Void in
                                            self.appDelegate.rsvpPics[key] = UIImage(data: data)
                                            sender.tableView?.reloadData()
                                        }
                                    }
                                }
                            } else {
                                print("unable to load users for event")
                                updatedIDs = updatedIDs.filter() { $0 != key }
                                //print(snapshot.value)
                            }
                            var recievedAll: Bool = true
                            for id in updatedIDs {
                                if userObjects[id] == nil {
                                    recievedAll = false
                                }
                            }
                            if recievedAll {
                                print("users for IDs loaded")
                                sender.loadContents(users: userObjects as NSDictionary, userIDs: updatedIDs)
                            }
                        })
                    }
                } else {
                    print("I FOUND YOUR PROBLEM DUDE")
                    let updatedIDs = userIDs.filter() { $0 != userIDs[0] }
                    self.getUsersForIDs(userIDs: updatedIDs, sender: sender)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            print("no users found")
        }
    }
    
    
    private func getUsersForIDs(userIDs: [String], sender: CheckIns) {
        if !userIDs.isEmpty {
            var dataRef: FIRDatabaseReference = self.appDelegate.ref!.child("chapman").child("users").child(userIDs[0])
            dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    //print("starting loop")
                    var userObjects: [String : NSDictionary] = [:]
                    var updatedIDs: [String] = userIDs
                    for key in userIDs {
                        dataRef = self.appDelegate.ref!.child("chapman").child("users").child(key)
                        dataRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                            if let userObj = snapshot2.value as? NSMutableDictionary {
                                userObj["key"] = key
                                userObjects[key] = (userObj as NSDictionary)
                                if self.appDelegate.checkInPics[key] == nil {
                                    self.getDataFromUrl(url: URL(string: userObj["profileImageURL"] as! String)!) { (data, response, error)  in
                                        guard let data = data, error == nil else { return }
                                        //print(response?.suggestedFilename ?? URL(string: userObj["profileImageURL"] as! String)!.lastPathComponent)
                                        //print("Download Finished")
                                        DispatchQueue.main.async() { () -> Void in
                                            self.appDelegate.checkInPics[key] = UIImage(data: data)
                                            sender.tableView?.reloadData()
                                        }
                                    }
                                }
                            } else {
                                print("unable to load users for event")
                                updatedIDs = updatedIDs.filter() { $0 != key }
                                //print(snapshot.value)
                            }
                            var recievedAll: Bool = true
                            for id in updatedIDs {
                                if userObjects[id] == nil {
                                    recievedAll = false
                                }
                            }
                            if recievedAll {
                                print("users for IDs loaded")
                                sender.loadContents(users: userObjects as NSDictionary, userIDs: updatedIDs)
                            }
                        })
                    }
                } else {
                    print("I FOUND YOUR PROBLEM DUDE")
                    let updatedIDs = userIDs.filter() { $0 != userIDs[0] }
                    self.getUsersForIDs(userIDs: updatedIDs, sender: sender)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            print("no users found")
        }
    }

    
    
    

    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    

    
    func getPPLWhoRSVPedd(eventID: String, sender: ProfileRSVPs){
        self.refQuery = self.appDelegate.ref?.child("chapman").child("RSVPs").queryOrdered(byChild: "eventID").queryEqual(toValue: eventID)
        self.refQuery!.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let result = snapshot.value as? NSDictionary {
                var finalOutput: [String] = []
                for (_, value) in result {
                    let userID: String = (value as! NSDictionary)["userID"] as! String
                    finalOutput.append(userID)
                }
                DispatchQueue.main.async {
                    print("loaded ID's of people who RSVPd")
                    //print(finalOutput)
                    self.getUsersForIDss(userIDs: finalOutput, sender: sender)
                }
            } else {
                print("unable to load rsvp data")
                //print(snapshot.value)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    private func getUsersForIDss(userIDs: [String], sender: ProfileRSVPs) {
        var dataRef: FIRDatabaseReference = self.appDelegate.ref!.child("chapman").child("users").child(userIDs[0])
        dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                //print("starting loop")
                var userObjects: [String : NSDictionary] = [:]
                for key in userIDs {
                    dataRef = self.appDelegate.ref!.child("chapman").child("users").child(key)
                    dataRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                        if let userObj = snapshot2.value as? NSMutableDictionary {
                            userObj["key"] = key
                            userObjects[key] = (userObj as NSDictionary)
                            var recievedAll: Bool = true
                            for id in userIDs {
                                if userObjects[id] == nil {
                                    recievedAll = false
                                }
                            }
                            if recievedAll {
                                //print("contents loaded")
                                sender.loadContents(users: userObjects as NSDictionary, userIDs: userIDs)
                            }
                        } else {
                            print("unable to load users for event")
                            //print(snapshot.value)
                        }
                    })
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    
    func getEventsUserRSVPdTo(user: FIRUser, sender: UIViewController){
        self.refQuery = self.appDelegate.ref?.child("chapman").child("RSVPs").queryOrdered(byChild: "userID").queryEqual(toValue: user.uid)
        self.refQuery!.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let result = snapshot.value as? NSDictionary {
                var finalOutput: [String] = []
                var rsvpOutput: [String] = []
                //print(result)
                for (key, value) in result {
                    let eventID: String = (value as! NSDictionary)["eventID"] as! String
                    finalOutput.append(eventID)
                    let rsvpID: String = key as! String
                    rsvpOutput.append(rsvpID)
                }
                DispatchQueue.main.async {
                    print("loaded ID's of events you've RSVP'd to")
                    self.appDelegate.rsvpKeys = rsvpOutput
                    if let sender = sender as? HomeView {
                        sender.loadRSVPs(events: finalOutput, rsvpIDs: rsvpOutput)
                    } else  {
                        self.getEventsForIDs(eventIDs: finalOutput, sender: sender)
                    }
                }
            } else {
                print("unable to load rsvp data")
                DispatchQueue.main.async {
                    //print("loaded ID's of events you've RSVP'd to")
                    if let sender = sender as? ProfileView {
                        sender.loadContents(events: [:], eventIDs: [])
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func getEventsForIDs(eventIDs: [String], sender: UIViewController) {
        var dataRef: FIRDatabaseReference = self.appDelegate.ref!.child("chapman").child("events").child("public").child(eventIDs[0])
        dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                var eventObjects: [String : NSDictionary] = [:]
                for key in eventIDs {
                    dataRef = self.appDelegate.ref!.child("chapman").child("events").child("public").child(key)
                    dataRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                        if let eventObj = snapshot2.value as? NSMutableDictionary {
                            eventObj["key"] = key
                            eventObjects[key] = (eventObj as NSDictionary)
                            var recievedAll: Bool = true
                            for id in eventIDs {
                                if eventObjects[id] == nil {
                                    recievedAll = false
                                }
                            }
                            if recievedAll {
                                if let sender = sender as? ProfileView {
                                    sender.loadContents(events: eventObjects as NSDictionary, eventIDs: eventIDs)
                                }
                            }
                        } else {
                            print("unable to load events for IDs")
                            //print(snapshot2.value)
                            //print(eventIDs)
                        }
                    })
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func addEvent(user: FIRUser, details: [String : Any], pointsRemaining: Int) {
        self.appDelegate.ref?.child("chapman").child("events").child("public").childByAutoId().setValue(details)
        self.appDelegate.ref?.child("chapman").child("organizations").child(user.uid).child("allowance").setValue(pointsRemaining)
    }
    
    func addPrivateEvent(user: FIRUser, details: [String : Any], pointsRemaining: Int) {
        self.appDelegate.ref?.child("chapman").child("events").child("private").childByAutoId().setValue(details)
        self.appDelegate.ref?.child("chapman").child("organizations").child(user.uid).child("allowance").setValue(pointsRemaining)
    }
    
    func removeEvent(eventID: String) {
        self.appDelegate.ref?.child("chapman").child("events").child("public").child(eventID).removeValue()
    }
    
    func removePrivateEvent(eventID: String) {
        self.appDelegate.ref?.child("chapman").child("events").child("private").child(eventID).removeValue()
    }
    
    func addSuggestionReport(user: FIRUser, report: String) {
        //let cUser = FIRAuth.auth()?.currentUser
        self.appDelegate.ref?.child("chapman").child("reports").child("suggestion").childByAutoId().setValue(["report": report
            ])
    }
    
    func addBugReport(user: FIRUser, report: String) {
        
        //let cUser = FIRAuth.auth()?.currentUser
        self.appDelegate.ref?.child("chapman").child("reports").child("bugs").childByAutoId().setValue(["report": report
            ])
    }
    
    func addEventReport(user: FIRUser, type: String, report: String) {
        
        
        //let cUser = FIRAuth.auth()?.currentUser
        self.appDelegate.ref?.child("chapman").child("reports").child("events").childByAutoId().setValue(["type":type,"report": report
            ])
    }
    
    
    //TODO
    //CREATED ADMIN ID REFERENCE BUT NOT INVOKED IN THE DB
    func addCashouts(user: FIRUser, rewardID: String, userID: String, timeStamp: Double, numPts: Int){
        self.appDelegate.ref?.child("chapman").child("cashouts").childByAutoId().setValue(["rewardID":rewardID, "userID": userID, "timeStamp": timeStamp, "numPts": numPts])
    }
    
    func updateRewardAmount(rewardID: String, numLeft: Int) {
        self.appDelegate.ref?.child("chapman").child("rewards").child(rewardID).child("prizeAmount").setValue(numLeft)
    }
    
    
    
    func getRewards() {
        self.appDelegate.ref?.child("chapman").child("rewards").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let result = snapshot.value as? NSDictionary {
                var finalOutput: [NSDictionary] = []
                
                var keys: [String] = [String]()
                for (key, _) in result {
                    keys.append(key as! String)
                }
                
                for (key, value) in result {
                    let newResult: NSMutableDictionary = value as! NSMutableDictionary
                    newResult["key"] = key as! String
                    let newResultSolid: NSDictionary = newResult as NSDictionary
                    finalOutput.append(newResultSolid)
                    if self.appDelegate.rewardPics[newResultSolid["key"] as! String] == nil {
                        let picRef = self.appDelegate.storage!.reference(forURL: newResultSolid["imageURL"] as! String)
                        picRef.data(withMaxSize: 2 * 1024 * 1024) { data, error2 in
                            if let error2 = error2 {
                                // Uh-oh, an error occurred!
                                print(error2.localizedDescription)
                            } else {
                                // Data for "images/island.jpg" is returned
                                let image = UIImage(data: data!)
                                self.appDelegate.rewardPics[newResultSolid["key"] as! String] = image
                                
                                var recievedAll: Bool = true
                                for key in keys {
                                    if self.appDelegate.rewardPics[key] == nil {
                                        recievedAll = false
                                    }
                                }
                                if recievedAll {
                                    DispatchQueue.main.async {
                                        print("loaded reward data")
                                        //print((value[0] as! NSDictionary)["eventTitle"] as! String)
                                        self.appDelegate.rewards = finalOutput as NSArray
                                        self.appDelegate.rewardsLoaded = true
                                        if self.appDelegate.adminView != nil {
                                            self.appDelegate.adminView!.enableRewards()
                                        }
                                        if self.appDelegate.profileView != nil {
                                            self.appDelegate.profileView!.enableRewards()
                                        }
                                        if self.appDelegate.homeView != nil {
                                            self.appDelegate.homeView!.enableRewards()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("unable to load reward data")
                //print(snapshot.value)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateEvent(event: NSDictionary, eventTitle: String, startDate: String, startTime: String, endDate: String, location: String, eventType: String, additionalInfo: String){
        let updated = event as! NSMutableDictionary
        
        updated["eventTitle"] = eventTitle
        updated["startDate"] = startDate
        updated["startTime"] = startTime
        updated["endDate"] = endDate
        updated["eventType"] = eventType
        updated["additionalInfo"] = additionalInfo
        updated["location"] = location
        
        self.appDelegate.ref?.child("chapman").child("events").child("public").child(event["key"] as! String).setValue(updated)
        
    }
    
    func updatePrivateEvent(event: NSDictionary, eventTitle: String, startDate: String, startTime: String, endDate: String, location: String, eventType: String, additionalInfo: String){
        let updated = event as! NSMutableDictionary
        
        updated["eventTitle"] = eventTitle
        updated["startDate"] = startDate
        updated["startTime"] = startTime
        updated["endDate"] = endDate
        updated["eventType"] = eventType
        updated["additionalInfo"] = additionalInfo
        updated["location"] = location
        
        self.appDelegate.ref?.child("chapman").child("events").child("private").child(event["key"] as! String).setValue(updated)
        
    }
    
    func getEvents() {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("events").child("public").queryOrdered(byChild: "startDate").queryLimited(toFirst: 20)
        self.refQuery!.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let result = snapshot.value as? NSDictionary {
                var finalOutput: [NSDictionary] = []
                for (key, value) in result {
                    let newResult: NSMutableDictionary = value as! NSMutableDictionary
                    newResult["key"] = key as! String
                    let newResultSolid: NSDictionary = newResult as NSDictionary
                    finalOutput.append(newResultSolid)
                    if self.appDelegate.profPics[newResultSolid["orgID"] as! String] == nil {
                        let picRef = self.appDelegate.storage!.reference(forURL: newResultSolid["picURL"] as! String)
                        picRef.data(withMaxSize: 2 * 1024 * 1024) { data, error2 in
                            if let error2 = error2 {
                                // Uh-oh, an error occurred!
                                print(error2.localizedDescription)
                            } else {
                                // Data for "images/island.jpg" is returned
                                let image = UIImage(data: data!)
                                self.appDelegate.profPics[newResultSolid["key"] as! String] = image
                                self.appDelegate.homeView?.tableView?.reloadData()
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    //print("loaded org names")
                    //print((value[0] as! NSDictionary)["eventTitle"] as! String)
                    self.appDelegate.homeView?.loadContents(events: finalOutput as NSArray)
                }
            } else {
                print("unable to load event data")
                //print(snapshot.value)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getPrivateEvents() {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("events").child("private").queryOrdered(byChild: "startDate").queryLimited(toFirst: 20)
        self.refQuery!.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let result = snapshot.value as? NSDictionary {
                var finalOutput: [NSDictionary] = []
                for (key, value) in result {
                    let newResult: NSMutableDictionary = value as! NSMutableDictionary
                    newResult["key"] = key as! String
                    let newResultSolid: NSDictionary = newResult as NSDictionary
                    finalOutput.append(newResultSolid)
                    if self.appDelegate.profPics[newResultSolid["orgID"] as! String] == nil {
                        let picRef = self.appDelegate.storage!.reference(forURL: newResultSolid["picURL"] as! String)
                        picRef.data(withMaxSize: 2 * 1024 * 1024) { data, error2 in
                            if let error2 = error2 {
                                // Uh-oh, an error occurred!
                                print(error2.localizedDescription)
                            } else {
                                // Data for "images/island.jpg" is returned
                                let image = UIImage(data: data!)
                                self.appDelegate.profPics[newResultSolid["key"] as! String] = image
                                self.appDelegate.homeView?.tableView?.reloadData()
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    //print("loaded org names")
                    //print((value[0] as! NSDictionary)["eventTitle"] as! String)
                    self.appDelegate.homeView?.loadContents(events: finalOutput as NSArray)
                }
            } else {
                print("unable to load event data")
                //print(snapshot.value)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    
    func getOrgs() {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("organizations").queryOrdered(byChild: "orgType").queryLimited(toFirst: 20)
        self.refQuery!.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let result = snapshot.value as? NSDictionary {
                var finalOutput: [NSDictionary] = []
                for (key, value) in result {
                    let newResult: NSMutableDictionary = value as! NSMutableDictionary
                    newResult["key"] = key as! String
                    let newResultSolid: NSDictionary = newResult as NSDictionary
                    finalOutput.append(newResultSolid)
                    if self.appDelegate.profPics[newResultSolid["orgID"] as! String] == nil {
                        let picRef = self.appDelegate.storage!.reference(forURL: newResultSolid["picURL"] as! String)
                        picRef.data(withMaxSize: 2 * 1024 * 1024) { data, error2 in
                            if let error2 = error2 {
                                // Uh-oh, an error occurred!
                                print(error2.localizedDescription)
                            } else {
                                // Data for "images/island.jpg" is returned
                                let image = UIImage(data: data!)
                                self.appDelegate.profPics[newResultSolid["key"] as! String] = image
                                self.appDelegate.findOrgs?.tableView?.reloadData()
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    //print("loaded org names")
                    //print((value[0] as! NSDictionary)["eventTitle"] as! String)
                    self.appDelegate.homeView?.loadContents(events: finalOutput as NSArray)
                }
            } else {
                print("unable to load event data")
                //print(snapshot.value)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func getCashoutsForUser(user: FIRUser, sender: UIViewController) {
        self.appDelegate.ref?.child("chapman").child("cashouts").queryOrdered(byChild: "userID").queryEqual(toValue: user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.value as? NSDictionary {
                var output: [String] = []
                for (_, value) in result {
                    if let value = value as? NSDictionary {
                        if (value["rewardID"] as! String) != "pantherBucks" {
                            output.append(value["rewardID"] as! String)
                        }
                    }
                }
                print("Mesomorphic Gravitron Syncronized")
                if output.count == 0 {
                    print("Gravitron Signal Not Found")
                } else {
                    self.getRewardsForIDs(rewardIDs: output, sender: sender)
                }
            } else {
                print("The Mesomorphic Gravitron is out of sync.")
            }
        })
    }
    
    func getRewardsForIDs(rewardIDs: [String], sender: UIViewController) {
        var dataRef: FIRDatabaseReference = self.appDelegate.ref!.child("chapman").child("rewards").child(rewardIDs[0])
        dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //print(rewardIDs)
            if snapshot.exists() {
                var eventObjects: [String : NSDictionary] = [:]
                var output: [NSDictionary] = []
                for key in rewardIDs {
                    dataRef = self.appDelegate.ref!.child("chapman").child("rewards").child(key)
                    dataRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                        if let eventObj = snapshot2.value as? NSMutableDictionary {
                            eventObj["key"] = key
                            eventObjects[key] = (eventObj as NSDictionary)
                            output.append(eventObj as NSDictionary)
                            var recievedAll: Bool = true
                            for id in rewardIDs {
                                if eventObjects[id] == nil {
                                    recievedAll = false
                                }
                            }
                            if recievedAll {
                                if let sender = sender as? winnerPrizes {
                                    sender.loadContents(rewards: output as NSArray)
                                }
                            }
                        } else {
                            print("unable to load events for IDs")
                            //print(snapshot2.value)
                            //print(rewardIDs)
                        }
                    })
                }
            } else {
                print("Isotopic Cryptogram has become uncoupled.")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUserDetails(user: FIRUser) {
        let dataRef: FIRDatabaseReference!
        if user.displayName == "org" || user.displayName == "admin" {
            dataRef = self.appDelegate.ref!.child("chapman").child("organizations").child(user.uid)
        } else {
            dataRef = self.appDelegate.ref!.child("chapman").child("users").child(user.uid)
        }
        self.refHandle = dataRef.observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                self.appDelegate.userDetails = value
                if self.appDelegate.homeView != nil {
                    DispatchQueue.main.async {
                        print("loaded user details")
                        self.appDelegate.homeView?.userDetailsLoaded()
                        if self.appDelegate.profileView != nil {
                            self.appDelegate.profileView?.updatePointView()
                        }
                    }
                }
            } else {
                print("unable to load user details")
            }
        })
    }
    
    func detachListener() {
        self.appDelegate.ref!.removeObserver(withHandle: self.refHandle!)
    }
    
    func getUserVerificationsForOrgs(orgID: String) {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("private_Connections").child(orgID).queryOrdered(byChild: "verified").queryEqual(toValue: false)
        
        self.refQuery!.observeSingleEvent(of: .value, with: {(snapshot) in
            if let result = snapshot.value as? NSDictionary{
                var finalOutput: [NSDictionary] = []
                for(key,value) in result{
                    let newResult: NSMutableDictionary = value as! NSMutableDictionary
                    newResult["key"] = key as! String
                    let newResultSolid: NSDictionary = newResult as NSDictionary
                    finalOutput.append(newResultSolid)
                    if self.appDelegate.profPics[newResultSolid["key"] as! String] == nil {
                        let picRef = self.appDelegate.storage!.reference(forURL: newResultSolid["profileImageURL"] as! String)
                        picRef.data(withMaxSize: 2 * 1024 * 1024) { data, error2 in
                            if let error2 = error2 {
                                // Uh-oh, an error occurred!
                                print(error2.localizedDescription)
                            } else {
                                // Data for "images/island.jpg" is returned
                                let image = UIImage(data: data!)
                                self.appDelegate.profPics[newResultSolid["key"] as! String] = image
                                self.appDelegate.orgPrivateRequests!.tableView!.reloadData()
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.appDelegate.adminView!.loadContents(data: finalOutput as NSArray)
                }
            }
        }){(error) in
            print(error.localizedDescription)
        }
        
    }

    
    
    func getEventsByOrgID(orgID: String){
        self.refQuery = self.appDelegate.ref?.child("chapman").child("events").child("public").queryOrdered(byChild: "orgID").queryEqual(toValue: orgID)
        
        self.refQuery!.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let result = snapshot.value as? NSDictionary{
                var finalOutput: [String : NSDictionary] = [:]
                var eventIDs: [String] = []
                for(key,value) in result{
                    let newResult: NSMutableDictionary = value as! NSMutableDictionary
                    newResult["key"] = key as! String
                    eventIDs.append(key as! String)
                    let newResultSolid: NSDictionary = newResult as NSDictionary
                    finalOutput[key as! String] = newResultSolid
                }
                DispatchQueue.main.async {
                    self.appDelegate.profileView?.loadContents(events: finalOutput as NSDictionary, eventIDs: eventIDs)
                }
            }
        }){(error) in
            print(error.localizedDescription)
        }
    }
    
    
    func getVerifiedOrgs() {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("organizations").queryOrdered(byChild: "verified").queryEqual(toValue: true)
        
        self.refQuery!.observeSingleEvent(of: .value, with: {(snapshot) in
            if let result = snapshot.value as? NSDictionary{
                var finalOutput: [NSDictionary] = []
                for(key,value) in result{
                    let newResult: NSMutableDictionary = value as! NSMutableDictionary
                    newResult["key"] = key as! String
                    let newResultSolid: NSDictionary = newResult as NSDictionary
                    finalOutput.append(newResultSolid)
                    if self.appDelegate.profPics[newResultSolid["key"] as! String] == nil {
                        let picRef = self.appDelegate.storage!.reference(forURL: newResultSolid["profileImageURL"] as! String)
                        picRef.data(withMaxSize: 2 * 1024 * 1024) { data, error2 in
                            if let error2 = error2 {
                                // Uh-oh, an error occurred!
                                print(error2.localizedDescription)
                            } else {
                                // Data for "images/island.jpg" is returned
                                let image = UIImage(data: data!)
                                self.appDelegate.profPics[newResultSolid["key"] as! String] = image
                                self.appDelegate.adminView!.tbv!.reloadData()
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.appDelegate.adminView!.loadContents(data: finalOutput as NSArray)
                }
            }
        }){(error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    //---------- ADMIN STUFF --------------
    
    func approveOrg(orgID: String) {
        self.appDelegate.ref?.child("chapman").child("organizations").child(orgID).child("verified").setValue(true)
    }
    
    func declineOrg(orgID: String) {
        self.appDelegate.ref?.child("chapman").child("organizations").child(orgID).removeValue()
    }
    
    func getOrgsNeedVerification() {
        self.refQuery = self.appDelegate.ref?.child("chapman").child("organizations").queryOrdered(byChild: "verified").queryEqual(toValue: false)
        
        self.refQuery!.observeSingleEvent(of: .value, with: {(snapshot) in
            if let result = snapshot.value as? NSDictionary{
                var finalOutput: [NSDictionary] = []
                for(key,value) in result{
                    let newResult: NSMutableDictionary = value as! NSMutableDictionary
                    newResult["key"] = key as! String
                    let newResultSolid: NSDictionary = newResult as NSDictionary
                    finalOutput.append(newResultSolid)
                    if self.appDelegate.profPics[newResultSolid["key"] as! String] == nil {
                        let picRef = self.appDelegate.storage!.reference(forURL: newResultSolid["profileImageURL"] as! String)
                        picRef.data(withMaxSize: 2 * 1024 * 1024) { data, error2 in
                            if let error2 = error2 {
                                // Uh-oh, an error occurred!
                                print(error2.localizedDescription)
                            } else {
                                // Data for "images/island.jpg" is returned
                                let image = UIImage(data: data!)
                                self.appDelegate.profPics[newResultSolid["key"] as! String] = image
                                self.appDelegate.adminView!.tbv!.reloadData()
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.appDelegate.adminView!.loadContents(data: finalOutput as NSArray)
                }
            }
        }){(error) in
            print(error.localizedDescription)
        }
        
    }

    
}
