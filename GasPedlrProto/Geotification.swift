

import UIKit
import MapKit
import CoreLocation

let kGeotificationLatitudeKey = "latitude"
let kGeotificationLongitudeKey = "longitude"
let kGeotificationRadiusKey = "radius"
let kGeotificationIdentifierKey = "identifier"
let kGeotificationNoteKey = "note"
let kGeotificationEventTypeKey = "eventType"
let kGeotificationIconKey = "Icon"
let kGeotificationAddressKey = "Address"
let kGeotificationCouponKey = "Coupon"
enum EventType: Int {
  case OnEntry = 0
  case OnExit
}

class Geotification:  NSObject, NSCoding, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var radius: CLLocationDistance
  var identifier: String
  var note: String
var address : String
var coupon: String?
    var icon : String
  var eventType: EventType
  var searchModel:SearchModel!
   
  
 //
    
    var title: String? {
    if note.isEmpty {
      return "No Note"
    }
    return note
  }

  var subtitle: String? {
//    let eventTypeString = eventType == .OnEntry ? "On Entry" : "On Exit"
//    return "Radius: \(radius)m - \(eventTypeString)"
     return note
  }
    

   

    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String,  eventType: EventType , Model: SearchModel) {
    self.coordinate = coordinate
    self.radius = radius
    self.identifier = identifier
    self.note = Model.name
   self.icon = Model.icon
    self.address = Model.address
    self.coupon = Model.coupon
    self.eventType = eventType
    self.searchModel = Model
   
  }
    
    
  // MARK: NSCoding

  required init?(coder decoder: NSCoder) {
    let latitude = decoder.decodeDoubleForKey(kGeotificationLatitudeKey)
    let longitude = decoder.decodeDoubleForKey(kGeotificationLongitudeKey)
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    radius = decoder.decodeDoubleForKey(kGeotificationRadiusKey)
    identifier = decoder.decodeObjectForKey(kGeotificationIdentifierKey) as! String
    note = decoder.decodeObjectForKey(kGeotificationNoteKey) as! String
    eventType = EventType(rawValue: decoder.decodeIntegerForKey(kGeotificationEventTypeKey))!
    address = decoder.decodeObjectForKey(kGeotificationAddressKey) as! String
    coupon = decoder.decodeObjectForKey(kGeotificationCouponKey) as? String
    icon = decoder.decodeObjectForKey(kGeotificationIconKey) as! String
  
  }

  func encodeWithCoder(coder: NSCoder) {
    coder.encodeDouble(coordinate.latitude, forKey: kGeotificationLatitudeKey)
    coder.encodeDouble(coordinate.longitude, forKey: kGeotificationLongitudeKey)
    coder.encodeDouble(radius, forKey: kGeotificationRadiusKey)
    coder.encodeObject(identifier, forKey: kGeotificationIdentifierKey)
    coder.encodeObject(note, forKey: kGeotificationNoteKey)
    coder.encodeInt(Int32(eventType.rawValue), forKey: kGeotificationEventTypeKey)
    coder.encodeObject(icon, forKey: kGeotificationIconKey)
    coder.encodeObject(address, forKey: kGeotificationAddressKey)
   coder.encodeObject(coupon, forKey: kGeotificationCouponKey)
  }
}
