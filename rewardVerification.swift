//
//  rewardVerification.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/27/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class rewardVerification: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var eSig: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var theScrollView: UIScrollView!
    
    let datePicker = UIDatePicker()
    
    func doneClicked(){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eSig.delegate = self
        password.delegate = self
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        eSig.inputAccessoryView = toolBar
        password.inputAccessoryView = toolBar
        

        // Do any additional setup after loading the view.
    }
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.theScrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.theScrollView.contentInset = contentInset
    }

  
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(_ sender: UIButton) {
        if checkFields(){
            //Do something
        }
    }
    func checkFields() -> Bool {
        if "" == self.eSig.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Your E-Signature", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
            //TODO: Check if password for the real thang is equal
        else if "" == self.password.text {
            let alert = UIAlertController(title: "Alert", message: "Incorrect Password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else{
            return true
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == eSig{
            password!.becomeFirstResponder()
        }
        else{
            password!.resignFirstResponder()
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
