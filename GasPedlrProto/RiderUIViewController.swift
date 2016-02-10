//
//  RiderUIViewController.swift
//  GasPedlrProto
//
//  Created by Lisa Bernkopf on 10/25/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderUIViewController: UIViewController {

   
    @IBOutlet weak var BrowserButton: UIButton!
    @IBOutlet weak var MapButton: UIButton!
    @IBOutlet weak var GameButton: UIButton!
    //kkk
    @IBOutlet weak var driverName: UILabel!
    override func viewDidLoad() {
        //Parse Test Object DO NOT REMOVE
        //let testObject = PFObject(className: "TestObject")
        //testObject["foo"] = "bar"
        //testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
         //print("Object has been saved.")
        //}
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var driverPlate: UILabel!
    

    @IBOutlet weak var driverCar: UILabel!

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
