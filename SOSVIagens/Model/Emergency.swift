//
//  Emergency.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 28/11/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import Foundation

class Emergency: NSObject {
    var number: String = ""
    var type: String = ""
    var identification : String = ""
    var key: String = ""
    
    
    public init(key: String,number: String,
                type: String,
                identification: String){
        
        self.number = number
        self.type = type
        self.identification = identification
        
    }
}
