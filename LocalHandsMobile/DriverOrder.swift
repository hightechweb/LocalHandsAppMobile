//
//  DriverOrder.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/31/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import Foundation
import SwiftyJSON

class DriverOrder {
    
    var id: Int?
    var customerName: String?
    var customerAddress: String? // orderAddress
    var customerAvatar: String?
    var scooperName: String?
    
    init(json: JSON) {
        
        self.id = json["id"].int
        self.customerName = json["customer"]["name"].string
        self.customerAddress = json["address"].string
        self.customerAvatar = json["customer"]["avatar"].string
        self.scooperName = json["scooper"]["name"].string
    }
    
}
