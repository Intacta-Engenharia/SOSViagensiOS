//
//  MapSceneViewController.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 06/11/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit
import MapKit
import Floaty

class MapSceneViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    // MARK: - Outlets
     @IBOutlet weak var mapview: MKMapView!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var annotation:MKAnnotation!
    
    
    
    var showingcomment = false
    var currentLocation: CLLocation? = nil
    var mostRecentPlacemark: CLPlacemark? = nil
    var  lastGeocodeTime: Date? = nil
     var closed = false
    var currentplace = ""
    var suggested = false
    var road:Road!
    var pullUpController: ConcessViewController? = nil
     var concessionaries = [Road]()
    // MARK: - pullcontroler configuration
    
    
    
    
    
    var locationManager = CLLocationManager()

    internal func getLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest

        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .denied {
            print("User denied location permissions.")
        }
    }
   
    
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        switch status {

        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
    
        default:
            noauthorizationwarning()
            
        }
    }
    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        locationManager.delegate = self
        mapview.delegate = self
        
        //addPullUpController(animated: true, search: "")
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!self.showingcomment){
            if(pullUpController != nil){
                print("Search already showing")
                return
            }
            pullUpController = makeconcessview()
            setupPullUp()
        }
       
        switch CLLocationManager.authorizationStatus() {
        case .denied,.notDetermined,.restricted:
            noauthorizationwarning()
            self.findlocation.isUserInteractionEnabled = false
            break
        default:
            print("Autorizado a acessar localização")
            getLocation()
            self.findlocation.isUserInteractionEnabled = true
            self.findlocation.handleFirstItemDirectly = true
            self.findlocation.addItem(title: "Find my location!")

            self.findlocation.items[0].handler = { item in
                if(self.mostRecentPlacemark != nil && self.mostRecentPlacemark?.location != nil){
                    
                        self.movetolocation(location: (self.mostRecentPlacemark?.location)!)

                    

                    
                }else{
                    print("recent location not provided")
                }
            }
            
            
            
        }
 

    }
    
    
 
    
    func movetolocation(location: CLLocation){
        print("moving map")
        
        
        //self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.mapview.centerCoordinate = location.coordinate
        //self.mapview.addAnnotation(self.pinAnnotationView.annotation!)
    }
    
    func noauthorizationwarning(){
        self.locationManager.requestWhenInUseAuthorization()
        
    }
            
        
    
    func setupPullUp(){
         pullUpController!.rootview = self
        addPullUpController(pullUpController!,
                            initialStickyPointOffset: self.mapview.frame.size.height * 0.25,
                            animated: true)
    }
    
    private func setupCommentUp(){
           pullUpController!.preferredContentSize = self.mapview.frame.size
           pullUpController!.preferredContentSize.height = 0
           pullUpController!.rootview = self
           addPullUpController(pullUpController!,
                               initialStickyPointOffset: self.view.safeAreaLayoutGuide.layoutFrame.size.height,
                               animated: true)
       }
    
   
    
    func movemap(address: String){
        print("moving to " + address)
        let localSearchRequest = MKLocalSearch.Request()
       localSearchRequest.naturalLanguageQuery = address
       let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
        
        if localSearchResponse == nil{
            print("no address founded \n" + (error?.localizedDescription.description)!)
            return
        }
            
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = address
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapview.centerCoordinate = self.pointAnnotation.coordinate
            self.mapview.addAnnotation(self.pinAnnotationView.annotation!)
            
            
            

        }
    }
    
    func addCommentController(animated: Bool, road: Road){
        let screenSize: CGRect = UIScreen.main.bounds

        let pullUpController = makecommentview()
        pullUpController.road = road
        pullUpController.showviews()
         addPullUpController(pullUpController,
                             initialStickyPointOffset: screenSize.size.height,
                            animated: animated)
    }
    
    func makeconcessview() -> ConcessViewController{
        let currentPullUpController = children
            .filter({ $0 is ConcessViewController})
            .first as? ConcessViewController
        let pullUpController: ConcessViewController = currentPullUpController ?? UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "ConcessViewController") as! ConcessViewController
        return pullUpController
    }
    
    func makecommentview() -> CommentViewController{
           let currentPullUpController = children
               .filter({ $0 is CommentViewController})
               .first as? CommentViewController
           let pullUpController: CommentViewController = currentPullUpController ?? UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
           return pullUpController
       }
    
    
    func updatesearch(endereco: String, location: CLLocation){
       // let span = MKCoordinateSpan.init(latitudeDelta: 0.0010, longitudeDelta: 0.0010)
       // let region = MKCoordinateRegion(center:  location.coordinate, span: span)
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 3000)!, longitudinalMeters: CLLocationDistance(exactly: 3000)!)

        //let eyeCoordinate = CLLocationCoordinate2D(latitude: 58.571647, longitude: 16.234660)
    
        mapview.setRegion(region, animated: true)
        //mapview.addAnnotation(annotation)
       //mapview.setCamera(mapCamera, animated: true)
        self.pullUpController?.searchconcess(search: endereco)
        
        
    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            mapView.setUserTrackingMode(.followWithHeading, animated: true)

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied{
            noauthorizationwarning()
        }
    }
    
    @IBOutlet weak var findlocation: Floaty!
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let newLocation = userLocation.location else { return }
        
        let currentTime = Date()
        let lastLocation = self.currentLocation
        self.currentLocation = newLocation
        // Only get new placemark information if you don't have a previous location,
        // if the user has moved a meaningful distance from the previous location, such as 1000 meters,
        // and if it's been 60 seconds since the last geocode request.
        if let lastLocation = lastLocation,
            newLocation.distance(from: lastLocation) <= 2000,
            let lastTime = lastGeocodeTime,
            currentTime.timeIntervalSince(lastTime) < 60 {
            print("short time since last update")
            return
        }
        
        // Convert the user's location to a user-friendly place name by reverse geocoding the location.
        lastGeocodeTime = currentTime
        CLGeocoder().reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if placemarks?.first != nil &&
                placemarks?.first?.thoroughfare != self.mostRecentPlacemark?.thoroughfare{
                self.mostRecentPlacemark = placemarks?.first
                self.updatesearch(endereco: (self.mostRecentPlacemark?.thoroughfare)!, location: newLocation)

            }
            
            guard error == nil else {
                print("erro " + error!.localizedDescription)
                return
            }
            
            // Most geocoding requests contain only one result.
//            if let firstPlacemark = placemarks?.first {
//                self.mostRecentPlacemark = firstPlacemark
//                 print("Última localização " + (self.mostRecentPlacemark?.thoroughfare ?? "Nenhum"))
//
//                if firstPlacemark.thoroughfare == nil {
//                    return
//                }
//
//
//
//            }
            
        }
    }
    
    
    
}
