//
//  PointView.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 12/18/16.
//  Copyright © 2016 Ordinem. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FirebaseAuth

public class PointView: UIViewController {
    
    @IBOutlet var pointBal: UILabel?
    //@IBOutlet weak var stepper: UIStepper!
    //@IBOutlet weak var projectedAttendance: UITextField!
    //@IBOutlet weak var projectedCost: UILabel!
    
    //@IBAction func stepperStepped(_ sender: UIStepper) {
    //    pointBal!.text = String(Int(sender.value))
    //}
    
    /*
    var points = Double(1)
    var attendance = Double(1)
    
    
    func getPoints() -> Double{
        self.points = Double(pointBal!.text!)!
        return self.points
    }
    
    func attToInt() -> Double{
        self.attendance = Double(projectedAttendance.text!)!
        return self.attendance
    }

    @IBAction func calcPressed(_ sender: UIButton) {
        let total = Double(getPoints()*attToInt()*0.05*1.05)
        projectedCost.text = String(total)
    }
    */
    
    
    @IBAction func backedHome(segue: UIStoryboardSegue) {
        
    }
    
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func logout(sender: UIButton) {
        appDelegate.setLoginState(state: false, email: nil, password: nil)
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    @IBAction func backHome(segue: UIStoryboardSegue) {
        
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.pointBal?.text = "\(appDelegate.userDetails!["pointBalance"] as! Int)"
        //code

        //stepper.maximumValue = 99
        //stepper.stepValue = 1
        // Do any additional setup after loading the view.
        
        
        /*
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        
        //projectedAttendance.inputAccessoryView = toolBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

        */
    }
    
   // @IBOutlet weak var theScrollView: UIScrollView!
    /*
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
    */
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //code
    }
}
