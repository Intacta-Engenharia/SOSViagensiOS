//
//  InitialViewController.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 11/11/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit
 import MapKit
class InitialViewController: UIViewController {
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let controller = storyboard.instantiateViewController(withIdentifier: "TabBarView")
             self.present(controller, animated: true, completion: nil)
        }else{
            locationManager?.requestWhenInUseAuthorization()
            return
        }
 
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
