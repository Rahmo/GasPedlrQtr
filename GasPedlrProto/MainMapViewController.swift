//
//  MainMapViewController.swift
//  GasPedlrProto
//
//  Created by Abdulrahman on 2015-11-23.
//  Copyright © 2015 GMG Developments. All rights reserved.
//


import Foundation
import MapKit
import CoreLocation
import UIKit
import Parse


class MainMapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {


    @IBOutlet weak var mapView: MKMapView!
    
    //relate to get the user location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self;
        // self.mapView.setUserTrackingMode(MAUserTrackingMode.Follow, animated: true)
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)

        

    
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


