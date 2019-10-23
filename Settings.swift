//
//  Settings.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/24/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class Settings: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var tableView: UITableView!
    
    let destination = UIViewController() // Your destination
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }

    @IBAction func backToSettings(segue: UIStoryboardSegue) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    let SettingCellText = ["Change Profile Picture","Report a Bug/Request", "Delete Account","Reset Password","Create Event", "Find Organizations", "Log Out"]
    
    let userSettings = ["Change Profile Picture","Report a Bug/Request", "Delete Account","Reset Password","Create Event", "Find Organizations","Log Out"]
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "NewProfPic", sender: self)
            
        }
        else if indexPath.row == 1 {
            self.performSegue(withIdentifier: "Report", sender: self)
        }
        else if indexPath.row == 2 {
            let alertController = UIAlertController(title: "Warning!", message: "Are You Sure You Want To Delete Your Account?", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                let cUser = FIRAuth.auth()!.currentUser
                cUser?.delete()
                
                
                
                self.appDelegate.setLoginState(state: false, email: nil, password: nil)
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                let firebaseAuth = FIRAuth.auth()
                do {
                    try firebaseAuth?.signOut()
                } catch let signOutError as NSError {
                    print ("Error Signing Out: %@", signOutError)
                }
                self.performSegue(withIdentifier: "logout", sender: self)
                
            })
            let defaultAction2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertController.addAction(defaultAction2)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else if indexPath.row == 3 {
            if (appDelegate.mainUser?.email)! == ""{
                let alertController = UIAlertController(title: "No email entered", message: "Please enter your email.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                FIRAuth.auth()?.sendPasswordReset(withEmail: (appDelegate.mainUser?.email)!, completion: { (error) in
                    
                    var title = ""
                    var message = ""
                    if error != nil{
                        title = "Something went wrong!"
                        message = (error?.localizedDescription)!
                    }
                    else{
                        title = "Success!"
                        message = "A link has been emailed to reset your password!"
                    }
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                )
            }

            
            /*
             

             */
        } else if indexPath.row == 4 { //add event
            if FIRAuth.auth()?.currentUser?.displayName == "org" {
                if(appDelegate.userDetails!["verified"] as! Bool == false){
                    let alertController = UIAlertController(title: "Alert", message: "Please wait for your account to be verified by your school's administration before creating your event", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                else{
                self.performSegue(withIdentifier: "createEvent", sender: self)
                }
            } else {
                let alertController = UIAlertController(title: "Alert", message: "This feature is yet to be added for regular users", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        else if indexPath.row == 5 {
            self.performSegue(withIdentifier: "findOrg", sender: self)
        }
            
        else if indexPath.row == 6 { //logout
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return SettingCellText.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 77
    }

    let AddEventIdentifier = "CreateEvent"
    let ReportIdentifier = "Report"
    let ChgProfPicIdent = "NewProfPic"
    
    /*func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == AddEventIdentifier,
            let destination = segue.destination as? eventTemp,
        let settingsIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.blogName = SettingCellText[settingsIndex]
        }
    }*/
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell: SettingCell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingCell
            
            cell.addEventLbl?.text = SettingCellText[indexPath.item]
            return cell
    }
    
    
    
}
