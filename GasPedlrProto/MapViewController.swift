

//  MapViewController.swift
//  GasPedlrProto
//
//  Created by Abdulrahman on 2015-10-19.
// What is this file does are
// 1 - adding multiple pins of the surrounding businesses according google place api as it send to the service using get helper
// 2 - Retrieved the pins according to either by the search method if the user searched or using the catagories that has been shown in the collectionView. or else it takes from the default business that has been partnered with our service.
//3 -The retrived info get add as a Geotification and been added to an array. then this array get sent to the App Delegate to monitor the region
//4- it keeps updating the location based on the user location
// Files that interact with this file :
//.CutomFlyout
//.Appdelegate
//.Utilities
//.Geotification
//.CustomAnnotation
//.ServiceHelper
//.SearchModel : This to be added to the Geaotification to contain the srecieved info about each place
// Copyright © Rahmo


import Foundation
import MapKit
import CoreLocation
import UIKit
import Parse



let reuseIdentifier = "Cell"


// MARK: -
// delta is the zoom factor
// 2 will zoom out x2
// .5 will zoom in by x2
extension MKMapView {
    func setZoomByDelta(delta: Double, animated: Bool) {
        var _region = region;
        var _span = region.span;
        _span.latitudeDelta *= delta;
        _span.longitudeDelta *= delta;
        _region.span = _span;
        
        setRegion(_region, animated: animated)
    }
}

class MapViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate ,UISearchBarDelegate   {
    
    
    var flagRideMode = 0
    var geotifications = [Geotification]()
    var partnerDict: [String: String] = [String: String]()
    var searchController:UISearchController!
    var autoCompleteDataSource:Array<String> = [];
    @IBOutlet weak var mapView: MKMapView!
    
    //This used in the dataload method to save the result from the service
    var mapModels:[SearchModel]?;
    var mapData:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:0, longitude:0)
    //This key is for Google api servcie
    let apiKey = "AIzaSyAbXjQRDPYZJkP1FloGsnqjQHF8qc1I4yw"
    var searchBy:String = ""
    
    //relate to get the user location
    let locationManager = CLLocationManager()
    @IBOutlet weak var myAddress: UILabel!
    @IBOutlet weak var myLocation: UILabel!
    var zoomSpan = [Double]()
    
    //this function is responsible on show the search bar when search button pressed
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        //  self.mapView.showsUserLocation = true
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh ()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("DataLoadedForPartner:"), name: "DataLoadedForPartner", object: nil);
        autoCompleteDataSource.append("PartneredUser");
        autoCompleteDataSource.append("Restaurant");
        autoCompleteDataSource.append("Airport");
        autoCompleteDataSource.append("Atm");
        autoCompleteDataSource.append("Bank");
        autoCompleteDataSource.append("Church");
        autoCompleteDataSource.append("Hospital");
        autoCompleteDataSource.append("Mosque");
        autoCompleteDataSource.append("Movie_theater");
        
        //the default zoom
        zoomSpan = [0.0,0.1]
        myAddress.lineBreakMode = .ByWordWrapping
        myAddress.numberOfLines = 0
        myLocation.lineBreakMode = .ByWordWrapping
        myLocation.numberOfLines = 0
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //  self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.distanceFilter = 1000.0;
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self;
        // self.mapView.setUserTrackingMode(MAUserTrackingMode.Follow, animated: true)
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     After the map Fully renders it runs this
     This is important as without it the map loads slowly if this put in VeiwDidLoad
     
     - parameter mapView:       <#mapView description#>
     - parameter fullyRendered: <#fullyRendered description#>
     */
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        findAllPartners()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated);
        runPartneredBusiness()

        //this to make the location manager update each 1 km     if its 1000.0
        let monitoredRegions =  locationManager.monitoredRegions.count
        if (monitoredRegions > 0) {

            //The part below is important which is to delete the monitored regions from the set in the locationmanager (even if the user closed the app and reopen )
            let geoSet = locationManager.monitoredRegions
            for geo in geoSet  {
                locationManager.stopMonitoringForRegion(geo)
            }
        }
        
    }
    
    
    
    //this Func to remove the anntioation info flyer from the map when pressed
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView)
    {
        for childView:AnyObject in view.subviews{
            childView.removeFromSuperview();
        }
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        if(!view.annotation!.isKindOfClass(MKUserLocation)){
            let flyOutView:CustomFlyout = (NSBundle.mainBundle().loadNibNamed("CustomFlyout", owner: self, options: nil))[0]as! CustomFlyout;
            var calloutViewFrame = flyOutView.frame;
            calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 15, -calloutViewFrame.size.height);
            flyOutView.frame = calloutViewFrame;
            
            let customAnotation = view.annotation as! Geotification;
            let model = customAnotation.searchModel;
            flyOutView.lblTitle.text = model!.name;
            let url = NSURL(string: model!.icon);
            let urlData = NSData(contentsOfURL: url!);
            let img = UIImage(data: urlData!);
            flyOutView.lblIcon.image = img;
            flyOutView.lblPosition.text = model!.address; //"Longitude: \(model!.lon) & Latitude: \(model!.lat)";
            view.addSubview(flyOutView);
        }
    }
    
    
    
    /**
     This function changes the pins
     
     - parameter mapView:    <#mapView description#>
     - parameter annotation: <#annotation description#>
     
     - returns: <#return value description#>
     */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // simple and inefficient example
       
         let annotationView = MKPinAnnotationView()
        if (flagRideMode == 1) {
        annotationView.pinColor = .Green
        }
        else {
        
          annotationView.pinColor = .Red
        }
    
        if (annotation is MKUserLocation) {
          
                return nil
        
        }
      return annotationView
    }
    

    
    /**
     This function animate the pin drops as well as disabling the canShowCallout veiw when we click the pin.
     
     - parameter mapView: <#mapView description#>
     - parameter views:   <#views description#>
     */
    func mapView(mapView: MKMapView,didAddAnnotationViews views: [MKAnnotationView]){
        for veiw in views {
            veiw.canShowCallout = false
            
            
        }
        
        /// Animation code start
        var i = -1;
        for view in views {
            i++;
            let mkView = view as! MKAnnotationView
            if view.annotation is MKUserLocation {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint  =  MKMapPointForCoordinate(mkView.annotation!.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue;
            }
            
            let endFrame:CGRect = mkView.frame;
            
            // Move annotation out of view
            mkView.frame = CGRectMake(mkView.frame.origin.x, mkView.frame.origin.y - self.view.frame.size.height, mkView.frame.size.width, mkView.frame.size.height);
           
            // Animate drop
            let delay = 0.03 * Double(i)
            UIView.animateWithDuration(0.5, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations:{() in
                mkView.frame = endFrame
                // Animate squash
                }, completion:{(Bool) in
                    UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                        mkView.transform = CGAffineTransformMakeScale(1.0, 0.6)
                        
                        }, completion: {(Bool) in
                            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                                mkView.transform = CGAffineTransformIdentity
                                }, completion: nil)
                    })
                    
            })
        }
        
        
    }
    
    
    //this function is to customise the veiw for the annotation
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            if (flagRideMode == 1)
            {
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.greenColor()
                circleRenderer.fillColor = UIColor.grayColor().colorWithAlphaComponent(0.4)
            }
            else {
                circleRenderer.lineWidth = 1.0
                circleRenderer.strokeColor = UIColor.redColor()
                circleRenderer.fillColor = UIColor.grayColor().colorWithAlphaComponent(0.4)
            }
            return circleRenderer
        }
        return nil
    }
    

    
    
    
    @IBAction func currentLocationPressed(sender: AnyObject) {
        //this below to remove all annotioantion plus the custom
        //runPartneredBusiness()
        self.locationManager.startUpdatingLocation()
    }
    
    
    
    //the function fires after a text inserted in the search bar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        // locationManager.startUpdatingLocation()
        self.clearAllGeo()
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        
        //2
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        self.locationManager.startUpdatingLocation()
        //this is important to get the most current location
        self.locationManager.stopUpdatingLocation()
        //searchBy = self.autoCompleteDataSource[indexPath.row];
        let searchkey =  (searchBar.text)
        let searchkey2: String = (myAddress.text)!
        
        // let aString: String = "This is my string"
        let newString = searchkey2.stringByReplacingOccurrencesOfString("\r", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let removedSpaces = newString.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let serviceHelper = ServiceHelper();
        let dynamicURL = "https://maps.googleapis.com/maps/api/place/textsearch/json?location=\(mapData.latitude),\(mapData.longitude)&radius=5000&query=\(searchkey!)+\(removedSpaces)&sensor=false&key=\(apiKey)"
        print(dynamicURL);
        serviceHelper.getServiceHandle(self.DataLoadedWithoutMonitoringRegion, url: dynamicURL);
        self.locationManager.stopUpdatingLocation()
    }
    
    //this function get the current location of the user and keep updating the fields with the new Lat and lon
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let regionToZoom = MKCoordinateRegionMake(manager.location!.coordinate, MKCoordinateSpanMake(zoomSpan[0],zoomSpan[1]))
        mapView.setRegion(regionToZoom, animated: true)
        self.mapData =  CLLocationCoordinate2D(latitude: manager.location!.coordinate.latitude, longitude:     manager.location!.coordinate.longitude)
           myLocation.text = "\(locationManager.location!)"
        refresh()
        runPartneredBusiness()
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                print("Error: " + error!.localizedDescription)
                return
            }
            if placemarks!.count > 0 {
                let pm = placemarks?[0]
                self.displayLocationInfo(pm!)
            }
        })
    }

    
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("Error: " + error.localizedDescription)
//    }


    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Return the number of items in the section
        return self.autoCompleteDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Configure the cell
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        let data = autoCompleteDataSource[indexPath.row];
        if(data == "PartneredUser"){
            cell.title.text = "Partnered User"
            cell.imageView.image = UIImage(named: "noimage.gif")}
        else if(data == "Restaurant"){
            
            cell.title.text = "Restaurant"
            cell.imageView.image = UIImage(named: "restaurent.png")
            
        }
        else if(data == "Airport"){
            cell.title.text = "Airport"
            cell.imageView.image = UIImage(named: "Airport.png")
        }
        else if(data == "Hospital"){
            cell.title.text = "Hospital"
            cell.imageView.image = UIImage(named: "Hospital.png")
        }
            
        else if(data == "Church"){
            cell.title.text = "church"
            cell.imageView.image = UIImage(named: "church-icon.png")
        }
        else if(data == "Mosque"){
            cell.title.text = "Mosque"
            cell.imageView.image = UIImage(named: "Mosque.png")        }
        else if(data == "Atm"){
            cell.title.text = "Atm"
            cell.imageView.image = UIImage(named: "Atm-.png")
        }
        else if(data == "Bank"){
            cell.title.text = "Bank"
            cell.imageView.image = UIImage(named: "Bank.png")        }
        else if(data == "Movie_theater"){
            cell.title.text = "Movie_theater"
            cell.imageView.image = UIImage(named: "cinema.png")
        }
        return cell;
      }
    
    //this method is when searching from the bar
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        clearAllGeo()
        /**
        *  The reason of having the two in sequence because once the user hit the catagory already before the update has stopped so when we press again we want to get the recent location of the currnet user.
        */
        locationManager.startUpdatingHeading()
        searchBy = self.autoCompleteDataSource[indexPath.row];
        let searchkey = self.autoCompleteDataSource[indexPath.row].lowercaseString;
        let serviceHelper = ServiceHelper();
        let dynamicURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(mapData.latitude),\(mapData.longitude)&radius=5000&types=\(searchkey)&sensor=true&key=\(apiKey)"
        print(dynamicURL);
        serviceHelper.getServiceHandle(self.DataLoadedWithoutMonitoringRegion, url: dynamicURL);
        zoomToFitMapAnnotations()
        // after the block closes it will check the notification cneter to get the observer
         locationManager.stopUpdatingLocation()
    }
    
   
    /**
     Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
     Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
     */
      @IBAction func zoomOut(sender: UIBarButtonItem) {
        //        zoomSpan[0] = mapView.region.span.latitudeDelta*2
        //        zoomSpan[1] = mapView.region.span.longitudeDelta*2
        //
        self.mapView.setZoomByDelta(2, animated: true)
        
    }
    
    //to zoom in and out the current location
    @IBAction func zoomIn(sender: UIBarButtonItem) {
        self.mapView.setZoomByDelta(0.5, animated: true)
        //        zoomSpan[0] = mapView.region.span.latitudeDelta/2
        //        zoomSpan[1] = mapView.region.span.longitudeDelta/2
    }
    
    
    /**
     This method changes the map type of the map
     */
    @IBAction func changeMapType(sender: UIBarButtonItem) {
        
        if mapView.mapType == MKMapType.Standard {
            mapView.mapType = MKMapType.Satellite
        }else{
            mapView.mapType = MKMapType.Standard
        }
        
    }
    
    //will delete this one TBD  Because it is always occur
    //This function occur when there Adding fails to the set locationmanage.monitored set<Clregion>
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier) with error \(error)")
    }
    
    
 
 
    
  // MARK: Helping Functions

    func runPartneredBusiness(){
        
        if (self.partnerDict.count != 0 ){
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            clearAllGeo()
            for geo in geotifications
            {
                mapView.removeAnnotation(geo)
                stopMonitoringGeotification(geo)
                removeGeotification(geo)
                
            }
            let serviceHelper = ServiceHelper();
            for Partner in partnerDict {
                let dynamicURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(mapData.latitude),\(mapData.longitude)&radius=5000&name=\(Partner.0)&sensor=true&key=\(apiKey)"
                serviceHelper.getServiceHandle(self.DataLoadedForPartner, url: dynamicURL);
            }
            
        }
    }

    
    func findAllPartners(){
        let query = PFQuery(className: "Partners")
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
            if objects?.count > 0{
                    for obj in objects!{
              if self.partnerDict.count < objects?.count {
              //self.partnersArray.append(obj["PartnerName"] as! String)
              
                let partnerName = obj["PartnerName"] as! String
                let partnerCoupon = obj["CouponCode"] as! String
                self.partnerDict.updateValue(partnerCoupon, forKey: partnerName)
                
                        }
                                        }
                        self.runPartneredBusiness()
                                 }
                            }
                     }
                }
    
    
    func refresh (){
        let monitoredRegions =  locationManager.monitoredRegions.count
        if (monitoredRegions > 0) {
            
            
            //The part below is important which is to delete the monitored regions from the set in the locationmanager (even if the user closed the app and reopen )
            let geoSet = locationManager.monitoredRegions
            for geo in geoSet  {
                locationManager.stopMonitoringForRegion(geo)
            }
        }
        
    }
    //clearlocal nsuser default as a replacment for database
    func clearAllGeo(){
        
        for geo in geotifications
        {
            mapView.removeAnnotation(geo)
            stopMonitoringGeotification(geo)
            removeGeotification(geo)
        }
        
        if geotifications.count > 0 {
            for index in 1...geotifications.count {
                geotifications.removeAtIndex(index)
            }
        }
    }

    
    /**
     This function to Fit the annotation in the map when a catagory or search pressed !
     */
    func zoomToFitMapAnnotations(){
        var topLeftCoord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0);
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        var bottomRightCoord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0);
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
        var foundAnotation = false;
        if(!foundAnotation){
            return;
        }
        
        var region:MKCoordinateRegion = MKCoordinateRegion(center: topLeftCoord, span:MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0));
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
        
        self.mapView.regionThatFits(region);
        self.mapView.setRegion(region, animated: true);
        //        var timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector:  Selector("runPartneredBusiness"), userInfo: nil, repeats: false)
    }
    
    
    //This method save the Geo in the array and make it start the monitoring So we can alert the user for a partner business
    func saveAllGeotifications() {
        let newItems = NSMutableArray()
        for geotification in geotifications {
            startMonitoringGeotification(geotification)
            let item = NSKeyedArchiver.archivedDataWithRootObject(geotification)
            newItems.addObject(item)
        }
        let delegate = AppDelegate.getDelegate()
        items = newItems
        print("now printing count")
        print(items.count)
        print("now in for loop")
        //for item in items {
        //    print(item.description.cStringUsingEncoding(NSUTF8StringEncoding))
        //}
        
        let savedGeos = items
        if let savedItems = savedGeos as? NSMutableArray {
            for savedItem in savedItems {
                if let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification {
                    var text:String = "\(geotification.note)"
                    print(text)
                }
                
            }
        }

    }
    
    
    /**
     this is a helper method for the dictionary in the following method
     
     - parameter key:        Key to return its value
     - parameter dictionary: The dictionary where we searhc the value from
     
     - returns: <#return value description#>
     */
    func findValueForKey(key: String, dictionary: [String: String]) ->String?
    {
        for (k, value) in dictionary
        {
           
            if (k.lowercaseString == key.stringByReplacingOccurrencesOfString("'", withString: "").lowercaseString)
            {
                return value
            }
        }
        
        return nil
    }
    
    //This Function is important as it recieve the result from the service
    func DataLoadedForPartner(userData:[SearchModel]){
        flagRideMode = 1
        
        /**
        *  <#Description#>
      TODO add the coupon from the partner Dict
        */
       
        var UserDataResultsWithCoupons : [SearchModel] = [SearchModel]()
        
        for model  in userData {
            var m : SearchModel = SearchModel(name: model.name, icon: model.icon, lon: model.lon, lat: model.lat, address: model.address)
          
            if let lookupcoupon = self.findValueForKey(model.name, dictionary: partnerDict)
            { m.coupon = "\(lookupcoupon)"}
           
           UserDataResultsWithCoupons.append(m)
        }
       
        
        self.mapModels = UserDataResultsWithCoupons;
        
        var counter = 0
        for searchModel in self.mapModels!{
       
            if (counter > 2) {
                break
            }
            //get the result from google service and make coordinate so we can create a geo on that location.
            let GeoCoordinate =  CLLocationCoordinate2D(latitude: searchModel.lat, longitude: searchModel.lon);
            
            //This is to create a geo according to the coordinate also sent the model for further info
            StartGeotification(GeoCoordinate,model: searchModel)
            counter++
        }
        
        /**
        The save is important to make the region monitoring
        */
        saveAllGeotifications()
        updateGeotificationsCount()
    }
    
    func DataLoadedWithoutMonitoringRegion(userData:[SearchModel]){
       flagRideMode = 0
        self.mapModels = userData;
        var counter = 0
        for searchModel in self.mapModels!{
            
            //get the result from google service and make coordinate so we can create a geo on that location.
            let GeoCoordinate =  CLLocationCoordinate2D(latitude: searchModel.lat, longitude: searchModel.lon);
            
            //This is to create a geo according to the coordinate also sent the model for further info
            StartGeotification(GeoCoordinate,model: searchModel)
            counter++
        }
        updateGeotificationsCount()
    }
    
    
    
    // Map overlay functions
    //This add the overlay of the
    func addRadiusOverlayForGeotification(geotification: Geotification) {
        mapView?.addOverlay(MKCircle(centerCoordinate: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlayForGeotification(geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        if let overlays = mapView?.overlays {
            for overlay in overlays {
                if let circleOverlay = overlay as? MKCircle {
                    let coord = circleOverlay.coordinate
                    if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                        mapView?.removeOverlay(circleOverlay)
                        break
                    }
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    

    
    //This method is to let the loction manager know when to stop  montioring the geo
    func stopMonitoringGeotification(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == geotification.identifier {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    
    
    
    func regionWithGeotification(geotification: Geotification) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        // 2
        region.notifyOnEntry = (geotification.eventType == .OnEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    //this method let the location know knows when the to start monitor this region .
    func startMonitoringGeotification(geotification: Geotification) {
        // 1
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: self)
            return
        }
        //        // 2
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            showSimpleAlertWithTitle("Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.", viewController: self)
        }
        // 3
        let region = regionWithGeotification(geotification)
        // 4
        let monitoredNum = locationManager.monitoredRegions.count
        if (monitoredNum <= 19){
            locationManager.startMonitoringForRegion(region)
        }
        
    }

    
    // MARK: Functions that update the model/associated views with geotification changes
    //This method does the add of the Geo into an array of Geotifications.and update the list
    func addGeotification(geotification: Geotification) {
        if (geotifications.count <= 20)
        {
            
            geotifications.append(geotification)
            mapView.addAnnotation(geotification)
            addRadiusOverlayForGeotification(geotification)
            updateGeotificationsCount()
            
        }
    }
    
    func removeGeotification(geotification: Geotification) {
        if let indexInArray = geotifications.indexOf(geotification) {
            geotifications.removeAtIndex(indexInArray)
        }
        
        mapView.removeAnnotation(geotification)
        removeRadiusOverlayForGeotification(geotification)
        updateGeotificationsCount()
        
    }
    
    func updateGeotificationsCount() {
        title = "Geotifications (\(geotifications.count))"
        navigationItem.rightBarButtonItem?.enabled = (geotifications.count < 20)
    }
    
    
    func StartGeotification(coordinate: CLLocationCoordinate2D, model: SearchModel)// this method takes a coordinate and turn it in a geo and add it to using addgeo method  .
    {
        
        let radius = (700).doubleValue
        let clampedRadius = (radius > locationManager.maximumRegionMonitoringDistance) ? locationManager.maximumRegionMonitoringDistance : radius
        
        let identifier = NSUUID().UUIDString
        
        
        let eventType = EventType.OnEntry
        //(eventTypeSegmentedControl.selectedSegmentIndex == 0) ? EventType.OnEntry : EventType.OnExit
        
        
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier,  eventType: eventType, Model: model)
        
        addGeotification(geotification)
        
        // self.customAnotations.append(geotification)
        
        
    }
    
    
    //the function show the info of the current location in the labels of the map as well as the consol
    func displayLocationInfo(placemark: CLPlacemark) {
        
        myAddress.text = "   \r \(placemark.postalCode!) \(placemark.administrativeArea!) \(placemark.postalCode!) \r \(placemark.country!)"
        //\(placemark.thoroughfare!) //todo in the addresstxt
        print("-----START UPDATE-----")
        //print(placemark.subThoroughfare)
        // print(placemark.thoroughfare!)
        print(placemark.locality!)
        print(placemark.postalCode!)
        print(placemark.administrativeArea!)
        print(placemark.country!)
        print("--------------------")
        print("*** My location: ***")
        print(locationManager.location!)
        print("--------------------")
        print("***The addressDictionary: ***")
        print(placemark.addressDictionary!)
        print("-----END OF UPDATE-----")
        
    }
    
    
}