//
//  RewardView.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 1/18/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}



class RewardView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var scanButton: UIButton?
    @IBOutlet var createButton: UIButton?

    @IBOutlet weak var prizeName: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label4Slider: UILabel!
    
    @IBOutlet var userPoints: UILabel!
    @IBOutlet var userName: UILabel!
    
    @IBAction func goToProfile(sender: UIButton) {
        self.appDelegate.fadeTransition(sender: self, destinationVC: ProfileView())
    }
    
    @IBAction func goToHome(sender: UIButton) {
        self.appDelegate.fadeTransition(sender: self, destinationVC: HomeView())
    }
    
    @IBAction func goToCamera(sender: UIButton) {
        self.appDelegate.showCamera = true
        self.appDelegate.fadeTransition(sender: self, destinationVC: HomeView())
    }
    
    var c = ""
    var r = ""
    
    
    let cellID = "cellID"

    public var source: NSArray = []
    var imageSource = [UIImage]()

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()

    
    @IBAction func cashout(segue: UIStoryboardSegue) {
        
    }
    
    func loadUserDetails() {
        if appDelegate.userDetails != nil {
            if let pointBal = appDelegate.userDetails!["pointBalance"] as? Int {
                userPoints?.text = "\(pointBal)"
            }
        }
    }
    
    @IBAction func actionSlider(_ sender: UISlider) {
        let currentValue = Int(slider.value)
        let value = Double(currentValue)
        let current = Double(value/20).roundTo(places: 2)
        let v = (String(format:"%.02f", current))
        label4Slider.text = "\(currentValue) pts = $\(v)"
        
        c = String(currentValue)
        r = String(current)
        
        self.appDelegate.showMeYourTits = currentValue
        self.appDelegate.currentValue = c
        self.appDelegate.dollarValueOfCurrentValue = v
    }
    
    func loadContents(rewards: NSArray) {
        print("Data recieved")
        //print(rewards)
        source = rewards
        self.imageSource = []
        
        for reward in rewards {
            self.imageSource.append(self.appDelegate.rewardPics[(reward as! NSDictionary)["key"] as! String]!)
        }
        tableView?.reloadData()
    }
    
    override func loadView() {
        super.loadView()
        self.loadContents(rewards: self.appDelegate.rewards!)
    }
    

    @IBOutlet weak var theScrollView: UIScrollView!
    
    @IBOutlet weak var rewardName: UILabel!
    
    @IBOutlet weak var rewardType: UILabel!
    
    @IBOutlet weak var points: UILabel!
    
    @IBOutlet weak var result: UILabel!
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func checkClick(_ sender: UIButton) {
        getPrizeInfo()
    }
    
    func loadContents(events: NSArray) {
        print("Data recieved")
        //print(events)
        source = events
        tableView?.reloadData()
    }
    
    
    
    func getPrizeInfo(){
        rewardName = prizeName
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.rewardView = self
        slider.minimumValue = 200
        fetchUser()
        loadUserDetails()
        
        if appDelegate.userDetails != nil {
            if let displayName = appDelegate.userDetails!["display_name"] as? String {
                userName!.text = displayName
            }
            if let pointBal = appDelegate.userDetails!["pointBalance"] as? Int {
                userPoints!.text = "\(pointBal)"
            }
            if appDelegate.mainUser!.displayName == "org" {
                if(appDelegate.userDetails!["verified"] as! Bool == false){
                    createButton?.isEnabled = false
                } else {
                    createButton?.isEnabled = true
                }
            }
        }
        
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
        

    }
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //code
    }
    
    
    func fetchUser(){
        FIRDatabase.database().reference().child("Chapman").child("Admin").observe(.childAdded, with: { (snapshot) in
            
            if (snapshot.value as? [String: AnyObject]) != nil{

                
                //Unsure about what the code right below does.. Just told I should do this
                //Just something to look at if it's something that'll cause trouble when running
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
 
            
        }, withCancel: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code
        tableView.deselectRow(at: indexPath, animated: false)
        self.appDelegate.selectedReward = self.source[indexPath.row] as? NSDictionary
        self.performSegue(withIdentifier: "DetailForReward", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return source.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RewardCell = tableView.dequeueReusableCell(withIdentifier: "RewardCell") as! RewardCell
        
        var eventer: NSDictionary!

        eventer = (self.source[indexPath.row] as! NSDictionary)
        
        cell.rewardID = eventer["key"] as? String
        cell.rewardImage?.layer.cornerRadius = 33
        cell.rewardImage?.layer.masksToBounds = true
        cell.rewardName?.text = eventer["rewardTitle"] as? String
        cell.rewardType?.text = eventer["rewardType"] as? String
        //cell.eventDescription?.text = (self.source?[indexPath.row] as! NSArray)[2] as? String
        //cell.eventID = source?[indexPath.row][2] as? String
        
        //cell.eventDate?.text = (self.source?[indexPath.row] as! NSArray)[4] as? String
        
        if self.imageSource.count == self.source.count {
            cell.rewardImage?.image = self.imageSource[indexPath.row]
        }
        //self.appDelegate.profPics[(self.source[indexPath.row] as! NSDictionary)["orgName"] as! String]
        cell.costForReward?.text = "Cost: \(eventer["pointCost"] as! Int) Points"
        if eventer["rewardType"] as? String == "AutoWin"{
        cell.amountLeft?.text = "\(eventer["prizeAmount"] as! Int) left"
        }
        else{
            cell.amountLeft?.text = "\(eventer["prizeAmount"] as! Int) offered"
        }
        return cell
    }
    
}

