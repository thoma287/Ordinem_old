//
//  pantherBucksRewards.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/22/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import FirebaseAnalytics

class pantherBucksRewards: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var pantherBucks: UILabel!
    
    @IBOutlet weak var pointCost: UILabel!
    
    @IBOutlet weak var rewardDollar: UILabel!
    
    @IBAction func submitPressed(_ sender: UIButton) {
        let ptBal = appDelegate.userDetails!["pointBalance"] as! Int
        
        
        let ptCost = appDelegate.showMeYourTits
        let moneys = self.appDelegate.dollarValueOfCurrentValue
        
        if(ptBal >= ptCost){
            
            FIRAnalytics.logEvent(withName: "attempted_panther_bucks_reward_purchase", parameters: ["Reward_Name" : (("Panther_Bucks") as Any as! NSObject),"Point_Cost" : ((self.appDelegate.currentValue) as Any as! NSObject),"Dollar_Cost" : ((self.appDelegate.dollarValueOfCurrentValue) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
            
            let alert = UIAlertController(title: "Cash Out", message: "Are you sure you would like to cash out on \(moneys) ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { (action) in
                self.handleFunction()
                alert.dismiss(animated: true, completion: nil)
                let alert2 = UIAlertController(title: "Success!", message: "$\(moneys) will be added to your account within the next 48 hours.", preferredStyle: UIAlertControllerStyle.alert)
                
                FIRAnalytics.logEvent(withName: "panther_bucks_reward_success", parameters: ["Reward_Name" : (("Panther_Bucks") as Any as! NSObject),"Point_Cost" : ((self.appDelegate.currentValue) as Any as! NSObject),"Dollar_Cost" : ((self.appDelegate.dollarValueOfCurrentValue) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
                
                alert2.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { (action2) in
                    self.appDelegate.fadeTransition(sender: self, destinationVC: ProfileView())
                }))
                self.present(alert2, animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Not enough points", message: "You're gonna need more points than that if you want a reward this great!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: { () in
                self.performSegue(withIdentifier: "RewardView", sender: self)
            })
            
        }
    }
    
    func handleFunction(){
        let cUser = self.appDelegate.mainUser
        let rewardID = "pantherBucks"
        let timeStamping = Date.timeIntervalBetween1970AndReferenceDate
        let ptCost = appDelegate.showMeYourTits
        let userIDing = cUser?.uid
        dbc.addPointsToUser(user: cUser!, points: (-ptCost))
        dbc.addCashouts(user: cUser!, rewardID: rewardID, userID: userIDing!, timeStamp: timeStamping, numPts: ptCost)
    }
    
    @IBOutlet weak var theScrollView: UIScrollView!

    func closekeyboard() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closekeyboard()
    }
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pointCost.text = "\(appDelegate.currentValue) points"
        self.rewardDollar.text = "$ \(appDelegate.dollarValueOfCurrentValue)"
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

        FIRAnalytics.logEvent(withName: "panther_bucks_reward_viewed", parameters: ["Reward_Name" : (("Panther_Bucks") as Any as! NSObject),"Point_Cost" : ((self.appDelegate.currentValue) as Any as! NSObject),"Dollar_Cost" : ((self.appDelegate.dollarValueOfCurrentValue) as Any as! NSObject),"User_ID" : ((self.appDelegate.mainUser!.uid) as Any as! NSObject),"Student_ID" : ((self.appDelegate.userDetails?["studentID"] as? String) as Any as! NSObject)])
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
