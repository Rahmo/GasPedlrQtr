//
//  LoginViewController.swift
//  GasPedlrProto
//
//  Created by Munib Ali on 10/10/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//


//Test comment!!

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var userEmailTextField: UITextField!
      var PartnersArray = NSMutableArray()
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var userPasswordTextField:
    UITextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
  
        
//        var query = PFQuery(className: "Partners")
//        query.whereKeyExists("PartnerName")
//      
//        
//        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil
//            {
//                if let pfObjects = objects as [PFObject]!
//                {
//                    print(pfObjects)
//            
//                    return
//                }
//            }
//            
//        
//        }
    

//        var query = PFQuery(className: "Partners")
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                
//                // query successful - display number of rows found
//                print("Successfully retrieved \(objects!.count) people")
//                
//                // print name & hair color of each person found
//                for object in objects! {
//                    
//                    let name = object["PartnerName"] as! NSString
//                   
//                    
//                    print("\(name) has ")
//                    
//                }
//            } else {
//                
//                // Log details of the failure
//                NSLog("Error: %@ %@", error!, (error?.userInfo)!)
//            }
//        }
        
        let userEmail = userEmailTextField.text;
        let userPassword = userPasswordTextField.text;
        
        
        PFUser.logInWithUsernameInBackground(userEmail!, password: userPassword!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil
            {
                
             
                
                
                // Login is succesfull
               NSUserDefaults.standardUserDefaults().setBool(true, forKey:"isUserLoggedIn");
               NSUserDefaults.standardUserDefaults().synchronize();
               print("User logged in")
                
           //     self.dismissViewControllerAnimated(true, completion:nil);
                
            //}else{
             //   print("Could not find user")
            //}
            
       
                self.performSegueWithIdentifier("LoginSuccess", sender: self)
                
            }  else {
                
                let alert: UIAlertView = UIAlertView(title: "error", message: "Make sure of the entered information", delegate: self, cancelButtonTitle: "Ok")
             alert.show()
            }
            
            
        }
        
    }
    
    
    
    

    // Do any additional setup after loading the view.
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
