//
//  newReward.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/22/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class newReward: UIViewController,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPickerViewDelegate {

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    @IBOutlet weak var awardTitle: UITextField!
    @IBOutlet weak var costInPts: UITextField!
    @IBOutlet weak var closureDate: UITextField!
    @IBOutlet weak var pickupLocation: UITextField!
    @IBOutlet weak var totalPrizes: UITextField!
    @IBOutlet weak var timeAvailableToPickUP: UITextField!
    
    @IBOutlet var winVRaffle: UISegmentedControl!
    @IBOutlet weak var addInfo: UITextView!
    
    @IBOutlet weak var theScrollView: UIScrollView!
    
    let datePicker = UIDatePicker()
    let timeToPickUp = UIDatePicker()
    
    @IBAction func complete(_ sender: UIButton) {
        if checkFields(){
            handleSet()
        }
    }
    
    func handleSet(){
        if checkFields(){
            self.appDelegate.mainUser = FIRAuth.auth()!.currentUser
            
            let cUser = FIRAuth.auth()!.currentUser
            
            var profileImageUrl = ""
            
            //IMAGE INFORMATION
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_Image").child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(self.imagePicked.image!){
                storageRef.put(uploadData, metadata: nil, completion: {
                    (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    else{
                        profileImageUrl = (metadata?.downloadURL()?.absoluteString)!
                        var prize = ""
                        if self.winVRaffle.selectedSegmentIndex == 0{
                            prize = "AutoWin"
                        }
                        if self.winVRaffle.selectedSegmentIndex == 1{
                            prize = "Raffle"
                        }
                        
                        let details = ["rewardTitle": self.awardTitle!.text!,
                                       "pointCost": Int(self.totalPrizes.text!)!,
                                       "closeDate": self.closureDate!.text!,
                                       "pickupLocation": self.pickupLocation!.text!,"timeAvailableToPickUp":self.timeAvailableToPickUP!.text!,
                                       "prizeAmount": Int(self.costInPts.text!)!,
                                       "imageURL": profileImageUrl,
                                       "rewardType": String(prize)!,
                                       "addInfo" : self.addInfo!.text!,
                                       "verified": false] as [String : Any]
                        
                        self.dbc.addReward(user: cUser!, details: details)
                        self.performSegue(withIdentifier: "backHome", sender: self)
                    }
                })
            }
        }
    }
    
    @IBAction func openCameraButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    


    
    @IBAction func dp(sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        self.closureDate.text = dateFormatter.string(from: sender.date)
    }
    
    
    
    @IBAction func timeToPickup(sender: UITextField){
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .time
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePickerForMe), for: .valueChanged)
        //self.timeToPickUp.inputView = datePickerView
    }
    
    
    func handleDatePickerForMe(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        self.timeAvailableToPickUP.text = dateFormatter.string(from: sender.date)
    }
    

    @IBAction func newReward(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func openPhotoLibraryButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {//2
            imagePicked.contentMode = .scaleAspectFit
            imagePicked.image = image
        } else {
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil);
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
    
    
    func closekeyboard() {
        self.view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closekeyboard()
    }
    
    func doneClicked(){
        view.endEditing(true)
    }

    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.theScrollView.contentInset = contentInset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        awardTitle.inputAccessoryView = toolBar
        costInPts.inputAccessoryView = toolBar
        closureDate.inputAccessoryView = toolBar
        pickupLocation.inputAccessoryView = toolBar
        totalPrizes.inputAccessoryView = toolBar
        addInfo.inputAccessoryView = toolBar
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == awardTitle{
            costInPts.becomeFirstResponder()
        }
        else if textField == costInPts{
            closureDate.becomeFirstResponder()
        }
        else if textField == closureDate{
            pickupLocation.becomeFirstResponder()
        }
        else if textField == pickupLocation{
            totalPrizes.becomeFirstResponder()
        }
        else if textField == totalPrizes{
            addInfo.becomeFirstResponder()
        }
        else{
            addInfo.resignFirstResponder()
        }
        return true
    }

    func checkFields() -> Bool {
        if "" == self.awardTitle.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Reward Title", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.costInPts.text {
            let alert = UIAlertController(title: "Alert", message: "Please Cost in Points", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.closureDate.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Closure Date", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.pickupLocation.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Pickup Location", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.totalPrizes.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter The Total Prizes Offered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
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
