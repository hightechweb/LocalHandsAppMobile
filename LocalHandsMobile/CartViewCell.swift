//
//  CartViewCell.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/28/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class CartViewCell: UITableViewCell {

    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var lbTaskName: UILabel!
    @IBOutlet weak var lbSubTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        lbQty.layer.borderColor = UIColor.gray.cgColor
        lbQty.layer.borderWidth = 1.0
        lbQty.layer.cornerRadius = 10
    }

}
