//
//  Scooper.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/27/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import Foundation
import SwiftyJSON

class Scooper {
    
    var id: Int?
    var name: String?
    var address: String?
    var logo: String?
    var phone: String?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.address = json["address"].string
        self.logo = json["logo"].string
        self.phone = json["phone"].string
    }
}
