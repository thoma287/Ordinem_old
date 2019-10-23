//
//  otherRewards.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/22/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import FirebaseAnalytics


class otherRewards: UIViewController, MFMailComposeViewControllerDelegate{

    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var endDate: UILabel!
    
    @IBOutlet weak var pointCost: UILabel!
    
    @IBOutlet weak var awardsAvailable: UILabel!
    
    @IBOutlet weak var addInfo: UITextView!
    
    
    @IBOutlet weak var theScrollView: UIScrollView!
    
    var selfRef: otherRewards?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfRef = self
        self.name?.text = self.appDelegate.selectedReward!["rewardTitle"] as? String
        self.type?.text = self.appDelegate.selectedReward!["rewardType"] as? String
        self.endDate?.text = "Available until: \(self.appDelegate.selectedReward!["closeDate"] as! String)"
        self.pointCost?.text = "Cost: \(self.appDelegate.selectedReward!["pointCost"] as! Int) Points"
        self.awardsAvailable?.text = "Only \(self.appDelegate.selectedReward!["prizeAmount"] as! Int) Left!"
        self.addInfo?.text = self.appDelegate.selectedReward!["addInfo"] as? String
        
        //CONTESTANTS NOT ADDED.. MAY WANT TO DELETE
        
        FIRAnalytics.logEvent(withName: "particular_reward_viewed", parameters: ["Reward_Name" : ((self.appDelegate.selectedReward!["rewardTitle"] as? String) as Any as! NSObject),"Reward_Type" : ((self.appDelegate.selectedReward!["rewardType"] as? String) as Any as! NSObject),"Point_Cost" : ((self.appDelegate.selectedReward!["prizeAmount"] as? Int) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
        
        if self.appDelegate.rewardPics[self.appDelegate.selectedReward!["key"] as! String] != nil {
            self.image.image = self.appDelegate.rewardPics[self.appDelegate.selectedReward!["key"] as! String]
        } else {
            do {
                try self.image.image = UIImage(data: Data(contentsOf: URL(string: self.appDelegate.selectedReward!["picURL"] as! String)!))
            } catch {
                print("error")
            }
        }

        if (self.appDelegate.selectedReward!["rewardType"] as! String) != "AutoWin" {
            self.awardsAvailable?.text = ""
        }
        
        
        if #available(iOS 10.0, *) {
            self.addInfo!.adjustsFontForContentSizeCategory = true
        } else {
            self.addInfo!.font?.withSize(13)
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    let destination = UIViewController() // Your destination
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    



    @IBAction func submitPressed(_ sender: UIButton) {
        let ptBal = appDelegate.userDetails!["pointBalance"] as! Int
        
        let ptCost = self.appDelegate.selectedReward!["pointCost"] as! Int
        
        FIRAnalytics.logEvent(withName: "Cash_Out_Attempted", parameters: ["Reward_Name" : ((self.appDelegate.selectedReward!["rewardTitle"] as? String) as Any as! NSObject),"Reward_Type" : ((self.appDelegate.selectedReward!["rewardType"] as? String) as Any as! NSObject),"Point_Cost" : ((self.appDelegate.selectedReward!["prizeAmount"] as? Int) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
        
        if(ptBal >= ptCost){
            
            
            let alert = UIAlertController(title: "Cash Out", message: "Are you sure you would like to cash out on \(self.appDelegate.selectedReward!["rewardTitle"] as! String) ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                self.handleFunction()
                alert.dismiss(animated: true, completion: nil)
                let alert2 = UIAlertController(title: "Success!", message: "\(self.appDelegate.selectedReward!["rewardTitle"] as! String) has been added to your reward bank!", preferredStyle: UIAlertControllerStyle.alert)
                
                FIRAnalytics.logEvent(withName: "particular_reward_attempted_purchase_success", parameters: ["Reward_Name" : ((self.appDelegate.selectedReward!["rewardTitle"] as? String) as Any as! NSObject),"Reward_Type" : ((self.appDelegate.selectedReward!["rewardType"] as? String) as Any as! NSObject),"Point_Cost" : ((self.appDelegate.selectedReward!["prizeAmount"] as? Int) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
                
                alert2.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { (action) in
                    self.appDelegate.fadeTransition(sender: self, destinationVC: ProfileView())
                }))
                self.present(alert2, animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        else {
            let alert = UIAlertController(title: "Not enough points", message: "You're gonna need more points than that if you want a reward this great!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: { () in
                self.performSegue(withIdentifier: "RewardView", sender: self)
            })
            
            }
    }
    
    func handleFunction(){
        let cUser = self.appDelegate.mainUser
        let rewardID = self.appDelegate.selectedReward!["key"] as! String
        let timeStamping = Date.timeIntervalBetween1970AndReferenceDate
        let ptCost = self.appDelegate.selectedReward!["pointCost"] as! Int
        let userIDing = cUser?.uid
        if (self.appDelegate.selectedReward!["rewardType"] as! String) == "AutoWin" {
            self.awardsAvailable?.text = "Only \((self.appDelegate.selectedReward!["prizeAmount"] as! Int)-1) Left!"
            dbc.updateRewardAmount(rewardID: rewardID, numLeft: (self.appDelegate.selectedReward!["prizeAmount"] as! Int)-1)
        }
        dbc.addPointsToUser(user: cUser!, points: (-ptCost))
        dbc.addCashouts(user: cUser!, rewardID: rewardID, userID: userIDing!, timeStamp: timeStamping, numPts: ptCost)
        self.dbc.getRewards()
    }
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.theScrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.theScrollView.contentInset = contentInset
    }
    
        func doneClicked(){
        view.endEditing(true)
    }
    
    func closekeyboard() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closekeyboard()
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
