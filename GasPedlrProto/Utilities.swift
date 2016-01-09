//
//  Utilities.swift
//  Geotify
//
//  Created by Ken Toh on 3/3/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit

// MARK: Helper Functions

func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController) {
   
    //added to make it work for subviews to show alert
    //first it determines the rootview then get the window 1 of the actual veiw we are at (if we put 0 it would go the actual first window in the app)
    let rootViewController: UIViewController = UIApplication.sharedApplication().windows[1].rootViewController!
    
  let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
  let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
  alert.addAction(action)
    //need to call the dismissViewControllerAnimated(_: completion:) on the same view controller when you'd like to dismiss your alert later.
      rootViewController.dismissViewControllerAnimated(true, completion: nil)
  
    //Old solution. 
  //viewController.presentViewController(alert, animated: true, completion: nil)
    
    //  Had a problem becasue i couldn't make the alert in the subveiw
     rootViewController.presentViewController(alert, animated: true, completion: nil)
}

func zoomToUserLocationInMapView(mapView: MKMapView) {
  if let coordinate = mapView.userLocation.location?.coordinate {
    let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
    mapView.setRegion(region, animated: true)
  }
}
