//
//  HomeView.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 12/12/16.
//  Copyright © 2016 Ordinem. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Firebase
import FirebaseStorage


class HomeView: UIViewController, UITableViewDelegate, UITableViewDataSource, QRCodeReaderViewControllerDelegate, UISearchControllerDelegate {
    
    @IBOutlet var pointLabel: CountingLabel!
    //Make to a count label
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var searchBar: UISearchBar?
    @IBOutlet var scanButton: UIButton?
    @IBOutlet var createButton: UIButton?
    @IBOutlet var rewardButton: UIButton?
    
    var rsvpEventIDs = [String]()
    var rsvpKeys = [String]()
    var checkinEventIDs = [String]()
    var modelAry = [NSDictionary]()
    var filteredAry = [NSDictionary]()
    
    
    var showFilteredResults: Bool = false
    
    //var previousPointValue: Int = 0
    
    let rsvpImage: [String : UIImage] = ["yes": UIImage(imageLiteralResourceName: "yesRSVP.png"), "no": UIImage(imageLiteralResourceName: "noRSVP.png"), "live": UIImage(imageLiteralResourceName: "liveEvent.png"), "checkedIn": UIImage(imageLiteralResourceName: "liveEvent_scored.png")]
    
    var refreshControl: UIRefreshControl!
    
    var numRows: Int = 0
    
    @IBAction func goToProfile(sender: UIButton) {
        self.appDelegate.fadeTransition(sender: self, destinationVC: ProfileView())
    }
    
    @IBAction func goToRewards(sender: UIButton) {
        self.appDelegate.fadeTransition(sender: self, destinationVC: RewardView())
    }
    
    func generateModelArray() -> [NSDictionary]{
        return modelAry
    }

    func filterContentForSearchText(searchText: String){
        self.filteredAry = self.modelAry.filter{evnt in
            tableView?.reloadData()
            if self.searchBar!.selectedScopeButtonIndex == 0 {
                tableView?.reloadData()
                let typeMatch = evnt["eventTitle"] as? String
                return ((typeMatch?.lowercased().contains(searchText.lowercased()))!)
            } else {
                tableView?.reloadData()
                let typeMatch = evnt["orgName"] as? String
                return ((typeMatch?.lowercased().contains(searchText.lowercased()))!)
            }
        }
        tableView?.reloadData()
    }
    
    
    let searchController = UISearchController(searchResultsController: nil)

    let cellID = "cellID"
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    var dateIndices: [String] = [String]()
    var eventsByDate: [String : [NSDictionary]] = [:]
    
    
    func loadContents(events: NSArray) {
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        modelAry = events as! [NSDictionary]
        eventsByDate.removeAll()
        dateIndices.removeAll()
        
        //START
        for event: NSDictionary in modelAry {
            
            let dateStr: String = "\(event["startDate"] as! String) \(event["startTime"] as! String)"
            //print(dateStr)
            let startDate: Date = Date(dateString: dateStr, format: "MMMM d, yyyy h:mm a")
            
            if Date().timeIntervalSince(startDate) > -600.0 {
                if var eventsAry: [NSDictionary] = eventsByDate["Live Now"] {
                    eventsAry.append(event)
                    eventsByDate["Live Now"] = eventsAry
                } else {
                    eventsByDate["Live Now"] = [event]
                    dateIndices.append("Live Now")
                }
                if !self.appDelegate.liveEvents.contains(event["key"] as! String) {
                    self.appDelegate.liveEvents.append(event["key"] as! String)
                }
            } else if var eventsAry: [NSDictionary] = eventsByDate[event["startDate"] as! String] {
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
    
    func loadRSVPs(events: [String], rsvpIDs: [String]) {
        rsvpEventIDs = events
        rsvpKeys = rsvpIDs
        self.appDelegate.rsvpIds = events
        tableView?.reloadData()
    }
    
    func loadCheckins(events: [String]) {
        checkinEventIDs = events
        tableView?.reloadData()
    }
    
    func loadUserDetails() {
        self.dbc.getUserDetails(user: self.appDelegate.mainUser!)
    }
    
    func enableRewards() {
        if self.appDelegate.mainUser?.displayName == "user" {
            print("rewards remotely loaded")
            self.rewardButton!.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.appDelegate.homeView = self
        
        self.rewardButton!.isEnabled = false
        
        //Float((pointLabel?.text)!)!
        //searchController.setS
        //loadUserDetails()
        
        if self.appDelegate.rewardsLoaded {
            print("rewards supposedly loaded")
            self.enableRewards()
        }
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl) // not required when using UITableViewController
        
        self.searchBar?.tintColor = UIColor.clear
        self.searchBar!.scopeButtonTitles = ["Event", "Host"]
        searchController.delegate = self
        
        if self.appDelegate.mainUser?.displayName != "org" {
            scanButton?.alpha = 1
            createButton?.isEnabled = false
            createButton?.alpha = 0
        } else {
            createButton?.alpha = 1
            scanButton?.isEnabled = false
            scanButton?.alpha = 0
            createButton?.isEnabled = false
        }
        //TIMER INCREMENTATION CALLER
        userDetailsLoaded()
    }
    //FUNCTION TO ANIMATE THE POINTS

    
    
    override func loadView() {
        super.loadView()
        loadUserDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dbc.detachListener()
    }
    
    func retrieveContent() {
        dbc.getEvents()
        dbc.getUserCheckins(user: self.appDelegate.mainUser!)
        dbc.getEventsUserRSVPdTo(user: self.appDelegate.mainUser!, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveContent()
        self.appDelegate.homeView = self
        if self.appDelegate.showCamera {
            self.appDelegate.showCamera = false
            scanAction(self)
        }
    }
    
    func sortByDate(inputArray: [String]) -> [String]{
        var dateAry: [Date] = []
        var hasLive: Bool = false
        for dateStr in inputArray {
            //print(dateStr)
            if dateStr == "Live Now" {
                hasLive = true
            } else {
                dateAry.append(Date(dateString: dateStr, format: "MMMM d, yyyy"))
            }
        }
        //print(dateAry)
        dateAry.sort()
        var returnAry: [String] = []
        if hasLive {
            returnAry.append("Live Now")
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if showFilteredResults {
            return 1
        } else {
            return dateIndices.count
        }
    }
    
    func userDetailsLoaded() {
        if appDelegate.userDetails != nil {
            if let displayName = appDelegate.userDetails!["display_name"] as? String {
                nameLabel?.text = displayName
            }
            if let pointBal = appDelegate.userDetails!["pointBalance"] as? Int {
                pointLabel.count(fromValue: Float(self.appDelegate.userPointBal), toValue: Float(pointBal), withDuration: 8, andAnimationType: .EaseOut, andCounterType: .Int)
                self.appDelegate.userPointBal = pointBal
            } else if let pointBal = appDelegate.userDetails!["allowance"] as? Int {
                pointLabel.count(fromValue: Float(self.appDelegate.userPointBal), toValue: Float(pointBal), withDuration: 8, andAnimationType: .EaseOut, andCounterType: .Int)
                self.appDelegate.userPointBal = pointBal
            }
            if appDelegate.mainUser!.displayName == "org" {
                if(appDelegate.userDetails!["verified"] as! Bool == false){
                    createButton?.isEnabled = false
                    if (createButton?.isTouchInside)!{
                        let alertController = UIAlertController(title: "Alert", message: "Please wait for your account to be verified by your school's administration before creating your event", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    createButton?.isEnabled = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code
        tableView.deselectRow(at: indexPath, animated: false)
        if showFilteredResults {
            self.appDelegate.selectedEvent = self.filteredAry[indexPath.row]
            self.performSegue(withIdentifier: "detail", sender: self)

        } else if ((indexPath.section == (self.eventsByDate.count - 1)) && (indexPath.row == self.eventsByDate[dateIndices[indexPath.section]]!.count) && !showFilteredResults) {
            //do nothing
        } else if (showFilteredResults && indexPath.row == self.numRows) {
          //do nothing
        } else {
            self.appDelegate.selectedEvent = self.eventsByDate[dateIndices[indexPath.section]]![indexPath.row]
            self.appDelegate.selectedCell = tableView.cellForRow(at: indexPath) as? EventCell
            self.performSegue(withIdentifier: "detail", sender: self)
        }
    }
    
    func didSelectRSVPButton(originCell: EventCell, state: Bool){
        if state {
            originCell.rsvpButton.isEnabled = false
            originCell.rsvp?.image = #imageLiteral(resourceName: "noRSVP.png")
            let cUser = self.appDelegate.mainUser
            
            let eventID = originCell.eventID
            
            let rsvpID = originCell.rsvpID!
            
            //let count = originCell.numRSVPs! - 1
            
            originCell.hasRSVPd = false
            
            appDelegate.rsvpIds = appDelegate.rsvpIds.filter() { $0 != eventID! }
            rsvpEventIDs = rsvpEventIDs.filter() { $0 != eventID! }
            
            dbc.removeRSVPUser(eventID: eventID!, rsvpid: rsvpID, user: cUser!)
            
            DispatchQueue.global(qos: .background).async {
                sleep(1)
                DispatchQueue.main.async {
                    originCell.rsvpButton.isEnabled = true
                }
            }
            
        } else {
            
            originCell.rsvp?.image = #imageLiteral(resourceName: "yesRSVP.png")
            let cUser = self.appDelegate.mainUser
            
            let eventID = originCell.eventID
            
            originCell.rsvpButton.isEnabled = false
            
            appDelegate.rsvpIds.append(eventID!)
            rsvpEventIDs.append(eventID!)
            
            //PROFILE IMG FROM FACEBOOK OR SAVED FROM STORAGE
            dbc.addRSVPUser(eventID: (eventID!), user: (cUser)!)
            if self.appDelegate.mainUser?.displayName == "user" {
             FIRAnalytics.logEvent(withName: "rsvp_button_tapped", parameters: ["Organization" : ((originCell.eventData!["orgName"] as? String) as Any as! NSObject),"Event_ID" : ((originCell.eventData!["key"] as? String) as Any as! NSObject),"Event_Type" : ((originCell.eventData!["eventType"] as? String) as Any as! NSObject),"Points_Offered" : ((originCell.eventData!["ptsForAttending"] as? Int) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
            }
            originCell.hasRSVPd = true
            //originCell.rsvpButton.isEnabled = false
            
            DispatchQueue.global(qos: .background).async {
                sleep(1)
                DispatchQueue.main.async {
                    originCell.rsvpButton.isEnabled = true
                }
            }
            
            
            
        }
        self.refresh(sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showFilteredResults {
            return filteredAry.count+1
        } else {
            //print("ebd: \(self.eventsByDate.count) - section \(section)")
            if section == (self.eventsByDate.count - 1) {
                return self.eventsByDate[dateIndices[section]]!.count + 1
                //print("num events: \(self.eventsByDate[dateIndices[section]]!.count) in last section (+1)")
            } else {
                return self.eventsByDate[dateIndices[section]]!.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if showFilteredResults {
            return "Search Results"
        } else {
            return dateIndices[section]
        }
    }
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        returnedView.backgroundColor = UIColor.clear
        
        let label = UILabel(frame: CGRect(x: 15, y: 8, width: self.view.frame.width-30, height: 34))
        label.text = self.dateIndices[section]
        returnedView.addSubview(label)
        return returnedView
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath.section == (self.eventsByDate.count - 1)) && (indexPath.row == self.eventsByDate[dateIndices[indexPath.section]]!.count) && !showFilteredResults) {
            return 200
        } else if (showFilteredResults && indexPath.row == filteredAry.count) {
            return 200
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("Section: \(indexPath.section) - Row: \(indexPath.row) - NumRows: \(self.numRows) - NumEventDates: \(self.eventsByDate.count)")
        let eventer: NSDictionary!
        
        if ((indexPath.section == (self.eventsByDate.count - 1)) && (indexPath.row == self.eventsByDate[dateIndices[indexPath.section]]!.count) && !showFilteredResults) {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "empty")!
            return cell
        }
        
        if (showFilteredResults && indexPath.row >= filteredAry.count) {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "empty")!
            return cell
        }
        
        if showFilteredResults && filteredAry.isEmpty {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "empty")!
            return cell
        }
        
        if showFilteredResults {
           eventer = filteredAry[indexPath.row]
        }
        else {
            eventer = (self.eventsByDate[dateIndices[indexPath.section]]![indexPath.row])
        }
        
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
        
        cell.orgPic?.image = self.appDelegate.profPics[eventer["key"] as! String]
            //UIImage(data: NSData(contentsOf: URL(string: eventer["picURL"] as! String)!) as! Data)
            //
        cell.eventPoints?.text = "\(eventer["ptsForAttending"] as! Int)"
        
        //cell.numRSVPs = eventer["numRSVPs"] as? Int
        
        if self.rsvpKeys.count > indexPath.row {
            cell.rsvpID = self.rsvpKeys[indexPath.row]
        }
        
        //let dateStr: String = "\(eventer["startDate"] as! String) \(eventer["startTime"] as! String)"
        //print(dateStr)
        //let startDate: Date = Date(dateString: dateStr, format: "MMMM d, yyyy h:mm a")
        
        //print(Date().timeIntervalSince(startDate))
        
        if checkinEventIDs.contains(eventer["key"] as! String) {
            cell.rsvp?.image = rsvpImage["checkedIn"]
            cell.rsvpButton.isEnabled = false
        } else if self.appDelegate.liveEvents.contains(eventer["key"] as! String) {
            cell.rsvp?.image = rsvpImage["live"]
            cell.rsvpButton.isEnabled = false
        } else if rsvpEventIDs.contains(eventer["key"] as! String) {
            cell.rsvp?.image = rsvpImage["yes"]
            cell.hasRSVPd = true
        } else {
            cell.rsvp?.image = rsvpImage["no"]
            cell.hasRSVPd = false
        }
        
        return cell
        
    }
    
    func refresh(sender:AnyObject?) {
        dbc.getEvents()
        dbc.getUserCheckins(user: self.appDelegate.mainUser!)
    }
    
    @IBAction func backHome(segue: UIStoryboardSegue) {
        dbc.getEvents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination: DetailView = segue.destination as? DetailView {
            destination.isHomeDetail = true
        }
        //code
    }
    
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
   /* public lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })*/
    
    @IBAction func scanAction(_ sender: AnyObject) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if result != nil {
                var fullArr = result!.value.characters.split{$0 == ":"}.map(String.init)
                if fullArr[0] == "event" {
                    self.isEvent(eventID: fullArr[1])
                } else if fullArr[0] == "reward" {
                    self.isReward(rewardID: fullArr[1])
                } else {
                    self.isOrg(orgID: fullArr[1])
                }
            }
        }
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    func isEvent(eventID: String) {
        self.appDelegate.ref?.child("chapman").child("events").child("public").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let event = snapshot.value as? NSMutableDictionary {
                event["key"] = eventID
                self.appDelegate.selectedEvent = event as NSDictionary
                if !self.checkinEventIDs.contains(eventID) {
                    self.dbc.checkUserIn(user: self.appDelegate.mainUser!, eventID: eventID)
                    self.dbc.addPointsToUser(user: self.appDelegate.mainUser!, points: event["ptsForAttending"] as! Int)
                    FIRAnalytics.logEvent(withName: "successful_event_checkin", parameters: ["Organization" : ((self.appDelegate.selectedEvent!["orgName"] as? String) as Any as! NSObject),"Event_ID" : ((self.appDelegate.selectedEvent!["key"] as? String) as Any as! NSObject),"Event_Type" : ((self.appDelegate.selectedEvent!["eventType"] as? String) as Any as! NSObject),"Points_Offered" : ((self.appDelegate.selectedEvent!["ptsForAttending"] as? Int) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])

                    let alert = UIAlertController(title: "SUCCESS!", message: "Congratulations, \(event["ptsForAttending"] as! Int) points have been awarded to your account.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.dbc.getUserCheckins(user: self.appDelegate.mainUser!)
                    self.present(alert, animated: true, completion: { () in
                        self.refresh(sender: self)
                    })
                } else {
                    let alert = UIAlertController(title: "FAILURE", message: "You've already recieved points for this event.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func isReward(rewardID: String) {
        self.appDelegate.ref?.child("chapman").child("cashouts").queryOrdered(byChild: "rewardID").queryEqual(toValue: rewardID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.value as? NSDictionary {
                var foundIt: Bool = false
                var cashoutID: String = ""
                for (key, value) in result {
                    if let value = value as? NSDictionary {
                        if (value["userID"] as! String) == self.appDelegate.mainUser!.uid {
                            foundIt = true
                            cashoutID = key as! String
                            break
                        }
                    }
                }
                if foundIt {
                    FIRAnalytics.logEvent(withName: "successful_reward_checkout", parameters: ["Reward_ID" : ((rewardID) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
                    self.appDelegate.ref?.child("chapman").child("cashouts").child(cashoutID).removeValue()
                    let alert = UIAlertController(title: "SUCCESS", message: "Congratulations, you can pick up this reward!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.dbc.getUserCheckins(user: self.appDelegate.mainUser!)
                    self.present(alert, animated: true, completion: { () in
                        self.refresh(sender: self)
                    })
                } else {
                    let alert = UIAlertController(title: "FAILURE", message: "You can't pick up this reward", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func isOrg(orgID: String) {
        //INSERT LOGIC TO AFFILIATE USER TO A PRIVATE ORG
    }
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    public func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    public func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
    public func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }

    
}
extension HomeView: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = self.searchBar!
        
        filterContentForSearchText(searchText: searchBar.text!)
        

        
    }
    
}

extension HomeView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar?.tintColor = UIColor.white
        showFilteredResults = true
        self.searchBar?.showsScopeBar = true
        self.searchBar?.showsCancelButton = true
        tableView?.reloadData()
    } /*func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar?.tintColor = UIColor.clear
        self.searchBar?.showsScopeBar = false
        self.searchBar?.showsCancelButton = false
        showFilteredResults = false
    }*/
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder()
        self.searchBar?.tintColor = UIColor.clear
        self.searchBar?.showsScopeBar = false
        self.searchBar?.showsCancelButton = false
        showFilteredResults = false
        tableView?.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder()
        self.searchBar?.tintColor = UIColor.clear
        self.searchBar?.showsScopeBar = false
        self.searchBar?.showsCancelButton = false
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchBar.text!)
        tableView?.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!)
        tableView?.reloadData()
    }
}

extension Date
{
    init(dateString:String, format: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = format
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        let d = dateStringFormatter.date(from: dateString)!
        //print(d)
        //print(dateString)
        self.init(timeInterval:0, since:d)
    }
}

