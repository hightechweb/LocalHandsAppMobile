//
//  NeedViewCell.swift
//  LocalHandsMobile
//
//  Created by Daniel on 2/7/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class NeedViewCell: UITableViewCell {
    
    // @IBOutlet weak var lbTaskName: UILabel!
    // @IBOutlet weak var lbTaskShortDescription: UILabel!
    // @IBOutlet weak var lbTaskPrice: UILabel!
    // @IBOutlet weak var imgTaskImage: UIImageView!
    
    @IBOutlet weak var lbNeedName: UILabel!
    @IBOutlet weak var lbNeedAddress: UILabel!
    @IBOutlet weak var imgNeedLogo: UIImageView!
    // @IBOutlet weak var lbScooperAddress: UILabel!
    @IBOutlet weak var lbNeedPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}
