//
//  Section.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 10/12/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit

class Section: NSObject{
    var title = ""
    var items: [Emergency]
    init(title: String, items: [Emergency]){
        self.title = title
        self.items = items
    }
    
    
}


