//
//  QRCodeForCashouts.swift
//  Ordinem_iOS
//
//  Created by Shevis Johnson on 2/21/17.
//  Copyright © 2017 Ordinem. All rights reserved.
//

import UIKit

class QRCodeForCashouts: UIViewController {
    
    @IBOutlet var rewardName: UILabel?
    @IBOutlet var rewardImage: UIImageView?
    @IBOutlet var qrcode: UIImageView?
    
    var r_name: String?
    var r_image: UIImage?
    var r_id: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        rewardName?.text = r_name
        rewardImage?.image = r_image
        let qrCode = QRCode("reward:\(r_id!)")
        qrcode?.image = qrCode!.image!
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
