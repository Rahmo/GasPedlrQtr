//
//  MapViewController.swift
//  GasPedlrProto
//
//  Created by Abdulrahman on 2015-10-19.
//  Copyright © 2015 GMG Developments. All rights reserved.


import Foundation
import MapKit
import CoreLocation
import UIKit
import Parse


let kSavedItemsKey = "savedItems"
let reuseIdentifier = "Cell"
var myImage =  UIImage(named: "restaurent.png");
class MapViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate ,UISearchBarDelegate   {
    
    //Geofications
    var geotifications = [Geotification]()
    
    //hh
    //relate to the search
    var searchController:UISearchController!
    
    var autoCompleteDataSource:Array<String> = [];
    @IBOutlet weak var mapView: MKMapView!
    var customAnotations:[Geotification] = [Geotification]();
    var mapModels:[SearchModel]?;
    
    var mapData:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:0, longitude:0)
    let apiKey = "AIzaSyAbXjQRDPYZJkP1FloGsnqjQHF8qc1I4yw"
    let mapHelper:MapHelper = MapHelper();
    
    var searchBy:String = ""
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    
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
        
        
        //TODO This to clear NSuserdefveult of the local device to start over
        //  clearlocalUserFefaults()
        
        
        
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("dataLoaded:"), name: "DataLoaded", object: nil);
        
        //        autoCompleteTableView.dataSource = self;
        //        autoCompleteTableView.delegate = self;
        //        autoCompleteTableView.backgroundColor = UIColor.clearColor();
        //        autoCompleteTableView.separatorColor = UIColor.clearColor();
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
        zoomSpan = [0.1,0.1]
        myAddress.lineBreakMode = .ByWordWrapping
        myAddress.numberOfLines = 0
        myLocation.lineBreakMode = .ByWordWrapping
        myLocation.numberOfLines = 0
        self.locationManager.delegate = self
        
        
        //this to make the location manager update each 1 km     if its 1000.0
        self.locationManager.distanceFilter = 1000.0;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self;
        self.customAnotations.removeAll(keepCapacity: false);
        //relate to Geotifications
        
        
        
        //        loadAllGeotifications()
        
    }
    
    
    //clearlocal nsuser default as a replacment for database
    func clearlocalUserFefaults(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kSavedItemsKey)
        
        for geo in geotifications
        {
            mapView.removeAnnotation(geo)
            removeRadiusOverlayForGeotification(geo)
            updateGeotificationsCount()
            
        }
        geotifications.removeAll()
    }
    
    
    func runPartneredBusiness(){
        clearlocalUserFefaults()
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        
        
        let serviceHelper = ServiceHelper();
        let dynamicURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(mapData.latitude),\(mapData.longitude)&radius=5000&types=starbucks&sensor=true&key=\(apiKey)"
        print(dynamicURL);
        serviceHelper.getServiceHandle(self.dataLoaded, url: dynamicURL);
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // loadAllGeotifications()
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        //loadAllGeotifications()
        zoomToFitMapAnnotations()
    }
    
    
    @IBAction func currentLocationPressed(sender: AnyObject) {
        //this below to remove all annotioantion plus the custom
        
        self.locationManager.startUpdatingLocation()
        self.customAnotations.removeAll(keepCapacity: false);
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        //loadAllGeotifications()
    }
    
    //this function get the current location of the user and keep updating the fields with the new Lat and lon
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let regionToZoom = MKCoordinateRegionMake(manager.location!.coordinate, MKCoordinateSpanMake(zoomSpan[0],zoomSpan[1]))
        
        mapView.setRegion(regionToZoom, animated: true)
        
        self.mapData =  CLLocationCoordinate2D(latitude: manager.location!.coordinate.latitude, longitude:     manager.location!.coordinate.longitude)
        
        
        myLocation.text = "\(locationManager.location!)"
        // clearlocalUserFefaults()
        // var timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector:  Selector("runPartneredBusiness"), userInfo: nil, repeats: false)
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    //
    
    
    
    
    
    //this Func to remove the anntioation info flyer from the map when pressed
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView)
    {
        
        for childView:AnyObject in view.subviews{
            childView.removeFromSuperview();
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //Return the number of sections
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
        var img:UIImage?;
        
        if(data == "PartneredUser"){
            
            cell.title.text = "Partnered User"
            cell.imageView.image = UIImage(named: "noimage.gif")
            
        }
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
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        //to remove all prev annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        self.locationManager.startUpdatingLocation()
        //this is important to get the most current location
        self.locationManager.stopUpdatingLocation()
        searchBy = self.autoCompleteDataSource[indexPath.row];
        let searchkey = self.autoCompleteDataSource[indexPath.row].lowercaseString;
        
        let serviceHelper = ServiceHelper();
        let dynamicURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(mapData.latitude),\(mapData.longitude)&radius=5000&types=\(searchkey)&sensor=true&key=\(apiKey)"
        print(dynamicURL);
        serviceHelper.getServiceHandle(self.dataLoaded, url: dynamicURL);
        // after the block closes it will check the notification cneter to get the observer
        
    }
    
    //
    //    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    //    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    //
    
    //
    
    @IBAction func zoomOut(sender: UIBarButtonItem) {
        zoomSpan[0] = mapView.region.span.latitudeDelta*2
        zoomSpan[1] = mapView.region.span.longitudeDelta*2
        
        
    }
    
    //to zoom in and out the current location
    @IBAction func zoomIn(sender: UIBarButtonItem) {
        
        zoomSpan[0] = mapView.region.span.latitudeDelta/2
        zoomSpan[1] = mapView.region.span.longitudeDelta/2
        
        
    }
    
    
    //Change the map Type
    @IBAction func changeMapType(sender: UIBarButtonItem) {
        
        if mapView.mapType == MKMapType.Standard {
            mapView.mapType = MKMapType.Satellite
        }else{
            mapView.mapType = MKMapType.Standard
        }
        
    }
    
    func zoomToFitMapAnnotations(){
        
        var topLeftCoord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0);
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        var bottomRightCoord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0);
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
        
        var foundAnotation = false;
        
        for anotation in self.customAnotations{
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, anotation.coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, anotation.coordinate.latitude);
            
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, anotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, anotation.coordinate.latitude);
            
            self.mapView.addAnnotation(anotation);
            foundAnotation = true;
        }
        
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
        
        self.locationManager.stopUpdatingLocation()
        
    }
    
    
    //This method save the Geo in the local device
    func saveAllGeotifications() {
        let items = NSMutableArray()
        
        for geotification in geotifications {
            let item = NSKeyedArchiver.archivedDataWithRootObject(geotification)
            items.addObject(item)
        }
        NSUserDefaults.standardUserDefaults().setObject(items, forKey: kSavedItemsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func dataLoaded(userData:[SearchModel]){
        // print(userData);
        clearlocalUserFefaults()
        
        self.customAnotations.removeAll(keepCapacity: false);
        self.mapModels = userData;
        
        for searchModel in self.mapModels!{
            //            let customAnotation = Geotification()
            //            customAnotation.coordinate = CLLocationCoordinate2D(latitude: searchModel.lat, longitude: searchModel.lon);
            let GeoCoordinate =  CLLocationCoordinate2D(latitude: searchModel.lat, longitude: searchModel.lon);
            
            //            customAnotation.title = "";
            //            customAnotation.subtitle = ""
            //             searchModel;
            
            StartGeotification(GeoCoordinate,model: searchModel)
            
        }
        self.zoomToFitMapAnnotations();
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    //This method does the add of the Geo into an array of Geotifications.and update the list
    func addGeotification(geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlayForGeotification(geotification)
        updateGeotificationsCount()
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
    
    // MARK: AddGeotificationViewControllerDelegate
    
    //    func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
    //        controller.dismissViewControllerAnimated(true, completion: nil)
    //        // 1
    //        let clampedRadius = (radius > locationManager.maximumRegionMonitoringDistance) ? locationManager.maximumRegionMonitoringDistance : radius
    //
    //        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
    //        addGeotification(geotification)
    //        // 2
    //        startMonitoringGeotification(geotification)
    //
    //        saveAllGeotifications()
    //    }
    func StartGeotification(coordinate: CLLocationCoordinate2D, model: SearchModel)// this method takes a coordinate and turn it in a geo and add it to using addgeo method  .
    {
        
        // var coordinate = mapView.centerCoordinate
        var radius = (700).doubleValue
        let clampedRadius = (radius > locationManager.maximumRegionMonitoringDistance) ? locationManager.maximumRegionMonitoringDistance : radius
        
        var identifier = NSUUID().UUIDString
        
        
        var eventType = EventType.OnEntry
        //(eventTypeSegmentedControl.selectedSegmentIndex == 0) ? EventType.OnEntry : EventType.OnExit
        
        
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier,  eventType: eventType, Model: model)
        addGeotification(geotification)
        // self.customAnotations.append(geotification)
        
        startMonitoringGeotification(geotification)
        
        saveAllGeotifications()
    }
    
    
    
    
    
    
    //        func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
    //            if(!view.annotation!.isKindOfClass(MKUserLocation)){
    //                let flyOutView:CustomFlyout = (NSBundle.mainBundle().loadNibNamed("CustomFlyout", owner: self, options: nil))[0]as! CustomFlyout;
    //                var calloutViewFrame = flyOutView.frame;
    //                calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 15, -calloutViewFrame.size.height);
    //                flyOutView.frame = calloutViewFrame;
    //
    //                let customAnotation = view.annotation as! Geotification;
    //                let model = customAnotation.searchModel;
    //                flyOutView.lblTitle.text = model!.name;
    //                let url = NSURL(string: model!.icon);
    //                let urlData = NSData(contentsOfURL: url!);
    //                let img = UIImage(data: urlData!);
    //                flyOutView.lblIcon.image = img;
    //                flyOutView.lblPosition.text = model!.address; //"Longitude: \(model!.lon) & Latitude: \(model!.lat)";
    //                view.addSubview(flyOutView);
    //            }
    //        }
    //
    
    
    //this function is to customise the veiw for the annotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        let identifier = "myGeotification"
        if annotation is Geotification {
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if annotationView == nil {
                
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                let removeButton = UIButton(type: .Custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 33, height: 23)
                removeButton.setImage(UIImage(named: "DeleteGeotification")!, forState: .Normal)
                
                
                let locationTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 43, height: 23))
                locationTitle.text = annotation.subtitle!
                
                annotationView?.rightCalloutAccessoryView = removeButton
                // annotationView?.leftCalloutAccessoryView =
                annotationView!.image = UIImage(named: "DeleteGeotification")!
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purpleColor()
            circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
            return circleRenderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        let geotification = view.annotation as! Geotification
        stopMonitoringGeotification(geotification)
        removeGeotification(geotification)
        saveAllGeotifications()
    }
    
    // MARK: Map overlay functions
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
        locationManager.startMonitoringForRegion(region)
        print(geotifications.count)
    }
    func loadAllGeotifications() {
        geotifications = []
        
        if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
            for savedItem in savedItems {
                if let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification {
                    addGeotification(geotification)
                }
            }
        }
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
    
    //the function fires after a text insertted in the search bar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
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
        serviceHelper.getServiceHandle(self.dataLoaded, url: dynamicURL);
    }
    
}

