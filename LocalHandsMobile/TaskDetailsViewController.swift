//
//  TaskDetailsViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/26/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class TaskDetailsViewController: UIViewController {

    @IBOutlet weak var imgTask: UIImageView!
    @IBOutlet weak var lbTaskName: UILabel!
    @IBOutlet weak var lbTaskShortDescription: UILabel!
    
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    
    var task: Task?
    var scooper: Scooper?
    var qty = 1
    
    //var scooper: Scooper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTask()
    }
    
    func loadTask() {
        
        if let price = task?.price {
            lbTotal.text = "$\(price)"
        }
        
        lbTaskName.text = task?.name
        lbTaskShortDescription.text = task?.short_description
        
        if let imageUrl = task?.image {
            Helpers.loadImage(imgTask, "\(imageUrl)")
        }
        
    }

    @IBAction func addQty(_ sender: AnyObject) {
        if qty < 99 {
            qty += 1
            lbQty.text = String(qty)
            
            if let price = task?.price {
                lbTotal.text = "$\(price * Float(qty))"
            }
        }
    }
    
    @IBAction func removeQty(_ sender: AnyObject) {
        if qty >= 2 {
            qty -= 1
            lbQty.text = String(qty)
            
            if let price = task?.price {
                lbTotal.text = "$\(price * Float(qty))"
            }
        }
    }
    
    @IBAction func addToCart(_ sender: AnyObject) {
        
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 48))
        image.image = UIImage(named: "button_chicken")
        image.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height-100)
        self.view.addSubview(image)
        
        UIView.animate(
           withDuration: 1.0,
           delay: 0.0,
           options: UIViewAnimationOptions.curveEaseOut,
           animations: { image.center = CGPoint(x: self.view.frame.width - 40, y:24) },
           completion: { _ in image.removeFromSuperview()
            
            
            let cartItem = CartItem(task: self.task!, qty: self.qty)
            
            guard let cartScooper = Cart.currentCart.scooper, let currentScooper = self.scooper
                else {
                // If those requirments are not met
                    
                Cart.currentCart.scooper = self.scooper
                Cart.currentCart.items.append(cartItem)
                return
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            // If ordering task from same scooper
            if cartScooper.id == currentScooper.id {
                let inCart = Cart.currentCart.items.index(where: { (item) -> Bool in
                    return item.task.id! == cartItem.task.id!
                })
                
                if let index = inCart {
                    let alertView = UIAlertController(
                        title: "Add more?",
                        message: "Your cart already has this task. Do you want to add more?",
                        preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(
                        title: "Add more",
                        style: .default,
                        handler: { (action: UIAlertAction!) in
                        
                        Cart.currentCart.items[index].qty += self.qty
                    })
                    
                    alertView.addAction(okAction)
                    alertView.addAction(cancelAction)
                    
                    self.present(alertView, animated: true, completion: nil)
                    
                } else {
                    Cart.currentCart.items.append(cartItem)
                }
            }
                
            else {// If ordering tasks from another scooper
                let alertView = UIAlertController(
                    title: "Start new order?",
                    message: "You're ordering a task from another scooper. Would you like to start a new order?",
                    preferredStyle: .alert)
                
                let okAction = UIAlertAction(
                    title: "New Order",
                    style: .default,
                    handler: { (action: UIAlertAction!) in
                        
                        Cart.currentCart.items = []
                        Cart.currentCart.items.append(cartItem)
                        Cart.currentCart.scooper = self.scooper
                })
                
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                
                self.present(alertView, animated: true, completion: nil)
            }
            
        })
    }
    
}
