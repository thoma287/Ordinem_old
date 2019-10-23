//
//  ReportEvent.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/23/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import Firebase

class ReportEvent: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var reasonForReport: UITextField!
    
    @IBOutlet weak var detailsOfReport: UITextView!
    
    let list = ["Offensive/Uncivil", "Irrelevant", "Unsafe/Illegal", "Spam", "Error"]
    
    
    var picker = UIPickerView()
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        if checkFields(){
            
            let alert = UIAlertController(title: "Event Report", message: "Are you sure you would like to submit this report?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                self.appDelegate.mainUser = FIRAuth.auth()!.currentUser
                
                let cUser = self.appDelegate.mainUser
                
                self.dbc.addEventReport(user: cUser!, type: self.reasonForReport!.text!, report: self.detailsOfReport!.text!)
                
                alert.dismiss(animated: true, completion: nil)
                let alert2 = UIAlertController(title: "Success!", message: "Thank you for your submission!", preferredStyle: UIAlertControllerStyle.alert)
                
                
                alert2.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { (action)  in
                    self.performSegue(withIdentifier: "HomeView", sender: self)
                    
                }))
                self.present(alert2, animated: true, completion: nil)
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return list.count

    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
            reasonForReport.text = list[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return list[row]
    }
    func doneClicked(){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        reasonForReport.inputView = picker
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)

        detailsOfReport.inputAccessoryView = toolBar

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func checkFields() -> Bool{
        if "" == self.detailsOfReport.text{
            let alert = UIAlertController(title: "Alert", message: "Please Enter Details within your report", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.reasonForReport.text{
            let alert = UIAlertController(title: "Alert", message: "Please Enter Your Reason For The Report", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
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
