//
//  ServiceHelper.swift
//  GasPedlrProto
//
//  Created by Abdulrahman on 2015-11-05.
//  Copyright © Rahmo
//

import Foundation
class ServiceHelper{
    
    
    /**
     This method read the serielized object (below) and put it in array to be returned.
     
     - parameter object: The object is the one that has been serilized from Json an dneed to be read
     */
    func readJSONObject(object: [String: AnyObject]) -> [SearchModel] {

        var Data:[SearchModel] = [SearchModel]();
        
        /// The lest side of the Json which string the contains "result"
        let datas = object["results"] as! NSArray
        
        /**
        *  The right side of the first node can contain many data types
        */
        for dictData : AnyObject in datas{
            let dictEach = dictData as! NSDictionary;
            let name = dictEach.valueForKey("name")as!  NSString;
            let icon = dictEach.valueForKey("icon")as!  String;
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
        
            
            var searchModel:SearchModel = SearchModel(name: name as String, icon: icon, lon: lon, lat: lat,address:address );
            if (Data.count <= 20 ) {
                
                Data.append(searchModel);
                
              
            }
            else {
                for index in 1...Data.count {
                    Data.removeAtIndex(index)
                }
                Data.append(searchModel);
            }
           
        }
            
   
    return Data
    }
    
    
    /**
     This service reads the data from google line that is Json and serilalize it then put it in an array to be returned
     return the result from the URl request into an array of [SearchModel]
     
     - parameter afterDownload: This is the array that is to be returned
     - parameter url:           This is the URL that conatins the request (will return Json )
     ** Updated 2/3/2016
     */
    
    func getServiceHandle(afterDownload:([SearchModel]) -> Void ,url:String){
        
        /// This is the result to be returned to the caller mathod
       var publishData:[SearchModel] = [SearchModel]();
        
        
        
      let nsURL:NSURL? = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!);
        

        /// 1) Get the URl Link
        let data = NSData(contentsOfURL: nsURL!)
        /**
        *  2) Serielize the Json to an object so we can do work on it.
        */
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            
            
            /// Check that it is a dictionary type meaning its Json
            if let dictionary = object as? [String: AnyObject] {
               publishData = readJSONObject(dictionary)
               // cacheResult(dictionary)
                //readCache()
                /**
                *  Send this paramete to the caller with the result "Publish Datas"
                */
                
               
                afterDownload(publishData)
            }
        }
        /// It is important to catch the error like that and not only putting catch... we put let error
        catch let error as NSError {
           print("json error: \(error.localizedDescription)")
        }
       }
    
    
    func readCache(){
    let cache = NSCache()
        
      let myObject =   cache.valueForKey("CachedObject")
        print("rrrrrr \(myObject?.valueForKey("CachedObject"))")
    }
    
    func cacheResult ( var myObject: [String: AnyObject]){
        let cache = NSCache()
        
        
        if let cachedVersion = cache.objectForKey("CachedObject") as? [String: AnyObject] {
            // use the cached version
            myObject = cachedVersion
        } else {
            // create it from scratch then store in the cache
           
            cache.setObject(myObject, forKey: "CachedObject")
        }
    
    }
    
}
