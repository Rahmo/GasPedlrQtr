//
//  GamePageViewController.swift
//  GasPedlrProto
//
//  Created by Lisa Bernkopf on 11/8/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import UIKit

class GamePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func gameBackButton(sender: AnyObject) {
         self.performSegueWithIdentifier("gameBackView", sender: self)
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
