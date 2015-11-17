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

class MapViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate ,UISearchBarDelegate , UITableViewDataSource, UITableViewDelegate  {



    @IBAction func mapBackButton(sender: AnyObject) {
                self.performSegueWithIdentifier("mapBackView", sender: self)
    }

    
    //relate to the search
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var autoCompleteDataSource:Array<String> = [];
    @IBOutlet weak var mapView: MKMapView!
    var customAnotations:[CustomAnotation] = [CustomAnotation]();
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("dataLoaded:"), name: "DataLoaded", object: nil);

        autoCompleteTableView.dataSource = self;
        autoCompleteTableView.delegate = self;
        autoCompleteTableView.backgroundColor = UIColor.clearColor();
        autoCompleteTableView.separatorColor = UIColor.clearColor();
        
        autoCompleteDataSource.append("Restaurant");
        autoCompleteDataSource.append("Airport");
        autoCompleteDataSource.append("Atm");
        autoCompleteDataSource.append("Bank");
        autoCompleteDataSource.append("Church");
        autoCompleteDataSource.append("Hospital");
        autoCompleteDataSource.append("Mosque.png");
        autoCompleteDataSource.append("Movie_theater");

        //the default zoom
        zoomSpan = [0.1,0.1]
        myAddress.lineBreakMode = .ByWordWrapping
        myAddress.numberOfLines = 0
        myLocation.lineBreakMode = .ByWordWrapping
        myLocation.numberOfLines = 0
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self;
        self.customAnotations.removeAll(keepCapacity: false);

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
      
           }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
    }
    
    
    @IBAction func currentLocationPressed(sender: AnyObject) {
      //this below to remove all annotioantion plus the custom
         self.locationManager.startUpdatingLocation()
        self.customAnotations.removeAll(keepCapacity: false);
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
    }
   
    //this function get the current location of the user and keep updating the fields with the new Lat and lon
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let regionToZoom = MKCoordinateRegionMake(manager.location!.coordinate, MKCoordinateSpanMake(zoomSpan[0],zoomSpan[1]))
        
        mapView.setRegion(regionToZoom, animated: true)
        
        self.mapData =  CLLocationCoordinate2D(latitude: manager.location!.coordinate.latitude, longitude:     manager.location!.coordinate.longitude)
        
        
        myLocation.text = "\(locationManager.location!)"
        
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
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        if(!view.annotation!.isKindOfClass(MKUserLocation)){
            let flyOutView:CustomFlyout = (NSBundle.mainBundle().loadNibNamed("CustomFlyout", owner: self, options: nil))[0]as! CustomFlyout;
            var calloutViewFrame = flyOutView.frame;
            calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 15, -calloutViewFrame.size.height);
            flyOutView.frame = calloutViewFrame;
            
            let customAnotation = view.annotation as! CustomAnotation;
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
    
    //this Func to remove the anntioation info flyer from the map when pressed
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView)
    {
        for childView:AnyObject in view.subviews{
            childView.removeFromSuperview();
        }
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.autoCompleteDataSource.count;
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell:UITableViewCell?;
        let cellString = "autocompletecell";
        if let cellToUse = cell{
            
        }
        else{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellString);
        }
        
        let data = autoCompleteDataSource[indexPath.row];
        var img:UIImage?;
        
        if(data == "Restaurant"){
            img = UIImage(named: "restaurent.png");
            
        }
        else if(data == "Airport"){
            img = UIImage(named: "airport.png");
        }
        else if(data == "Hospital"){
            img = UIImage(named: "hospital.png");
        }
        
        else if(data == "church"){
            img = UIImage(named: "church-icon.png");
        }
        else if(data == "mosque"){
            img = UIImage(named: "Mosque.png");
        }
        else if(data == "Atm"){
            img = UIImage(named: "atm-.png");
        }
        else if(data == "Bank"){
            img = UIImage(named: "bank.png");
        }
        else if(data == "Movie_theater"){
            img = UIImage(named: "cinema.png");
        }
        else{
            img = UIImage(named: "noimage.gif");
        }
        
        cell!.imageView!.image = img!;
        cell!.textLabel!.text = data;
        cell!.backgroundColor = UIColor(red: 100, green: 100, blue: 190, alpha: 0.5);
        
        return cell!;
    }

    
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
    
    func dataLoaded(userData:[SearchModel]){
       // print(userData);
         self.customAnotations.removeAll(keepCapacity: false);
        self.mapModels = userData;
             for searchModel in self.mapModels!{
            let customAnotation = CustomAnotation()
            customAnotation.coordinate = CLLocationCoordinate2D(latitude: searchModel.lat, longitude: searchModel.lon);
            customAnotation.title = "";
            customAnotation.subtitle = ""
            customAnotation.searchModel = searchModel;
            self.customAnotations.append(customAnotation)
        }
        
        self.zoomToFitMapAnnotations();
 
        
    }
    


    //the function fires after a text insertted in the search bar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
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

