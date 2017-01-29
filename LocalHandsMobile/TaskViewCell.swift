//
//  TaskViewCell.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/27/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class TaskViewCell: UITableViewCell {

    @IBOutlet weak var lbTaskName: UILabel!
    @IBOutlet weak var lbTaskShortDescription: UILabel!
    @IBOutlet weak var lbTaskPrice: UILabel!
    @IBOutlet weak var imgTaskImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
