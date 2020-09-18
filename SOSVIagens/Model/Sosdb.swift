//
//  Sosdb.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 29/10/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit
import CoreTelephony


class Sosdb: NSObject {

    var road: Road
    var rootview : MapSceneViewController
    init(data: Road,rootview: MapSceneViewController) {
        self.road = data
        self.rootview = rootview
    }
    
   

    @objc func checkAction(sender : UITapGestureRecognizer) {
        // Do what you want
    }
    
     func call(){
        let phoneNumber = String(self.road.telefone.filter {$0 != " "})
           if UIApplication.shared.canOpenURL(URL(string: "tel://\(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))")!) {
               let networkInfo = CTTelephonyNetworkInfo()
               let carrier: CTCarrier? = networkInfo.subscriberCellularProvider
               let code: String? = carrier?.mobileNetworkCode
            let call = (URL(string: "tel://\(phoneNumber)"))!
            
               if (code != nil) {
                UIApplication.shared.open(call, options: [:]) { (Bool) in
                    self.rootview.addCommentController(animated: true, road: self.road)

                    
                }
               


               }
               else {
                   let alert = UIAlertController(title: "SIM Card not detected", message: "No SIM Card founded on your phone, it's imposssible to make a phone call in your device", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

                   rootview.present(alert, animated: true)
                }
           }
           else {
               let alert = UIAlertController(title: "Device does not support phone calls", message: "It seems your device does not support phone calls, we can't help you", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

               rootview.present(alert, animated: true)
           }
       }

    
    
    
    
    
    
    
    
}
