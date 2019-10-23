//
//  OrgPrivateAccessRequest.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 3/24/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAuth

class OrgPrivateAccessRequest: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    var source: NSArray = []
    
    
    override func loadView() {
        super.loadView()
        //TODO
        //self.appDelegate.adminView = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dbc.getUserVerificationsForOrgs(orgID: (self.appDelegate.mainUser?.uid)!)
    }
    
    func loadContents(data: NSArray){
        source = data
        tableView!.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code
        tableView.deselectRow(at: indexPath, animated: false)
        self.appDelegate.selectedUserForDetails = self.source[indexPath.row] as? NSDictionary
        self.performSegue(withIdentifier: "showRequestDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return source.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PrivateRequestCell = tableView.dequeueReusableCell(withIdentifier: "PrivateRequestCell") as! PrivateRequestCell
        
        let org = source[indexPath.row] as! NSDictionary
        
        cell.userID = org["key"] as? String
        cell.name.text = "\(org["first_name"] as! String) \(org["last_name"] as! String)"
        if self.appDelegate.profPics[org["key"] as! String] != nil {
            cell.profileImage?.image = self.appDelegate.profPics[org["key"] as! String]
        }
        return cell
        
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
