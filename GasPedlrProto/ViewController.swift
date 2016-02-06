//
//  ViewController.swift
//  GasPedlrProto
//
//  Created by Munib Ali on 10/10/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import UIKit
import Parse




class ViewController: UIViewController {

    @IBOutlet weak var driverWebView: UIWebView!
    
    var URLPath = "https://analytics.google.com/analytics/web/#report/app-overview/a69637408w106680312p111074914/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        loadAddressURL ()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func loadAddressURL(){
        let requestURL = NSURL(string: URLPath)
        let request = NSURLRequest(URL:requestURL!)
        driverWebView.loadRequest(request)
    }

    override func viewDidAppear(animated: Bool)
    {
        
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn");
        if(!isUserLoggedIn)
        {
        self.performSegueWithIdentifier("logOut", sender: self);
        
        }
        
        


}
    @IBAction func logoutButtonTapped(sender: AnyObject)
    {
        NSUserDefaults.standardUserDefaults().setBool(false,forKey: "isUserLoggedIn");
        
        NSUserDefaults.standardUserDefaults().synchronize();
        
        self.performSegueWithIdentifier("LoginSuccess", sender: self);
        
    }
}
