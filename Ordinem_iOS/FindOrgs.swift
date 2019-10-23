//
//  FindOrgs.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 3/20/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class FindOrgs: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate {

    
    @IBOutlet var tableView: UITableView?
    
    @IBOutlet var searchBar: UISearchBar?
    
    var source: NSArray = []
    
    var modelAry = [NSDictionary]()
    var filteredAry = [NSDictionary]()
    
    var showFilteredResults: Bool = false
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    
    
    var orgTypeIndices: [String] = [String]()
    var orgsByType: [String : [NSDictionary]] = [:]
    
    func generateModelArray() -> [NSDictionary]{
        return modelAry
    }
    
    func filterContentForSearchText(searchText: String){
        self.filteredAry = self.modelAry.filter{evnt in
            tableView?.reloadData()
                tableView?.reloadData()
                let typeMatch = evnt["orgName"] as? String
                return ((typeMatch?.lowercased().contains(searchText.lowercased()))!)
            
        }
        tableView?.reloadData()
    }

    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dbc.getVerifiedOrgs()
    }
    
    func loadContents(orgs: NSArray) {
        source = orgs
        tableView!.reloadData()
        
        
        modelAry = orgs as! [NSDictionary]
        orgsByType.removeAll()
        orgTypeIndices.removeAll()
        
        for org: NSDictionary in modelAry{
            
            if var orgsAry: [NSDictionary] = orgsByType[org["orgType"] as! String] {
                orgsAry.append(org)
                orgsByType[org["orgType"] as! String] = orgsAry
            }
            else {
                orgsByType[org["orgType"] as! String] = [org]
                
                orgTypeIndices.append(org["orgType"] as! String)
            }

        }
        tableView?.reloadData()
        
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if showFilteredResults {
            return 1
        } else {
            return orgTypeIndices.count
        }
    }
    
    var numRows: Int = 0
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if showFilteredResults {
            self.appDelegate.selectedOrg = self.filteredAry[indexPath.row]
            self.performSegue(withIdentifier: "orgProfileSegue", sender: self)
            
        } else if ((indexPath.section == (self.orgsByType.count - 1)) && (indexPath.row == self.orgsByType[orgTypeIndices[indexPath.section]]!.count) && !showFilteredResults){
            //do nothing
        }
        else if (showFilteredResults && indexPath.row == self.numRows){
            //do nothing
        }
        else{
            self.appDelegate.selectedOrg = self.orgsByType[orgTypeIndices[indexPath.section]]![indexPath.row]
            self.appDelegate.selectedOrgs = tableView.cellForRow(at: indexPath) as? VerifiedOrgs
            self.performSegue(withIdentifier: "orgProfileSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showFilteredResults {
            //TOOK OUT THE 1 IN THIS CASE BECAUSE WE DON'T HAVE THE EXTRA CELL HERE
            return filteredAry.count
        } else {
            if section == (self.orgsByType.count - 1) {
                
            //TOOK OUT THE 1 IN THIS CASE BECAUSE WE DON'T HAVE THE EXTRA CELL HERE
                return self.orgsByType[orgTypeIndices[section]]!.count
            //print("num events: \(self.eventsByDate[dateIndices[section]]!.count) in last section (+1)")
                

            } else {
                return self.orgsByType[orgTypeIndices[section]]!.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if showFilteredResults {
            return "Search Results"
        } else {
            return orgTypeIndices[section]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath.section == (self.orgsByType.count - 1)) && (indexPath.row == self.orgsByType[orgTypeIndices[indexPath.section]]!.count) && !showFilteredResults) {
            return 200
        } else if (showFilteredResults && indexPath.row == filteredAry.count) {
            return 200
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventer: NSDictionary!
        
        if ((indexPath.section == (self.orgsByType.count - 1)) && (indexPath.row == self.orgsByType[orgTypeIndices[indexPath.section]]!.count) && !showFilteredResults) {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "empty")!
            return cell
        }
        
        if (showFilteredResults && indexPath.row >= filteredAry.count) {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "empty")!
            return cell
        }
        
        if showFilteredResults && filteredAry.isEmpty {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "empty")!
            return cell
        }
        
        if showFilteredResults {
            eventer = filteredAry[indexPath.row]
        }
        else {
            eventer = (self.orgsByType[orgTypeIndices[indexPath.section]]![indexPath.row])
        }


        
        
        let cell: VerifiedOrgs = tableView.dequeueReusableCell(withIdentifier: "VerifiedOrgs") as! VerifiedOrgs
        cell.orgData = eventer
        
        let org = source[indexPath.row] as! NSDictionary
        
        cell.orgID! = (org["key"] as? String)!
        cell.orgName!.text = (org["display_name"] as? String)!
        if self.appDelegate.profPics[org["key"] as! String] != nil {
            cell.profPic!.image = self.appDelegate.profPics[org["key"] as! String]
        }
 
        return cell
 
        
    }

    func refresh(sender:AnyObject?) {
        dbc.getOrgs()
        dbc.getUserCheckins(user: self.appDelegate.mainUser!)
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


extension FindOrgs: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar?.tintColor = UIColor.white
        showFilteredResults = true
        self.searchBar?.showsScopeBar = true
        self.searchBar?.showsCancelButton = true
        tableView?.reloadData()
    }
    /*func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar?.tintColor = UIColor.clear
        self.searchBar?.showsScopeBar = false
        self.searchBar?.showsCancelButton = false
        showFilteredResults = false
    }*/
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder()
        self.searchBar?.tintColor = UIColor.clear
        self.searchBar?.showsScopeBar = false
        self.searchBar?.showsCancelButton = false
        showFilteredResults = false
        tableView?.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder()
        self.searchBar?.tintColor = UIColor.clear
        self.searchBar?.showsScopeBar = false
        self.searchBar?.showsCancelButton = false
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchBar.text!)
        tableView?.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!)
        tableView?.reloadData()
    }
}

