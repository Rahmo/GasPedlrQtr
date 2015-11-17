//
//  customAnnotation.swift
//  GasPedlrProto
//
//  Created by Abdulrahman on 2015-11-05.
//  Copyright © 2015 GMG Developments. All rights reserved.
//
import Foundation
import MapKit

class CustomAnotation:NSObject, MKAnnotation
{
    var coordinate:CLLocationCoordinate2D;
    var title:String?;
    var subtitle:String?;
    var searchModel:SearchModel?;
    
    override init() {
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0);
        self.title = "Gaspedlr";
        self.subtitle = "Gaspedlr";
    }
}