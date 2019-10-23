//
//  FBLoginView.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 2/1/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

public class FBLoginView: UIViewController {
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    
    @IBOutlet var fbLoginButton: UIButton?
    @IBOutlet var loadingView: UIView?
    
    let dbc: DatabaseConnector = DatabaseConnector()
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func backToFBLogin(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func goToSignup(_ sender: Any) {
        self.performSegue(withIdentifier: "toSignup", sender: self)
    }
    
    func toLogin() {
        if appDelegate.mainUser!.isEmailVerified{
            self.performSegue(withIdentifier: "fbLogin", sender: self)
        } else {
            self.performSegue(withIdentifier: "getInfo", sender: self)
        }
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        self.loadingView?.alpha = 1
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self.parent, handler: { (result, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                self.loadingView?.alpha = 0
            } else if result!.isCancelled {
                print("Cancelled")
                self.loadingView?.alpha = 0
            } else {
                self.facebookLogin()
            }
        })
    }
    
    func facebookLogin() {
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error2) in
            // ...
            if error2 != nil {
                // ...
                self.loadingView?.alpha = 0
                print(error2!.localizedDescription)
                return
            }
            
            print("successfully logged in with facebook")
            
            self.appDelegate.ref?.child("chapman").child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                var studentID: String = "0"
                var pointBal: Int = 0
                if snapshot.exists() {
                    if let value = snapshot.value as? NSDictionary {
                        studentID = value["studentID"] as! String
                        pointBal = value["pointBalance"] as! Int
                    }
                }
                
                if((FBSDKAccessToken.current()) != nil){
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, age_range, gender"]).start(completionHandler: { (connection, result, error) -> Void in
                        if (error == nil){
                            if var result = result as? [String : Any?] {
                                result["pointBalance"] = pointBal
                                result["studentID"] = studentID
                                result["display_name"] = result["first_name"] as! String
                                result["profileImageURL"] = user!.photoURL!.absoluteString
                                self.dbc.addUser(user: user!, details: result)
                                //self.appDelegate.userDetails = result
                            } else {
                                print("facebook info - incorrect format")
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
                
                self.appDelegate.mainUser = user!
                self.dbc.getRewards()
                do {
                    try self.appDelegate.mainProfilePic = UIImage(data: Data(contentsOf: user!.photoURL!))
                } catch {
                    print("couldn't download profile picture")
                }
                let changeRequest = user!.profileChangeRequest()
                changeRequest.displayName = "user"
                changeRequest.commitChanges() { (error) in
                    // ...
                    if error != nil {
                        print(error!.localizedDescription)
                    }
                }
                self.toLogin()
            })
        }
    }
    
    public override func loadView() {
        super.loadView()
        //(0.1836266259*self.view.frame.width)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingView?.alpha = 0
        //code
        //self.appDelegate.fbLoginButton = self.fbLoginButton
        //loginButton.center = CGPoint(x: self.view.center.x, y: (self.view.center.y/2.0))
        //loginButton.
        //self.view.addSubview(loginButton)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //code
    }
}
