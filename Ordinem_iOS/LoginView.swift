//
//  ViewController.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 12/11/16.
//  Copyright © 2016 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginView: UIViewController, UITextFieldDelegate {
    
    //LOGIN PAGE
    
    @IBOutlet var emailStr: UILabel?
    @IBOutlet var passStr: UILabel?
    @IBOutlet var emailField: UITextField?
    @IBOutlet var passField: UITextField?
    @IBOutlet var loginButton: UIButton?
    @IBOutlet var createButton: UIButton?
    @IBOutlet var tapView: UIView?
    @IBOutlet var loadingMon: UIActivityIndicatorView?
    //@IBOutlet var accountType: UISwitch?
    @IBOutlet var accountTitle: UILabel?
    
    let dbc: DatabaseConnector = DatabaseConnector()
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func login() {
        loginLogic()
    }
    
    func loginLogic() {
        if checkFields() {
            self.loadingMon!.startAnimating()
            FIRAuth.auth()?.signIn(withEmail: self.emailField!.text!, password: self.passField!.text!) { (user, error) in
                if error != nil {
                    self.loadingMon?.isHidden = true
                    self.loadingMon?.stopAnimating()
                    let alert = UIAlertController(title: "Invalid Email/Password", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    //Create Account within the DB
                    self.appDelegate.mainUser = user!
                    do {
                        try self.appDelegate.mainProfilePic = UIImage(data: Data(contentsOf: user!.photoURL!))
                    } catch {
                        print("couldn't download profile picture")
                    }
                    self.dbc.getRewards()
                    self.loadingMon?.isHidden = true
                    self.loadingMon?.stopAnimating()
                    self.appDelegate.setLoginState(state: true, email: self.emailField!.text!, password: self.passField!.text!)
                    if (user!.displayName! == "admin") {
                        self.performSegue(withIdentifier: "adminLogin", sender: self)
                    } else if user!.isEmailVerified || (user!.displayName! == "org") {
                        self.performSegue(withIdentifier: "login", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "getInfo", sender: self)
                    }
                }
            }
        }
    }
    
    
    @IBAction func forgotPswdButtonPressed(_ sender: UIButton) {
        if self.emailField?.text == ""{
            let alertController = UIAlertController(title: "No email entered", message: "Please enter your email.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            FIRAuth.auth()?.sendPasswordReset(withEmail: (self.emailField?.text!)!, completion: { (error) in
                
                var title = ""
                var message = ""
                if error != nil{
                    title = "Something went wrong!"
                    message = (error?.localizedDescription)!
                }
                else{
                    title = "Success!"
                    message = "A link has been sent to reset your password!"
                }
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            )
        }
        
        
    }
    
    
    func checkFields() -> Bool {
        if (emailField?.text?.isEmpty)! {
            emailStr?.text = "Email* (Required)"
            
            return false
        } else if (passField?.text?.isEmpty)! {
            passStr?.text = "Password* (Required)"
            return false
        } else if !(isValidEmail(testStr: (emailField?.text)!)) {
            emailStr?.text = "Email* (Invalid)"
            return false
        } else {
            return true
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    func doneClicked(){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        emailField!.inputAccessoryView = toolBar
        passField!.inputAccessoryView = toolBar
        
        
        
        appDelegate.loginView = self
        loadingMon?.isHidden = true
        tapView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissKeyboard() {
        emailField?.resignFirstResponder()
        passField?.resignFirstResponder()
    }
    
    func logout() {
        appDelegate.setLoginState(state: false, email: nil, password: nil)
        self.loadingMon?.hidesWhenStopped = true
        self.loadingMon?.stopAnimating()
        self.emailField?.text = ""
        self.passField?.text = ""
    }
    
    @IBAction func backToLogging(segue: UIStoryboardSegue) {
        
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            passField!.becomeFirstResponder()
        }
        else{
            passField!.resignFirstResponder()
        }
        return true
        }


}

