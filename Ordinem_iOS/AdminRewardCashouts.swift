//
//  AdminRewardCashouts.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/21/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class AdminRewardCashouts: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!

    let cellID = "cellID"
    public var source: NSArray = []
    var imageSource: [UIImage] = []
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadContents(rewards: self.appDelegate.rewards!)
        self.appDelegate.AdminRewardCashouts = self
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContents(rewards: NSArray) {
        print("Data recieved")
        source = rewards
        for reward in rewards {
            self.imageSource.append(self.appDelegate.rewardPics[(reward as! NSDictionary)["key"] as! String]!)
        }
        tableView?.reloadData()
    }
    
    
    @IBAction func AdminRewardManager(segue: UIStoryboardSegue) {
        
    }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: false)
            self.appDelegate.selectedReward = self.source[indexPath.row] as? NSDictionary
            self.performSegue(withIdentifier: "toRewardCashout", sender: self)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return source.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CashoutRewards = tableView.dequeueReusableCell(withIdentifier: "CashoutRewards") as! CashoutRewards
        
        var eventer: NSDictionary!
        
        eventer = (self.source[indexPath.row] as! NSDictionary)
        
        cell.rewardTitle.text = eventer["rewardTitle"] as? String
        cell.rewardID = eventer["key"] as? String
        //cell.
        
        return cell
    }
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? QRCodeForCashouts {
            vc.r_image = self.appDelegate.rewardPics[(self.appDelegate.selectedReward!)["key"] as! String]!
            vc.r_name = (self.appDelegate.selectedReward!)["rewardTitle"] as? String
            vc.r_id = (self.appDelegate.selectedReward!)["key"] as? String
        }
    }
 

}
