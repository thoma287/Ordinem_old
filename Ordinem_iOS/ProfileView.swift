//
//  ProfileView.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 2/8/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var name: UILabel?
    @IBOutlet var profPic: UIImageView?
    @IBOutlet var pointLabel: CountingLabel?
    @IBOutlet var rewardsButton: UIButton?
    @IBOutlet var tableHeader: UILabel?
    var refreshControl: UIRefreshControl!
    @IBOutlet var createButton: UIButton?
    @IBOutlet var scanButton: UIButton?
    @IBOutlet var wonRewardsButton: UIButton?
    
    
    var previousPointValue:Int = 0
    public var source: NSDictionary = [:]
    var sourceIndex: [String] = []
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    @IBAction func goToHome(sender: UIButton) {
        self.appDelegate.fadeTransition(sender: self, destinationVC: HomeView())
    }
    
    @IBAction func goToRewards(sender: UIButton) {
        self.appDelegate.fadeTransition(sender: self, destinationVC: RewardView())
    }
    
    @IBAction func goToCamera(sender: UIButton) {
        self.appDelegate.showCamera = true
        self.appDelegate.fadeTransition(sender: self, destinationVC: HomeView())
    }
    
    override public func loadView() {
        super.loadView()
        self.appDelegate.profileView = self
        if(self.appDelegate.mainUser?.displayName == "org"){
            dbc.getEventsByOrgID(orgID: self.appDelegate.mainUser!.uid)
        }
        else{
            //its a student so just show them which ones they are rsvped to
            dbc.getEventsUserRSVPdTo(user: self.appDelegate.mainUser!, sender: self)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.rewardsButton!.isEnabled = false
        
        
        if self.appDelegate.mainUser?.displayName != "org" {
            scanButton?.alpha = 1
            createButton?.isEnabled = false
            createButton?.alpha = 0
            wonRewardsButton?.isEnabled = true
            wonRewardsButton?.isHidden = false
        } else {
            createButton?.alpha = 1
            scanButton?.isEnabled = false
            scanButton?.alpha = 0
            createButton?.isEnabled = false
            wonRewardsButton?.isEnabled = false
            wonRewardsButton?.isHidden = true
        }
        if appDelegate.userDetails != nil {
            name?.text = appDelegate.userDetails!["display_name"] as? String
            if let ptBal = appDelegate.userDetails!["pointBalance"] as? Int {
                pointLabel?.text = "\(ptBal)"
                previousPointValue = ptBal
            } else {
                pointLabel?.text = "0"
            }
            if self.appDelegate.mainUser?.displayName == "org" {
                if appDelegate.userDetails!["verified"] as! Bool {
                    createButton?.isEnabled = true
                }
            }
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl)
        
        //code
        if self.appDelegate.rewardsLoaded {
            self.enableRewards()
        }
        
        if self.appDelegate.mainUser?.displayName == "org" {
            self.tableHeader?.text = " YOUR EVENTS"
        } else {
            self.tableHeader?.text = " YOUR RSVPS"
        }
        profPic?.image = self.appDelegate.mainProfilePic!
        profPic?.layer.masksToBounds = true
        profPic?.layer.cornerRadius = (profPic?.frame.width)!/2
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.appDelegate.rsvpIds.isEmpty {
            self.loadContents(events: [])
        } else {
            if(self.appDelegate.mainUser?.displayName == "org"){
                dbc.getEventsByOrgID(orgID: self.appDelegate.mainUser!.uid)
            }
            else{
                //its a student so just show them which ones they are rsvped to
                dbc.getEventsUserRSVPdTo(user: self.appDelegate.mainUser!, sender: self)
            }
        }
    }
    
    func refresh(sender: AnyObject?) {
        if(self.appDelegate.mainUser?.displayName == "org"){
            dbc.getEventsByOrgID(orgID: self.appDelegate.mainUser!.uid)
        }
        else{
            //its a student so just show them which ones they are rsvped to
            dbc.getEventsUserRSVPdTo(user: self.appDelegate.mainUser!, sender: self)
        }
    }
    
    func loadContents(events: NSDictionary, eventIDs: [String]) {
        print("Events data recieved")
        //print(events)
        //source = events
        //sourceIndex = eventIDs
        
        var output = [NSDictionary]()
        
        for id in eventIDs {
            output.append(events[id] as! NSDictionary)
        }
        
        loadContents(events: output as NSArray)
    }
    
    var dateIndices: [String] = [String]()
    var eventsByDate: [String : [NSDictionary]] = [:]
    
    func loadContents(events: NSArray) {
        //print("Data recieved")
        //print(events)
        //source = events
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        let modelAry = events as! [NSDictionary]
        eventsByDate.removeAll()
        dateIndices.removeAll()
        for event: NSDictionary in modelAry {
            if var eventsAry: [NSDictionary] = eventsByDate[event["startDate"] as! String] {
                eventsAry.append(event)
                eventsByDate[event["startDate"] as! String] = eventsAry
            } else {
                eventsByDate[event["startDate"] as! String] = [event]
                //print("Added section: \(event["startDate"] as! String)")
                dateIndices.append(event["startDate"] as! String)
            }
        }
        dateIndices = sortByDate(inputArray: dateIndices)
        tableView?.reloadData()
    }
    func sortByDate(inputArray: [String]) -> [String]{
        var dateAry: [Date] = []
        for dateStr in inputArray {
            //print(dateStr)
            dateAry.append(Date(dateString: dateStr, format: "MMMM d, yyyy"))
        }
        //print(dateAry)
        dateAry.sort()
        var returnAry: [String] = []
        for dateObj in dateAry {
            returnAry.append(stringFromDate(dateObj: dateObj))
        }
        //print(returnAry)
        return returnAry
    }
    
    func stringFromDate(dateObj:Date) -> String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "MMMM d, yyyy"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        
        
        let dateString = dateStringFormatter.string(from: dateObj)
        //print(dateString)
        return dateString
    }
    
    @IBAction func backToProfile(segue: UIStoryboardSegue) {
        
    }
    
    func enableRewards() {
        if self.appDelegate.mainUser?.displayName == "user" {
            self.rewardsButton!.isEnabled = true
        }
    }
    
    func updatePointView() {
        if let pointBal = appDelegate.userDetails!["pointBalance"] as? Int {
            self.pointLabel?.count(fromValue: Float(previousPointValue), toValue: Float(pointBal), withDuration: 8, andAnimationType: .EaseOut, andCounterType: .Int)
            previousPointValue = pointBal
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //code
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code
        tableView.deselectRow(at: indexPath, animated: false)
        if dateIndices.isEmpty {
            //do nothing
        } else {
            self.appDelegate.selectedEvent = self.eventsByDate[dateIndices[indexPath.section]]![indexPath.row]
            self.appDelegate.selectedCell = tableView.cellForRow(at: indexPath) as? EventCell
            self.performSegue(withIdentifier: "profileDetail", sender: self)
        }
        
        //self.appDelegate.selectedEvent = self.source?[indexPath.row] as? NSArray
        //self.performSegue(withIdentifier: "detail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dateIndices.isEmpty {
            return 1
        }
        return self.eventsByDate[dateIndices[section]]!.count
        //return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if dateIndices.isEmpty {
            return 1
        }
        return dateIndices.count
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if dateIndices.isEmpty {
            return "Empty"
        }
        return dateIndices[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dateIndices.isEmpty {
            let cell = UITableViewCell()
            if self.appDelegate.mainUser!.displayName == "user" {
                cell.textLabel?.text = "RSVP to an event to see it here."
            } else {
                cell.textLabel?.text = "Create an event to see it here."
            }
            cell.textLabel?.textColor = UIColor.lightGray
            cell.textLabel?.textAlignment = .center
            return cell
        }
        let eventer: NSDictionary = (self.eventsByDate[dateIndices[indexPath.section]]![indexPath.row])
        let cell: EventCell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        
        cell.eventData = eventer
        cell.orgPic?.layer.cornerRadius = 33
        cell.orgPic?.layer.masksToBounds = true
        cell.eventName?.text = eventer["eventTitle"] as? String
        //cell.eventDescription?.text = (self.source?[indexPath.row] as! NSArray)[2] as? String
        cell.eventID = eventer["key"] as? String
        cell.orgName?.text = eventer["orgName"] as? String
        //cell.eventDate?.text = (self.source?[indexPath.row] as! NSArray)[4] as? String
        cell.eventTime?.text = (eventer["startTime"] as! String) + " - " + (eventer["endDate"] as! String)
        
        if self.appDelegate.rsvpKeys.count > indexPath.row {
            cell.rsvpID = self.appDelegate.rsvpKeys[indexPath.row]
        }
        
        //cell.numRSVPs = eventer["numRSVPs"] as? Int
        
        cell.orgPic?.image = self.appDelegate.profPics[eventer["key"] as! String]
        //UIImage(data: NSData(contentsOf: URL(string: eventer["picURL"] as! String)!) as! Data)
        //
        cell.eventPoints?.text = "\(eventer["ptsForAttending"] as! Int)"
        cell.rsvp?.alpha = 0
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination: DetailView = segue.destination as? DetailView {
            destination.isHomeDetail = false
        }
        //code
    }

}
   

