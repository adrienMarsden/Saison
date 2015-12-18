//
//  ViewController.swift
//  Saison
//
//  Created by Adrien Marsden on 6/14/15.
//  Copyright (c) 2015 Adrien Marsden. All rights reserved.
//

import UIKit
import MapKit
//import CoreData


class ViewController: UIViewController, MKMapViewDelegate {
    
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var speed = 50.0
    var rotating = true
    @IBOutlet weak var orbit: UIImageView!
    var manager:CLLocationManager!
    var carLocationData = CLLocation()
    var lastTenLocations = [CLLocation]()
    var lastTenLocationsNotes = [String]()
    //var parkedCars = [NSManagedObject]()

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var carLocation: UILabel!
    
    
    @IBAction func goToCurrentLocation(sender: AnyObject) {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        mapView.mapType = MKMapType.Satellite
        
        //mapView.layer.cornerRadius = 125.0
        //mapView.clipsToBounds = true
        manager.stopUpdatingLocation()

    }
    
    @IBAction func openInMap(sender: AnyObject) {

        var lastLong = Double()
        var lastLat = Double()

        if let longitude = prefs.stringForKey("location_long"){
            println("long: " + longitude)
            lastLong  =  (longitude as NSString).doubleValue
        }
        
        if let latitude = prefs.stringForKey("location_lat"){
            println("lat: " + latitude)
            lastLat  =  (latitude as NSString).doubleValue
            
        }

        openMapForPlace(lastLat, lon: lastLong)

    }
    
    
    
    
    
    
    @IBAction func saveCarLocation(sender: AnyObject) {
        

        
        var alert = UIAlertController(title: "Saved car location",
            message: "any special notes?",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "add note",
            style: .Default) { (action: UIAlertAction!) -> Void in
                let textField = alert.textFields![0] as! UITextField
                self.lastTenLocationsNotes.append(textField.text)
                self.prefs.setValue( textField.text, forKey: "note")


        }
        
        let cancelAction = UIAlertAction(title: "or nah",
            style: .Default) { (action: UIAlertAction!) -> Void in
                self.lastTenLocationsNotes.append("NULL")
                self.prefs.setValue( "none", forKey: "note")

        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)

        
    
        

    
        
        //delete all the old pins
        mapView.removeAnnotations(mapView.annotations)

        
        //update the location manager
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        
        carLocationData = manager.location
        
        
        //update last 10 locations
        if lastTenLocations.count >= 10{
            lastTenLocations.removeAtIndex(0)
            lastTenLocationsNotes.removeAtIndex(0)
        }

        lastTenLocations.append(carLocationData)
        println("\n\nlast 10 car locations \n\n\(lastTenLocations)")
    
        prefs.setValue(NSNumber(double: Double(carLocationData.coordinate.longitude)) ,forKey: "location_long")
        prefs.setValue(NSNumber(double: Double(carLocationData.coordinate.latitude)) ,forKey: "location_lat")
        prefs.setValue(NSNumber(double: Double(carLocationData.altitude)) ,forKey: "location_altitude")
        prefs.setValue(NSString(string: String(stringInterpolationSegment: carLocationData.timestamp)) ,forKey: "time")
        prefs.synchronize()
        
        carLocation.text = "saved car location"

        
    }
    
    
    func openMapForPlace(lat:Double, lon:Double) {
        
        var lat1 : Double = lat
        var lng1 : Double = lon
        
        var latitute:CLLocationDegrees =  lat1
        var longitute:CLLocationDegrees =  lng1
        
        let regionDistance:CLLocationDistance = 10000
        var coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        var options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        var mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "your car"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }

    
    
    
    
    
    
    
    @IBAction func getCarLocation(sender: AnyObject) {
        
        
        var locationString = "car not found :("
        var lastLong = Double()
        var lastLat = Double()
        var lastAlt = Double()
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let note = prefs.stringForKey("note"){
            println("note: " + note)
            locationString = String(note)

        }

        
        if let longitude = prefs.stringForKey("location_long"){
            println("long: " + longitude)
            lastLong  =  (longitude as NSString).doubleValue
        }
        
        if let latitude = prefs.stringForKey("location_lat"){
            println("lat: " + latitude)
            lastLat  =  (latitude as NSString).doubleValue

        }
        
        
        if let altitude = prefs.stringForKey("location_altitude"){
            println("alt: " + altitude)
            lastAlt  =  (altitude as NSString).doubleValue

        }
        
        if let time = prefs.stringForKey("time"){
            println("time: " + time)
        }
        println("last long is \(lastLong)")
        println("last lat is \(lastLat)")
        println("last alt is \(lastAlt)")
        
        
        
        mapView.removeAnnotations(mapView.annotations)
       
        
        //carLocation.text = "getting old car location \n Altitude \(lastTenLocations.last!.altitude) "
        //carLocation.text = "\(lastTenLocationsNotes.last!) \nAltitude: \(locationString)"

        var newYorkLocation = CLLocationCoordinate2DMake(lastLat, lastLong)
        // Drop a pin
        var dropPin = MKPointAnnotation()
        dropPin.coordinate = newYorkLocation
        dropPin.title = "hur yo car is"
        mapView.addAnnotation(dropPin)
        
        
        //stop tracking the user
        
        
        //center the screen on the annotation
        let location = CLLocationCoordinate2D(
            latitude: lastLat,
            longitude: lastLong
        )

        let span = MKCoordinateSpanMake(0.001, 0.001)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)

        
        

        
        /*
    
        let location = CLLocationCoordinate2D(
            latitude: carLocationData.coordinate.latitude,
            longitude: carLocationData.coordinate.longitude
        )
        // 2
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        //3
        let annotation = MKPointAnnotation()
        //annotation.setCoordinate(location)
        annotation.title = "Big Ben"
        annotation.subtitle = "London"
        mapView.addAnnotation(annotation)

        */
        /*
        let MasterAnnotation = AttractionAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
        mapView.addAnnotation(MasterAnnotation)
*/
        
        carLocation.text = "car location\nNote: \(locationString)\nAltitude: \(Int(lastAlt))ft"

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        mapView.mapType = MKMapType.Satellite

        //mapView.layer.cornerRadius = 125.0
        //mapView.clipsToBounds = true
        manager.stopUpdatingLocation()
        
        rotateOnce()
    }
    
    func rotateOnce() {
        UIView.animateWithDuration(speed,
            delay: 0.0,
            options: .CurveLinear,
            animations: {self.orbit.transform = CGAffineTransformRotate(self.orbit.transform, 3.1415926)},
            completion: {finished in self.rotateAgain()})
    }
    
    func rotateAgain() {
        UIView.animateWithDuration(speed,
            delay: 0.0,
            options: .CurveLinear,
            animations: {self.orbit.transform = CGAffineTransformRotate(self.orbit.transform, 3.1415926)},
            completion: {finished in if self.rotating { self.rotateOnce() }})
    }

    
    /*
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        // Below condition is for custom annotation
        if (annotation.isKindOfClass(CustomAnnotation)) {
            var customAnnotation = annotation as? CustomAnnotation
            mapView.setTranslatesAutoresizingMaskIntoConstraints(false)
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomAnnotation") as MKAnnotationView!
            
            if (annotationView == nil) {
                annotationView = customAnnotation?.annotationView()
            } else {
                annotationView.annotation = annotation;
            }
            
            self.addBounceAnimationToView(annotationView)
            return annotationView
        } else {
            return nil
        }
    }
*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

