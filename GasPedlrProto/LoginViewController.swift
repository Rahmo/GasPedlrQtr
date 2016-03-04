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
        

        // Store Login & Password fields from Parse to label

        let userEmail = userEmailTextField.text;
        let userPassword = userPasswordTextField.text;
        
        
        
        PFUser.logInWithUsernameInBackground(userEmail!, password: userPassword!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil
        
            {
                
             
                
                
                // Login is succesfull
               NSUserDefaults.standardUserDefaults().setBool(true, forKey:"isUserLoggedIn");
               NSUserDefaults.standardUserDefaults().synchronize();
              // print("User logged in")
                
              // self.dismissViewControllerAnimated(true, completion:nil);
                
            }else{
                print("Could not find user")
          
            
              let alert: UIAlertView = UIAlertView(title: "error", message: "Make sure of the entered information", delegate: self, cancelButtonTitle: "Ok")
             alert.show()
                
                self.dismissViewControllerAnimated(false, completion:nil)
            }
            
            
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
    
