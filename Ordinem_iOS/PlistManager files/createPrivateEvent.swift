//
//  createPrivateEvent.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 3/25/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import Firebase


class createPrivateEvent: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    
    @IBOutlet var pointBalance: UILabel?
    @IBOutlet var resetDate: UILabel?
    
    var pointsRemaining: Int = 0
    
    @IBAction func complete(_ sender: UIButton) {
        //handleSet()
    }
    
    @IBOutlet weak var eventTitle: UITextField!
    
    @IBOutlet weak var date: UITextField!
    
    @IBOutlet weak var eDate: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var eventType: UITextField!
    
    @IBOutlet weak var additionalInfo: UITextField!
    
    @IBOutlet weak var theScrollView: UIScrollView!
    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var label4Stepper: UILabel!
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        let currentValue = Int(sender.value)
        if currentValue <= 10 && currentValue <= pointsRemaining {
            label4Stepper.text = String(currentValue)
            pointBalance?.text = String(pointsRemaining - currentValue)
        } else {
            sender.value -= 1.0
            self.stepperPressed(sender)
        }
        
    }
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func handleSet(){
        if checkFields(){
            self.appDelegate.mainUser = FIRAuth.auth()!.currentUser
            
            let cUser = self.appDelegate.mainUser
            
            var profileImageUrl = ""
            
            //IMAGE INFORMATION
            //let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_Image").child("\(cUser!.uid).png")
            
            if let uploadData: Data = UIImagePNGRepresentation(self.imagePicked.image!){
                storageRef.put(uploadData, metadata: nil, completion: {
                    (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    else{
                        profileImageUrl = (metadata?.downloadURL()?.absoluteString)!
                        let details: [String : Any?] = ["eventTitle": self.eventTitle!.text!,
                                                        "startDate": self.dateOfEvent,
                                                        "startTime":self.timeOfEvent,
                                                        "endDate": self.eDate!.text!,
                                                        "location": self.location!.text!,
                                                        "eventType": self.eventType!.text!,
                                                        "additionalInfo":self.additionalInfo!.text!,
                                                        "ptsForAttending" : Int(self.stepper.value),
                                                        "picURL": profileImageUrl,
                                                        "orgID": cUser!.uid,
                                                        "orgName": self.appDelegate.userDetails!["display_name"] as! String]
                        self.dbc.addPrivateEvent(user: cUser!, details: details, pointsRemaining: (self.pointsRemaining - Int(self.stepper.value)))
                    }
                })
            } else {
                print("failed to upload picture")
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {//2
            imagePicked.contentMode = .scaleAspectFit
            imagePicked.image = image
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var list = ["Competitive", "Career Development", "Conference", "Ceremony","Educational","Entertainment", "Fundraising","Meeting","Networking","Promotional", "Retreat","Other"]
    
    var picker1 = UIPickerView()
    
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return list.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventType.text = list[row]
        
        
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    
    
    let datePicker = UIDatePicker()
    let datePickerr = UIDatePicker()
    
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
    
    
    func closekeyboard() {
        self.view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closekeyboard()
    }
    
    func doneClicked(){
        view.endEditing(true)
    }
    
    func createDatePicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        datePickerr.datePickerMode = .time
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        
        toolBar.setItems([doneButton], animated: false)
        
        
        date.inputAccessoryView = toolBar
        
        date.inputView = datePicker
        
        eDate.inputAccessoryView = toolBar
        
        eDate.inputView = datePickerr
        
    }

    var timeOfEvent = ""
    var dateOfEvent = ""
    
    @IBAction func updateDateEndText(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .time
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleTimePicker), for: .valueChanged)
    }
    
    func handleTimePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        eDate.text = dateFormatter.string(from: sender.date)
    }
    
    
    @IBAction func dp(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .dateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        date.text = "\(dateFormatter.string(from: sender.date)) \(timeFormatter.string(from: sender.date))"
        timeOfEvent = timeFormatter.string(from: sender.date)
        dateOfEvent = dateFormatter.string(from: sender.date)
    }
    
    func donePressed(){
        
        picker1.delegate = self
        picker1.dataSource = self
        
        //Formatting
        //Date will always be referenced at the start- cannot exceed past midnight
        if date.endEditing(true){
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "MMMM d, yyyy"
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            
            date.text = "\(dateFormatter.string(from: datePicker.date)) \(timeFormatter.string(from: datePicker.date))"
            timeOfEvent = timeFormatter.string(from: datePicker.date)
            dateOfEvent = dateFormatter.string(from: datePicker.date)
        }
        else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            eDate.text = dateFormatter.string(from: datePickerr.date)
            self.view.endEditing(true)
        }
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker1.delegate = self
        picker1.dataSource = self
        
        eventType.inputView = picker1
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        createDatePicker()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        
        
        location.inputAccessoryView = toolBar
        eventTitle.inputAccessoryView = toolBar
        eventType.inputAccessoryView = toolBar
        additionalInfo.inputAccessoryView = toolBar
        
        
        location.delegate = self
        eventTitle.delegate = self
        additionalInfo.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if self.appDelegate.userDetails != nil {
            self.pointsRemaining = self.appDelegate.userDetails!["allowance"] as! Int
            self.resetDate?.text = self.appDelegate.userDetails!["resetDate"] as? String
        }
        
        self.pointBalance?.text = String(self.pointsRemaining)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == eventTitle!{
            date!.becomeFirstResponder()
        }
        else if textField == date!{
            eDate!.becomeFirstResponder()
        }
        else if textField == eDate!{
            location!.becomeFirstResponder()
        }
        else if textField == location!{
            eventType!.becomeFirstResponder()
        }
        else if textField == eventType!{
            additionalInfo!.becomeFirstResponder()
        }
        else{
            additionalInfo!.resignFirstResponder()
        }
        return true
    }

    
    func checkFields() -> Bool {
        if "" == self.eventTitle.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Event Title", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.eventType.text {
            let alert = UIAlertController(title: "Alert", message: "Please Select Event Type", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.date.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Start Time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.eDate.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter the End Time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.location.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter The Location of the Event", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    

}
