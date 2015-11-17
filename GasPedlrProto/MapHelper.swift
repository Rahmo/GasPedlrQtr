//
//  MapHelper.swift
//  GasPedlrProto
//
//  Created by Abdulrahman on 2015-11-04.
//  Copyright © 2015 GMG Developments. All rights reserved.
//
 //TODO http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http this is a work around

import Foundation
import MapKit

class MapHelper{
    
    func geoCodeUsingAddress(address:String) ->CLLocationCoordinate2D{
        var latitude = 0.0
        var longitude = 0.0
        let esc_addr = address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let req = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=\(esc_addr!)"
       
      //  let result = NSString(contentsOfURL: NSURL(string: req)!, encoding: NSASCIIStringEncoding, error: nil)
        
        //TODO: Changed this to meet SWIFT 2 problems
        do {
            let result : NSString?
              result =    try NSString(contentsOfURL: NSURL(string: req)!, encoding: NSUTF8StringEncoding)
         
            
            if let value = result{
                let scanner:NSScanner = NSScanner(string: value  as String) // added as string
                if(scanner.scanUpToString("\"lat\" :", intoString: nil) && scanner.scanString("\"lat\" :", intoString: nil)){
                    scanner.scanDouble(&latitude)
                }
                if(scanner.scanUpToString("\"lng\" :", intoString: nil) && scanner.scanString("\"lng\" :", intoString: nil)){
                    scanner.scanDouble(&longitude);
                }
            }
            else{
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
              // let resultString = String(contentsOfURL: NSURL(string: req)!, encoding: NSUTF8StringEncoding, )         //let result:NSString? = NSString(contentsOfURL: NSURL(string: req)), encoding: 1, error: nil)
        
     
        
       
        
        var center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0);
        center.latitude = latitude;
        center.longitude = longitude;
        return center;
        
    }
}