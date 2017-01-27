//
//  User.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/27/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    
    var name: String?
    var email: String?
    var pictureURL: String?
    
    static let currentUser = User()
    
    func setInfo(json: JSON) {
        self.name = json["name"].string
        self.email = json["email"].string
        
        let image = json["picture"].dictionary
        let imageData = image?["data"]?.dictionary
        self.pictureURL = imageData?["url"]?.string
    }
    
    func resetInfo() {
        self.name = nil
        self.email = nil
        self.pictureURL = nil
    }
    
}
