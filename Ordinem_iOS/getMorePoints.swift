//
//  getMorePoints.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/30/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import Foundation
import Stripe

class getMorePoints: UIViewController, STPPaymentCardTextFieldDelegate {
    
    
    
    
    @IBOutlet weak var countPlaceHolder: UILabel!
    @IBOutlet weak var projectedAttendance: UITextField!
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var projectedCost: UILabel!
    
    var points = Int(1)
    var attendance = Double(1)
    var real = Double(1)
    
    @IBAction func pointStepperA(_ sender: Any) {
        countPlaceHolder.text = String(Int(stepper.value))
    }
    
    func getPoints() -> Int{
        self.points = Int(Double(countPlaceHolder.text!)!)
        return self.points
    }
    
    func getPointss() -> Double{
        self.real = Double(getPoints())
        return self.real
    }
    
    func attToInt() -> Double{
        self.attendance = Double(projectedAttendance.text!)!
        return self.attendance
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let total = Double(getPointss()*attToInt()*0.05*1.05)
        let r = Double(total).roundTo(places: 2)
        let k = (String(format:"%.02f", r))
        projectedCost.text = "$\(k)"
        
    }
    
    
    @IBOutlet weak var buyButton: UIButton!

    
    @IBAction func calcHome(segue: UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        

        
        stepper.maximumValue = 99
        stepper.stepValue = 1
        
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        
        projectedAttendance.inputAccessoryView = toolBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doneClicked(){
        view.endEditing(true)
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
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
