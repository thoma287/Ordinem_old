//
//  ViewController.swift
//  practice
//
//  Created by Drew Thomas on 8/4/17.
//  Copyright © 2017 OrdinemOrg. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var output: UILabel!
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if let it = Int(textField.text!){
            let random = arc4random_uniform(6)
            if it == random{
                output.text = "Correct! The number was " + String(it)
            }
            else{
                output.text = "Wrong. The number was " + String(random)
            }
            
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


