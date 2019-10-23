//
//  sSignUp.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/20/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class sSignUp: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var studentID: UITextField!
    @IBOutlet weak var school: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var verifyPwd: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var scrollRect: CGRect = CGRect()
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    @IBOutlet var loadingView: UIView?
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    
    
    
    @IBAction func openPhotoLibraryButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)

        }
    }
    
    /*func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        imagePicked.image = image
        self.dismiss(animated: true, completion: nil);
    }*/
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {//2
            imagePicked.contentMode = .scaleAspectFit
            imagePicked.image = image
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }

    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.scrollView.contentInset = contentInset
    }
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView.tag == 0{
            return list.count
        }
        else{
            return types.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        school.text = list[row]

    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    

    
    @IBAction func doneClicked(sender: UIButton){
        
        view.endEditing(true)
        if checkFields() {
            // CREATE NEW USER
            self.loadingView?.alpha = 1
            FIRAuth.auth()?.createUser(withEmail: self.email!.text!, password: self.password!.text!) { (user, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    let alert = UIAlertController(title: "Alert", message: "An Unknown Error Occured, Please Try Again Later", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                        self.loadingView?.alpha = 0
                    }))
                    self.present(alert, animated: true, completion: nil)
                    print(error.debugDescription)
                } else {
                    var profileImageUrl = ""
                    
                    //IMAGE INFORMATION
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("Chapman").child("Users").child("profile_Image").child("\(imageName).png")
                    
                    if self.imagePicked.image == nil {
                        self.imagePicked.image = UIImage(imageLiteralResourceName: "Profile_Pic-1.png")
                    }
                    
                    self.appDelegate.mainProfilePic = self.imagePicked.image!
                    
                    if let uploadData = UIImagePNGRepresentation(self.imagePicked.image!){
                        storageRef.put(uploadData, metadata: nil, completion: {
                            (metadata, error) in
                            if error != nil{
                                print(error.debugDescription)
                                self.loadingView?.alpha = 0
                                return
                            }
                            else{
                                profileImageUrl = (metadata?.downloadURL()?.absoluteString)!
                                self.appDelegate.mainUser = user
                                self.dbc.getRewards()
                                let details: [String : Any] = ["display_name": self.fName!.text!, "first_name": self.fName!.text!, "last_name": self.lastName!.text!, "studentID": self.studentID!.text!, "school": self.school!.text!, "profileImageURL": profileImageUrl, "pointBalance" : 0]
                                self.appDelegate.userDetails = details
                                self.dbc.addUser(user: user!, details: details)
                                self.appDelegate.setLoginState(state: true, email: self.email!.text!, password: self.password!.text!)
                                let changeRequest = user!.profileChangeRequest()
                                changeRequest.displayName = "user"
                                changeRequest.photoURL = URL(string: profileImageUrl)!
                                changeRequest.commitChanges() { (error) in
                                    // ...
                                    if error != nil {
                                        print(error!.localizedDescription)
                                    }
                                }
                                self.loadingView?.alpha = 0
                                self.performSegue(withIdentifier: "slogin", sender: self)
                            }
                        })
                    }  
                }
            }
        }
    }
    
    var list = ["Chapman University"]
    var picker1 = UIPickerView()
    
    var types = ["Academic/Professional", "Civic Engagement","Diversity/ Cultural","Greek","Honor Society","Sport", "Leisure", "Recreational","Religious/Spiritual"]
    
    var picker2 = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker1.tag = 0
        picker2.tag = 1
        
        picker1.delegate = self
        picker1.dataSource = self
        
        self.loadingView?.alpha = 0
        
        self.imagePicked.layer.masksToBounds = true
        self.imagePicked.layer.cornerRadius = self.imagePicked.frame.width/2
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.resignResponders))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)

        school.inputView = picker1
        // Do any additional setup after loading the view.
        
        fName.inputAccessoryView = toolBar
        lastName.inputAccessoryView = toolBar
        studentID.inputAccessoryView = toolBar
        school.inputAccessoryView = toolBar
        email.inputAccessoryView = toolBar
        password.inputAccessoryView = toolBar
        verifyPwd.inputAccessoryView = toolBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        fName.delegate = self
        lastName.delegate = self
        studentID.delegate = self
        school.delegate = self
        email.delegate = self
        password.delegate = self
        verifyPwd.delegate = self
        
        
        self.scrollRect = fName.frame
    }

    func resignResponders() {
        self.fName!.resignFirstResponder()
        self.lastName!.resignFirstResponder()
        self.studentID!.resignFirstResponder()
        self.school!.resignFirstResponder()
        self.email!.resignFirstResponder()
        self.password!.resignFirstResponder()
        self.verifyPwd!.resignFirstResponder()
    }
    
    func adjustForKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        //let selectedRange = theScrollVie
        //theScrollView.frame.width
        //CGRect(x: 0, y: 0, width: 1, height: 1)
        
        scrollView.scrollRectToVisible(self.scrollRect, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.fName{
            self.scrollRect = lastName.frame
            self.lastName!.becomeFirstResponder()
        }
        else if textField == self.lastName{
            self.scrollRect = studentID.frame
            self.studentID!.becomeFirstResponder()
        }
        else if textField == self.studentID{
            self.scrollRect = school.frame
            self.school!.becomeFirstResponder()
        }
        else if textField == self.school{
            self.scrollRect = email.frame
            self.email!.becomeFirstResponder()
        }
        else if textField == self.email{
            self.scrollRect = password.frame
            self.password!.becomeFirstResponder()
        }
        else if textField == self.password{
            self.scrollRect = verifyPwd.frame
            self.verifyPwd!.becomeFirstResponder()
        }
        else{
            self.verifyPwd!.resignFirstResponder()
        }
        return true
    }
    
    func checkFields() -> Bool {
        if "" == self.fName.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter First Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.lastName.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Last Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.studentID.text {
            let alert = UIAlertController(title: "Alert", message: "Incorrect Student ID", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.school.text {
            let alert = UIAlertController(title: "Alert", message: "Please Select Your School", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if ("" == self.email.text! || isValidEmail(testStr: self.email.text!) == false || self.email.text!.contains("chapman.edu") == false) { //
            let alert = UIAlertController(title: "Alert", message: "Invalid Student Email", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.password.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Your Password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if self.password.text != self.verifyPwd.text{
            let alert = UIAlertController(title: "Alert", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? FBEmailVerification {
            vc.emailText = self.email!.text!
            vc.idText = self.studentID!.text!
        }
    }
}
