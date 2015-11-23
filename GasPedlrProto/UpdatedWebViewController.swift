//
//  UpdatedWebViewController.swift
//  GasPedlrProto
//
//  Created by Lisa Bernkopf on 11/23/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import UIKit
import iAd

class UpdatedWebViewController: UIViewController, ADBannerViewDelegate {

    @IBOutlet var webBanner: ADBannerView?
    
    @IBOutlet var webContainer: UIView!
    
    @IBOutlet var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.canDisplayBannerAds = true
        self.webBanner?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
