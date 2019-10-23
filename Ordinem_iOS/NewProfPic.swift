//
//  NewProfPic.swift
//  Ordinem_iOS
//
//  Created by Drew Thomas on 2/16/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit
import Firebase

class NewProfPic: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var selectButton: UIButton!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbc: DatabaseConnector = DatabaseConnector()

    @IBAction func imageButtonPressed(_ sender: Any) {
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
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        } else{
            print("Something went wrong")
        }
            self.dismiss(animated: true, completion: nil)
        }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        handleset()
     }
    
    func handleset(){
        self.appDelegate.mainUser = FIRAuth.auth()!.currentUser
        
        let cUser = self.appDelegate.mainUser
        
        //IMAGE INFORMATION
        //let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("Chapman").child("Users").child("profile_Image").child("\(cUser!.uid).png")
        
        if let uploadData: Data = UIImagePNGRepresentation(self.imageView.image!){
            storageRef.put(uploadData, metadata: nil, completion: {
                (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                else{
                    let changeRequest = cUser!.profileChangeRequest()
                    changeRequest.photoURL = metadata?.downloadURL()!
                    self.appDelegate.mainProfilePic = self.imageView.image!
                    if self.appDelegate.mainUser?.displayName == "user" {
                        self.appDelegate.ref?.child("chapman").child("users").child(self.appDelegate.mainUser!.uid).child("profileImageURL").setValue(metadata?.downloadURL()!.absoluteString)
                    } else {
                        self.appDelegate.ref?.child("chapman").child("organizations").child(self.appDelegate.mainUser!.uid).child("profileImageURL").setValue(metadata?.downloadURL()!.absoluteString)
                    }
                    
                    changeRequest.commitChanges() { (error) in
                        // ...
                        if error != nil {
                            print(error!.localizedDescription)
                        }
                        self.performSegue(withIdentifier: "exit", sender: self)
                    }
                    //Cannot reverse the role due as did within details- get only
                    //picURL: profileImageUrl
                }
            })
        }else{
            print("failed to upload picture")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView?.image = self.appDelegate.mainProfilePic!
        imageView?.layer.masksToBounds = true
        imageView?.layer.cornerRadius = (imageView?.frame.width)!/2
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
