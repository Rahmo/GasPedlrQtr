//
//  AppDelegate.swift
//  GasPedlrProto
//
//  Created by Munib Ali on 10/10/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var items = NSMutableArray()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.enableLocalDatastore();
        
        // Override point for customization after application launch.
        
        
        //Initialize Parse
        Parse.setApplicationId("iJthxbC1aejCZ57PyVxgpNCG5RniczqNFLpOZs4a",
            clientKey: "1T41ABsAaI5PdPwdI2z7buM9DruGryt54h6R2vFO")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
          MapViewController().refresh()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        return true
    }
   
    class func getDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
          MapViewController().refresh()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
          MapViewController().refresh()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
          MapViewController().refresh()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
          MapViewController().refresh()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        locationManager.requestStateForRegion(region)
    }
    
    func handleRegionEvent(region: CLRegion) {
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active {
            if let message = notefromRegionIdentifier(region.identifier) {
                if let viewController = window?.rootViewController {
                    showSimpleAlertWithTitle(nil, message: message, viewController: viewController)
                }
            }
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = notefromRegionIdentifier(region.identifier)
            notification.soundName = "Default";
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleRegionEvent(region)
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleRegionEvent(region)
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("\(error)")
        
    }
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        print("BM didDetermineState \(state)");
        //  let delegate = AppDelegate.getDelegate()
        switch state {
        case .Inside:
            print("BeaconManager:didDetermineState CLRegionState.Inside \(region.identifier)")
            for savedItem in self.items {
                if let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification {
                    if geotification.identifier == region.identifier {
                        print("BeaconManager:didDetermineState CLRegionState.Inside \(region.identifier) is Equal to \(geotification.identifier)")                    }
                }
            }
            //   delegate.insideRegion(region.identifier)
        case .Outside:
            print("BeaconManager:didDetermineState CLRegionState.Outside");
            for savedItem in self.items {
                if let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification {
                    if geotification.identifier != region.identifier {
                        print("BeaconManager:didDetermineState CLRegionState.Inside \(region.identifier) does NOT Equal to \(geotification.identifier)")                    }
                }
            }
        case .Unknown:
            print("BeaconManager:didDetermineState CLRegionState.Unknown");
        default:
            print("BeaconManager:didDetermineState default");
        }
    }
    
    func notefromRegionIdentifier(identifier: String) -> String? {
        let savedGeos = self.items
        if let savedItems = savedGeos as? NSMutableArray {
            for savedItem in savedItems {
                if let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification {
                    if geotification.identifier == identifier {
                        // return geotification.note
                        let Emoji = "😀"
                        var text:String = "Welcome to \(geotification.note) \(Emoji) \n" +
                        "address: \(geotification.address)"
                        return text
                    }
                }
            }
        }
        return nil
    }
    
    
    
}