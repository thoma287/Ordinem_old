//
//  winnerPrizes.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/27/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class winnerPrizes: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var segmentController: UISegmentedControl?
    
    let cellID = "cellID"
    
    public var source: NSArray = []
    var imageSource: [[UIImage]] = [[UIImage](),[UIImage]()]
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    var separator : [[[String : Any]]] = [[], []]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbc.getCashoutsForUser(user: self.appDelegate.mainUser!, sender: self)
        self.segmentController?.selectedSegmentIndex = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func winnerRewards(segue: UIStoryboardSegue) {
        
    }
    @IBAction func segmentChanged(_ sender: Any) {
        tableView.reloadData()
    }

    
    
    func loadContents(rewards: NSArray) {
        print("Data recieved")
        //print(rewards)
        source = rewards
        
        //iterate through rewards
            //if reward \type is auto
        
        self.imageSource = [[UIImage](),[UIImage]()]
        self.separator = [[], []]
        
        for shiz in (rewards){
            if let shiz = shiz as? NSDictionary {
                if ((shiz["rewardType"] as! String) == "AutoWin") {
                    self.separator[0].append(shiz as! [String : Any])
                    self.imageSource[0].append(self.appDelegate.rewardPics[(shiz)["key"]as! String]!)
                } else {
                    self.separator[1].append(shiz as! [String : Any])
                    self.imageSource[1].append(self.appDelegate.rewardPics[(shiz)["key"]as! String]!)
                }
            } else {
                print("Quantum defibulator is broken.")
            }
        }
        tableView?.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if separator[self.segmentController!.selectedSegmentIndex].count == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.appDelegate.selectedReward = (self.separator[self.segmentController!.selectedSegmentIndex] as NSArray)[indexPath.row] as? NSDictionary
            if segmentController?.selectedSegmentIndex == 0{
                self.performSegue(withIdentifier: "wonRewardDetail", sender: self)}
            else{
                self.performSegue(withIdentifier: "raffleRewardDetail", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if separator[self.segmentController!.selectedSegmentIndex].count == 0 {
            return 1
        }
        return separator[self.segmentController!.selectedSegmentIndex].count
        //return source.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WonAndRaffleCell = tableView.dequeueReusableCell(withIdentifier: "WonAndRaffleCell") as! WonAndRaffleCell
        if(segmentController?.selectedSegmentIndex == 0){
            if separator[0].isEmpty {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Your Auto-Win Rewards Will Show Up Here"
                cell.textLabel?.textColor = UIColor.lightGray
                cell.textLabel?.textAlignment = .center
                return cell
            }
            cell.rewardName?.text = separator[self.segmentController!.selectedSegmentIndex][indexPath.row]["rewardTitle"] as? String
            cell.type?.text = "Won"
            cell.pointCost.text = "Cost: \(separator[self.segmentController!.selectedSegmentIndex][indexPath.row]["pointCost"] as! Int) points"
            if self.imageSource.count == self.source.count {
                cell.wonImage?.image = self.imageSource[(segmentController?.selectedSegmentIndex)!][indexPath.row]
            }
        }
        else{
            if separator[1].isEmpty {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Your Raffle Rewards Will Show Up Here"
                cell.textLabel?.textColor = UIColor.lightGray
                cell.textLabel?.textAlignment = .center
                return cell
            }
            cell.rewardName?.text = separator[self.segmentController!.selectedSegmentIndex][indexPath.row]["rewardTitle"] as? String
            cell.type?.text = "Raffle"
            cell.pointCost.text = "Cost: \(separator[self.segmentController!.selectedSegmentIndex][indexPath.row]["pointCost"] as! Int) points"
            if self.imageSource.count == self.source.count {
                cell.wonImage?.image = self.imageSource[(segmentController?.selectedSegmentIndex)!][indexPath.row]
            }

        }
        return cell
    }
    
}
