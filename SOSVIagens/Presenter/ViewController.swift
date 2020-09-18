//
//  ViewController.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 25/03/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController,CLLocationManagerDelegate {
    var ref: DatabaseReference!
    var databasehandler: DatabaseHandle?
    var rodovias = [String]()
    var number = ""
 
 
    

    @IBOutlet var navbar: UINavigationBar!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet var call_button: UIBarButtonItem!
    let locationmanager = CLLocationManager()
    
 
    override func viewDidLoad() {
         
        super.viewDidLoad()
        ref = Database.database().reference()

        locationmanager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationmanager.delegate = self
            locationmanager.desiredAccuracy = kCLLocationAccuracyBest
            locationmanager.startUpdatingLocation()
        }

    }
    
    
    
    
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            print(location.coordinate)
            let span = MKCoordinateSpan.init(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "There you are"
            map.setRegion(region, animated: true)
            map.addAnnotation(annotation)
            CLGeocoder().reverseGeocodeLocation(location){(CLPlacemark,error) in
                if error != nil {
                    print("Erro ao localizar")
                }else{
                    if let place = CLPlacemark?[0]{
                         let endereco = place.thoroughfare
                        self.title = endereco
                        self.ref?.child("rodovias")
                            .queryOrdered(byChild: "rodovia")
                            .queryStarting(atValue: "Rodovia Bandeirantes")
                            .queryEnding(atValue: "Rodovia Bandeirantes" +  "\u{f8ff}")
                            .observe(.childAdded, with:  { (snapshot) in
                                let phone = snapshot.childSnapshot(forPath: "telefone").value as! String
                                let concess = snapshot.childSnapshot(forPath: "concessionaria").value as! String
                                let roadname = snapshot.childSnapshot(forPath: "rodovia").value as! String
                                let road = Road()
                                if let r = snapshot.value as? Dictionary<String, AnyObject> {
                                    road.setValuesForKeys(r)
                                 }
                                 print("rodovia " + road.road)
                                annotation.coordinate = location.coordinate
                                annotation.title = roadname
                                annotation.subtitle = concess + " " + phone
 
                                
                                let annotationview = MKAnnotationView(annotation: annotation, reuseIdentifier: "customannotation")
                            
                                
                                annotationview.image = UIImage(named: "pin")
                                annotationview.canShowCallout = true
                                
                                
                                
                                
                                self.map.setRegion(region, animated: false)
                                self.map.addAnnotation(annotation)
                                if(!phone.isEmpty){
                                    self.call_button.isEnabled = true
                                    self.number = phone.replacingOccurrences(of: " ", with: "")
                                    self.number = self.number.replacingOccurrences(of: "-", with: "")
                                }
                                
                                
                                print(phone + " " + concess)
                                
                                
                                
                            }) { (error) in
                                print(error.localizedDescription)
                        }

                    }
                }
                
                
                
            }

        }
        
        
    }
    
    
    
    
    
    
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        print("Encontrando localização...")
        // Use the last reported location.
        if let lastLocation = locationmanager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                    
                                                }
                                                else {
                                                    // An error occurred during geocoding.
                                                    completionHandler(nil)
                                                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
      

}
