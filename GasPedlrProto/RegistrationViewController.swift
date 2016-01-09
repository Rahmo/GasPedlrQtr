//
//  RegistrationViewController.swift
//  GasPedlrProto
//
//  Created by Munib Ali on 10/10/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import UIKit
import Parse

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var userEmailTextField: UITextField!
    
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    
    @IBOutlet weak var repeatPassword: UITextField!
    
    
    @IBOutlet weak var vehicleTextField: UITextField!
    
    @IBOutlet weak var licensePlateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonTapped(sender: AnyObject) {
        
        let userEmail = userEmailTextField.text;
        let userPassword = userPasswordTextField.text;
        let userName = userNameTextField.text;
        let userVehicle = vehicleTextField.text;
        let userlicensePlate = licensePlateTextField.text;
        let userRepeatPassword = repeatPassword.text;
        
        
        // Check for empty fields
        if(userEmail!.isEmpty || userPassword!.isEmpty || userRepeatPassword!.isEmpty || userName!.isEmpty || userVehicle!.isEmpty || userlicensePlate!.isEmpty)
            
            
        {
            //Display Alert message
            
            displayMyAlertMessage("All fields are required");
            
            return;
            
        }
        
        // Check if passwords match
        if(userPassword != userRepeatPassword)
        {
            //Display an alert message
            
            displayMyAlertMessage("Passwords do not match");
            
            return;
            
        }
        
        
        
        // Store data
        let myUser: PFUser = PFUser();
        
        myUser.username = userName
        myUser.password = userPassword
        myUser.email = userEmail
        myUser.setObject(userVehicle!, forKey: "User_Vehicle")
        myUser.setObject(userlicensePlate!, forKey: "User_Plate")
        
        myUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("User successfully registered")
            
            
            
            
            // Display alert message with confirmation
            
            let myAlert = UIAlertController(title:"Alert", message:"Registration is Successful. Enjoy using GadPedlr", preferredStyle: UIAlertControllerStyle.Alert);
            
            
            let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.Default){action in
                self.dismissViewControllerAnimated(true, completion:nil);
                
            }
            
            myAlert.addAction(okAction);
            self.presentViewController(myAlert,animated:true, completion:nil);
            
        }
        
        
        
        
        
    }
    
    
    
    
    
    func displayMyAlertMessage(userMessage:String)
    {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert);
        
        let okAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler:nil);
        
        myAlert.addAction(okAction);
        
        self.presentViewController(myAlert, animated:true, completion:nil);
        
    }
    
    
    
    
    
}