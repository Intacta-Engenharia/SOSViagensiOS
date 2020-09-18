//
//  TableViewCell.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 25/04/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var phonenumber: UILabel!
    @IBOutlet weak var identification: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
            
        // Configure the view for the selected state
    }

}
