//
//  ConcessViewCell.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 28/10/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit

class ConcessViewCell: UITableViewCell {
 
    override func awakeFromNib() {
        super.awakeFromNib()
         // Initialization code
    }

    @IBOutlet weak var concessname: UILabel!
    @IBOutlet weak var roadname: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
