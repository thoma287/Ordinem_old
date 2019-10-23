//
//  FBEmailVerification.swift
//  
//
//  Created by Drew Thomas on 2/11/17.
//
//

import UIKit
import Firebase
import FBSDKLoginKit

class FBEmailVerification: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet var underView: UIView!
    @IBOutlet weak var schoolID: UITextField!
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var doneLabel: UILabel!
    @IBOutlet var sentView: UIView!
    @IBOutlet var messageLabel: UILabel!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var emailText = String()
    var idText = String()
    
    
    @IBAction func donePressed(sender: UIButton) {
        if checkFields() {
            if self.doneLabel.text == "I AGREE & SEND VERIFICATION" {
                self.switchUI()
                self.doneLabel.text = "CONTINUE"
                self.appDelegate.mainUser!.updateEmail(self.email.text!) { (error) in
                    //Shiz
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        self.appDelegate.mainUser!.reload(completion: { (error3) in
                            if error3 != nil {
                                print(error3!.localizedDescription)
                            } else {
                                self.sendVerif(user: self.appDelegate.mainUser!)
                            }
                        })
                    }
                }
            } else {
                self.appDelegate.mainUser!.reload(completion: { (error3) in
                    if error3 != nil {
                        print(error3!.localizedDescription)
                    } else {
                        if self.appDelegate.mainUser!.isEmailVerified{
                            self.performSegue(withIdentifier: "verified", sender: self)
                        } else {
                            let alert = UIAlertController(title: "Alert", message: "Please Verify Your Email To Continue", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    func switchUI() {
        var emailText = self.email.text!
        if self.email.text! == "" {
            emailText = self.appDelegate.mainUser!.email!
        }
        self.messageLabel.text = "We've sent an email to \(emailText), please follow the link to verify your account."
        self.sentView.alpha = 1
        self.email.alpha = 0
        self.schoolID.alpha = 0
        self.underView.alpha = 0
    }
    
    func sendVerif(user: FIRUser) {
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error2) in
            // ...
            if error2 != nil {
                print(error2!.localizedDescription)
            } else {
                self.doneLabel.text = "CONTINUE"
                if self.appDelegate.mainUser!.displayName == "org" {
                    self.appDelegate.ref!.child("chapman").child("organizations").child((FIRAuth.auth()?.currentUser?.uid)!).child("studentID").setValue(self.schoolID!.text!)
                } else if self.schoolID!.text! != "-" {
                    self.appDelegate.ref!.child("chapman").child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("studentID").setValue(self.schoolID!.text!)
                }
                if self.email.text! != "" {
                    self.appDelegate.updateLoginEmail(email: self.email.text!)
                }
                
                let alert = UIAlertController(title: "Email Sent", message: "Please check your email to verify your account", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func checkFields() -> Bool {
        //check that email and id are correct format
        if self.email.text == "" || (!isValidEmail(testStr: email.text!)) {
            return false
        } else if schoolID.text == "" {
            return false
        } else if FBSDKAccessToken.current() != nil && self.email.text?.contains("chapman.edu") == false {
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        self.email.text = emailText
        self.schoolID.text = idText
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        email.inputAccessoryView = toolBar
        schoolID.inputAccessoryView = toolBar
        
        if (FBSDKAccessToken.current() == nil) {
            sendVerif(user: self.appDelegate.mainUser!)
            switchUI()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func doneClicked() {
        email.resignFirstResponder()
        schoolID.resignFirstResponder()
    }
    
    @IBAction func backToEmailVerificationNBS(segue: UIStoryboardSegue) {
        
    }
    
    
    
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
