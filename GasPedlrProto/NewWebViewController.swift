//
//  NewWebViewController.swift
//  GasPedlrProto
//
//  Created by Lisa Bernkopf on 1/17/16.
//  Copyright © 2016 GMG Developments. All rights reserved.
//

import UIKit

class NewWebViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityIndicator.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        //let webURL = searchBar.text
        //print(webURL);
        let url:NSURL = NSURL(string: "https://\(searchBar.text!)")!
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

    func webViewDidStartLoad(webView: UIWebView){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    func webView(webView: UIWebView,
        didFailLoadWithError error: NSError){
            let alert:UIAlertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            activityIndicator.hidden = true
    }
}
