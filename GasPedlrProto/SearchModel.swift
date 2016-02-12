//
//  searchModel.swift
//  GasPedlrProto
//
//  Created by Abdulrahman on 2015-11-04.
//  Copyright © Rahmo
//

import Foundation


struct SearchModel{
    var name:String;
    var icon:String;
    var lon:Double;
    var lat:Double;
    var address:String;
   
    var coupon: String!;
    
    init( name:  String,  icon: String,  lon: Double,  lat: Double,  address: String  ) {
        
        self.name = name
        self.icon = icon
        self.lon =  lon
        self.lat = lat
        self.address = address
       // self.coupon = nil
    }
  
}