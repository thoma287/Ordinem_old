//
//  Report.swift
//  
//
//  Created by Drew Thomas on 2/16/17.
//
//

import UIKit
import Firebase

class Report: UIViewController {
    
    @IBOutlet var segSVSR: UISegmentedControl!
    
    @IBOutlet var userInput: UITextView!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    var textIn = ""

    @IBAction func submitButtonPressed(_ sender: UIButton) {
        getInformation()
    }
    
    func getInformation(){
        
        if self.userInput.text != ""{
            self.appDelegate.mainUser = FIRAuth.auth()!.currentUser
            let cUser = self.appDelegate.mainUser
            
            if segSVSR.selectedSegmentIndex == 0{
                let alert = UIAlertController(title: "Suggestion Report", message: "Are you sure you would like to submit this suggestion?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                    
                    self.textIn = (self.userInput.text as String)
                    self.dbc.addSuggestionReport(user: cUser!, report: self.textIn)
                    
                    alert.dismiss(animated: true, completion: nil)
                    let alert2 = UIAlertController(title: "Success!", message: "Thank you for your submission!", preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    alert2.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { (action)  in
                        self.performSegue(withIdentifier: "ProfileView", sender: self)
                        
                    }))
                    self.present(alert2, animated: true, completion: nil)
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
            if segSVSR.selectedSegmentIndex == 1{
                let alert = UIAlertController(title: "Bug Report", message: "Are you sure you would like to submit this suggestion?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                    
                    self.textIn = (self.userInput.text as String)
                    self.dbc.addBugReport(user: cUser!, report: self.textIn)
                    
                    alert.dismiss(animated: true, completion: nil)
                    let alert2 = UIAlertController(title: "Success!", message: "Thank you for your      !", preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    alert2.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { (action) in
                        self.performSegue(withIdentifier: "ProfileView", sender: self)
                        
                    }))
                    self.present(alert2, animated: true, completion: nil)
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
