//
//  Cart.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/28/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import Foundation

class CartItem {
    
    var task: Task
    var qty: Int
    
    init(task: Task, qty: Int) {
        self.task = task
        self.qty = qty
    }
}

class Cart {
    
    static let currentCart = Cart()
    
    var scooper: Scooper?
    var items = [CartItem]()
    var address: String?
    
    func getTotal() -> Float {
        var total: Float = 0
        
        for item in self.items {
            total = total + Float(item.qty) * item.task.price!
            
        }
        
        return total
        
    }
    
    func reset() {
        self.scooper = nil
        self.items = []
        self.address = nil
    }
    
}
