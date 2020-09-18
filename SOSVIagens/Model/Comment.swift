//
//  Road.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 27/03/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit

class Comment: NSObject {
    internal init(road: String, comment: String, concess: String, user: String, rating: Double) {
        self.road = road
        self.comment = comment
        self.concess = concess
         self.user = user
        self.rating = rating
    }
    
    
    var road:String
    var comment:String
    var concess:String
     var user:String
    var rating:Double
    
    
    
    
}


