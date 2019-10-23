//
//  ManageEvent.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/17/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ManageEvent: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet var imagePicked: UIImageView!
    
    @IBOutlet var eventTitle: UITextField!
    
    @IBOutlet var eventDate: UITextField!
    
    @IBOutlet var startTime: UITextField!
    
    @IBOutlet var endTime: UITextField!
    
    @IBOutlet var eventType: UITextField!
    
    @IBOutlet var location: UITextField!
    
    @IBOutlet var additionalInfo: UITextView!
    
    @IBOutlet var theScrollView: UIScrollView!
    
    private var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
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
    
    var list = ["Competitive", "Career Development", "Conference", "Educational","Entertainment", "Promotional", "Fundraising", "Other"]
    
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
    
    let dateDatePicker = UIDatePicker()
    let startTimeDatePicker = UIDatePicker()
    let endTimeDatePicker = UIDatePicker()
    
    func createDatePicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        dateDatePicker.datePickerMode = .date
        startTimeDatePicker.datePickerMode = .time
        endTimeDatePicker.datePickerMode = .time
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        
        toolBar.setItems([doneButton], animated: false)
        
        
        eventDate.inputAccessoryView = toolBar
        
        eventDate.inputView = dateDatePicker
        
        startTime.inputAccessoryView = toolBar
        
        startTime.inputView = startTimeDatePicker
        
        endTime.inputAccessoryView = toolBar
        
        endTime.inputView = endTimeDatePicker
        
        
    }
    
    func donePressed(){
        
        
        picker1.delegate = self
        picker1.dataSource = self
        
        //Formatting
        //Date will always be referenced at the start- cannot exceed past midnight
        if eventDate.endEditing(true){
            let dateFormatter = DateFormatter()
            
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .long
            eventDate.text = dateFormatter.string(from: dateDatePicker.date)
        }
        else if startTime.endEditing(true){
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            startTime.text = dateFormatter.string(from: startTimeDatePicker.date)
            self.view.endEditing(true)
        }
        else if endTime.endEditing(true){
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            endTime.text = dateFormatter.string(from: endTimeDatePicker.date)
            self.view.endEditing(true)
        }
        
    }

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker1.delegate = self
        picker1.dataSource = self
        
        eventType.inputView = picker1
        
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
        
        self.eventTitle.text = self.appDelegate.selectedEvent!["eventTitle"] as? String
        self.eventDate.text = self.appDelegate.selectedEvent!["startDate"] as? String
        self.startTime.text = self.appDelegate.selectedEvent!["startTime"] as? String
        self.endTime.text = self.appDelegate.selectedEvent!["endDate"] as? String
        self.eventType.text = self.appDelegate.selectedEvent!["eventType"] as? String
        self.location.text = self.appDelegate.selectedEvent!["location"] as? String
        self.additionalInfo.text = self.appDelegate.selectedEvent!["additionalInfo"] as? String
        if self.appDelegate.profPics[self.appDelegate.selectedEvent!["key"] as! String] != nil {
            self.imagePicked.image = self.appDelegate.profPics[self.appDelegate.selectedEvent!["key"] as! String]
        } else {
            do {
                try self.imagePicked.image = UIImage(data: Data(contentsOf: URL(string: self.appDelegate.selectedEvent!["picURL"] as! String)!))
            } catch {
                print("error")
            }
        }
        
        location.delegate = self
        eventTitle.delegate = self
        additionalInfo.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        

    }
    
    

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Warning!", message: "Are You Sure You Want To Delete This Event?", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.dbc.removeEvent(eventID: self.appDelegate.selectedEvent!["key"] as! String)
            self.performSegue(withIdentifier: "backHome", sender: self)
        })
        let defaultAction2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(defaultAction2)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func submitChanges(_ sender: Any) {
        handleSet()
        
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
                        //Cannot reverse the role due as did within details- get only
                        
                        
                        
                        //picURL: profileImageUrl
                    }
                })
            } else {
                print("failed to upload picture")
            }
            
            if(self.eventTitle.text != self.appDelegate.selectedEvent!["eventTitle"] as? String || self.eventType.text != self.appDelegate.selectedEvent!["eventType"] as? String || self.location.text != self.appDelegate.selectedEvent!["location"] as? String || self.additionalInfo.text != self.appDelegate.selectedEvent!["additionalInfo"] as? String || self.eventDate.text != self.appDelegate.selectedEvent!["startDate"] as? String || self.startTime.text != self.appDelegate.selectedEvent!["startTime"] as? String || self.endTime.text != self.appDelegate.selectedEvent!["endDate"] as? String){
                //update the database event title
                
                //let details = []
                
                dbc.updateEvent(event: self.appDelegate.selectedEvent!, eventTitle: self.eventTitle.text!, startDate: self.eventDate.text!, startTime: self.startTime.text!, endDate: self.endTime.text!, location: self.location.text!, eventType: self.eventType.text!, additionalInfo: self.additionalInfo.text!)
                print(eventDate.text!)
            }
        }
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == eventTitle!{
            eventDate!.becomeFirstResponder()
        }
        else if textField == eventDate!{
            startTime!.becomeFirstResponder()
        }
        else if textField == startTime!{
            endTime!.becomeFirstResponder()
        }
        else if textField == endTime!{
            eventType!.becomeFirstResponder()
        }
        else if textField == eventType!{
            location!.becomeFirstResponder()
        }
        else if textField == location!{
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
        else if "" == self.eventDate.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Start Time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.startTime.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter the End Time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.endTime.text {
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
