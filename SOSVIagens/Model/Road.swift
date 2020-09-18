//
//  Road.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 27/03/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit

class Road: NSObject,Codable {

    var rodovia:String = ""
    var concessionaria:String = ""
    var telefone:String = ""
    
    public init(rodovia: String, concessionaria: String, telefone: String){
        self.rodovia = rodovia
        self.concessionaria = concessionaria
        self.telefone = telefone
    }
    
    
}

 
