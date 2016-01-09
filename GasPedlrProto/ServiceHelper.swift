//
//  ServiceHelper.swift
//  GasPedlrProto
//
//  Created by Abdulrahman on 2015-11-05.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import Foundation
class ServiceHelper{
    
    
    
    func getServiceHandle(afterDownload:([SearchModel]) -> Void ,url:String){
        
        let nsURL:NSURL = NSURL(string: url)!;
        print(url);
        let urlRequest = NSMutableURLRequest(URL: nsURL);
        urlRequest.timeoutInterval = 30.0;
        urlRequest.HTTPMethod = "GET";
        let queue:NSOperationQueue = NSOperationQueue.mainQueue();
        
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue, completionHandler: { response, data, error in
            print(response);
            print(data);
            if(data!.length > 0){
                var publishData:[SearchModel] = [SearchModel]();
                // var errorPointer:NSError?
                var jsonObject:AnyObject? = nil
                
                do {
                    jsonObject   = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    // use anyObj here
                    
                    
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
                
                
                
                print(jsonObject);
                if(jsonObject!.isKindOfClass(NSDictionary)){
                    
               //     let jsonData = jsonObject as! NSDictionary;
                    let datas =  jsonObject!.valueForKey("results")as! NSArray;
                    
                    
                    for dictData : AnyObject in datas{
                        let dictEach = dictData as! NSDictionary;
                        let name = dictEach.valueForKey("name")as!  NSString;
                        let icon = dictEach.valueForKey("icon")as!  String;
                        
                        print(name);
                        print(icon);
                        
                        let gematries = dictEach.valueForKey("geometry")as!  NSDictionary;
                        let locations:AnyObject = gematries.valueForKey("location")!;
                        let lon = locations.valueForKey("lng")as!  Double;
                        let lat = locations.valueForKey("lat")as! Double;
                    
                        var address : String
                        
                        
                        //it follows this if we are searching according the type (catagory) using the nearbysearch APi
                        if ((dictEach.valueForKey("vicinity") ) != nil)
                        {
                         address = dictEach.valueForKey("vicinity")as!  String;
                        }
                            // this follows text search api 
                        else {
                            address = dictEach.valueForKey("formatted_address")as!  String;
                        }
                        //Changed this from Var to Let
                        let searchModel:SearchModel = SearchModel(name: name as String, icon: icon, lon: lon, lat: lat,address:address);
                        publishData.append(searchModel);
                        
                        
                    }
                    print(publishData);
                    for  item in publishData{
                        print(item.name);
                        print(item.icon);
                        print(item.lat);
                        print(item.lon);
                    }
                    afterDownload(publishData);
                    //block(publishData);
                    //NSNotificationCenter.defaultCenter()?.postNotificationName("DataLoaded", object: nil, userInfo: ["data":publishData]);
                }
            }
            else{
                //error cought here
            }
            
        });
        //completionHandler: ((response:NSURLResponse!, data:NSData!, error:NSError!), -> Void)
        
    }
}