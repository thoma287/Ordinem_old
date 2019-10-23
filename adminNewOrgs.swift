//
//  adminNewOrgs.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 1/27/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class adminNewOrgs: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var rewardButton: UIButton?
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    @IBOutlet var tbv: UITableView?
    
    var source: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rewardButton?.isEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        super.loadView()
        self.appDelegate.adminView = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dbc.getOrgsNeedVerification()
        if self.appDelegate.rewardsLoaded {
            self.enableRewards()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func adminOrg(segue: UIStoryboardSegue) {
        
    }
    
    func enableRewards() {
        self.rewardButton?.isEnabled = true
    }
    
    func loadContents(data: NSArray) {
        source = data
        tbv!.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code
        tableView.deselectRow(at: indexPath, animated: false)
        self.appDelegate.selectedOrg = self.source[indexPath.row] as? NSDictionary
        self.performSegue(withIdentifier: "DetailForOrg", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return source.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OrgCell = tableView.dequeueReusableCell(withIdentifier: "OrgCell") as! OrgCell
        
        let org = source[indexPath.row] as! NSDictionary
        
        cell.orgID = org["key"] as! String
        cell.orgTitle.text = org["display_name"] as! String
        if self.appDelegate.profPics[org["key"] as! String] != nil {
            cell.orgPic.image = self.appDelegate.profPics[org["key"] as! String]
        }
        return cell
    
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you would like to log out? ", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.appDelegate.setLoginState(state: false, email: nil, password: nil)
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            self.performSegue(withIdentifier: "logout", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
        
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
