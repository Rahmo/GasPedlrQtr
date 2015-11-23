//
//  ViewController.swift
//  Web App
//
//  Created by Lisa Bernkopf on 10/24/15.
//  Copyright © 2015 Meg Archer. All rights reserved.
//

import UIKit
import WebKit
import Parse
import iAd

class WebViewController: UIViewController, ADBannerViewDelegate {

    @IBOutlet var webBannerAd: ADBannerView?
    
    @IBOutlet weak var TheTextField: UITextField!
    @IBOutlet weak var TheWebView: UIWebView!
    
    @IBAction func TheGoButton(sender: AnyObject) {
        let text = TheTextField.text;
        let url = NSURL(string: text!);
        let req = NSURLRequest(URL:url!);
        self.TheWebView!.loadRequest(req);
    }
    
    @IBAction func webBackButton(sender: AnyObject) {
        self.performSegueWithIdentifier("webBackView", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true  // display banner ads

        let URL = NSURL(string: "https://www.google.com");
        TheWebView.loadRequest(NSURLRequest(URL:URL!));
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

