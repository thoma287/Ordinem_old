//
//  SignUp.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 1/18/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUp: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var orgName: UITextField!
    @IBOutlet weak var orgType: UITextField!
    @IBOutlet weak var orgID: UITextField!
    @IBOutlet weak var skewl: UITextField!
    @IBOutlet weak var sEmail: UITextField!
    @IBOutlet weak var sPassword: UITextField!
    @IBOutlet weak var vPassword: UITextField!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var imaged: UIImageView!
    @IBOutlet var loadingView: UIView?
    
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()
    var futureDate: String?
    
    let MONTHLY_ALLOWANCE: Int = 30
    
    @IBAction func backToOrgSignUp(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func openProfileLibrary(_ sender: UIButton) {
        
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
            imaged.contentMode = .scaleAspectFit
            imaged.image = image
        } else {
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAccount(sender: UIButton) {
        if checkFields() {
            // CREATE NEW USER
            self.loadingView?.alpha = 1
            FIRAuth.auth()?.createUser(withEmail: self.sEmail!.text!, password: self.sPassword!.text!) { (user, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    let alert = UIAlertController(title: "Alert", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                        self.loadingView?.alpha = 0
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    var profileImageUrl = ""
                    
                    //IMAGE INFORMATION
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("Chapman").child("Organizations").child("profile_Image").child("\(imageName).png")
                    
                    if self.imaged.image == nil {
                        self.imaged.image = UIImage(imageLiteralResourceName: "Profile_Pic-1.png")
                    }
                    
                    self.appDelegate.mainProfilePic = self.imaged.image!
                    
                    if let uploadData = UIImagePNGRepresentation(self.imaged.image!){
                        storageRef.put(uploadData, metadata: nil, completion: {
                            (metadata, error) in
                            if error != nil{
                                print(error.debugDescription)
                                self.loadingView?.alpha = 0
                                return
                            } else {
                                profileImageUrl = (metadata?.downloadURL()?.absoluteString)!
                                self.appDelegate.mainUser = user
                                self.dbc.getRewards()
                                let details = ["display_name" : self.orgName!.text!, "orgName": self.orgName!.text!, "orgType": self.orgType!.text!, "schoolID": self.orgID!.text!, "school": self.skewl!.text!, "profileImageURL": profileImageUrl, "verified" : false, "resetDate": self.futureDate!, "allowance": self.MONTHLY_ALLOWANCE] as [String : Any]
                                self.appDelegate.userDetails = details
                                self.dbc.addOrg(user: user!, details: details)
                                self.appDelegate.setLoginState(state: true, email: self.sEmail!.text!, password: self.sPassword!.text!)
                                let changeRequest = user!.profileChangeRequest()
                                changeRequest.displayName = "org"
                                changeRequest.photoURL = URL(string: profileImageUrl)!
                                changeRequest.commitChanges() { (error) in
                                    // ...
                                    if error != nil {
                                        print(error!.localizedDescription)
                                        self.loadingView?.alpha = 0
                                    }
                                }
                                self.performSegue(withIdentifier: "slogin", sender: self)
                            }
                        })
                    }
                }
            }
        }
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
    
    
    var list = ["Chapman University"]
    var picker1 = UIPickerView()
    
    var types = ["Academic/Professional", "Civic Engagement","Diversity/ Cultural","Greek","Honor Society","Sport", "Leisure", "Recreational","Religious/Spiritual"]
    
    var picker2 = UIPickerView()
    
    
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
        if pickerView.tag == 0{
            skewl.text = list[row]
        }
        else{
            orgType.text = types[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
            return list[row]}
        else{
            return types[row]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imaged.layer.masksToBounds = true
        self.imaged.layer.cornerRadius = self.imaged.frame.width/2
        
        orgName.delegate = self
        orgType.delegate = self
        orgID.delegate = self
        skewl.delegate = self
        sEmail.delegate = self
        sPassword.delegate = self
        vPassword.delegate = self
        
        
        picker1.tag = 0
        picker2.tag = 1
        
        self.loadingView?.alpha = 0
        
        picker1.delegate = self
        picker1.dataSource = self
 
        skewl.inputView = picker1
        

        picker2.delegate = self
        picker2.dataSource = self
        orgType.inputView = picker2
        
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
  
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        orgName.inputAccessoryView = toolBar
        orgType.inputAccessoryView = toolBar
        orgID.inputAccessoryView = toolBar
        skewl.inputAccessoryView = toolBar
        sEmail.inputAccessoryView = toolBar
        sPassword.inputAccessoryView = toolBar
        vPassword.inputAccessoryView = toolBar

        let currentDate = Date()
        
        var dateComponent = DateComponents()
        
        dateComponent.month = 1
        dateComponent.day = 0
        dateComponent.year = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        self.futureDate = dateFormatter.string(from: Calendar.current.date(byAdding: dateComponent, to: currentDate)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == orgName{
            orgType!.becomeFirstResponder()
        }
        else if textField == orgType{
            orgID!.becomeFirstResponder()
        }
        else if textField == orgID{
            skewl!.becomeFirstResponder()
        }
        else if textField == skewl{
            sEmail!.becomeFirstResponder()
        }
        else if textField == sEmail{
            sPassword!.becomeFirstResponder()
        }
        else if textField == sPassword{
            vPassword!.becomeFirstResponder()
        }
        else{
            vPassword!.resignFirstResponder()
        }
        return true
    }

    func checkFields() -> Bool {
        if "" == self.orgName.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Organization Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.orgType.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Organization Type", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.orgID.text {
            let alert = UIAlertController(title: "Alert", message: "Incorrect Student ID", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.skewl.text {
            let alert = UIAlertController(title: "Alert", message: "Please Select Your School", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.sEmail.text || !isValidEmail(testStr: self.sEmail.text!) { // || self.sEmail.text?.contains("chapman.edu") == false {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Valid Email", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if "" == self.sPassword.text {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Your Password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if self.sPassword.text != self.vPassword.text{
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
            vc.emailText = self.sEmail!.text!
            vc.idText = self.orgID!.text!
        }
    }
}
