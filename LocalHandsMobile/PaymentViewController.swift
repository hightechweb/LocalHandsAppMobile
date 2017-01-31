//
//  PaymentViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/26/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: UIViewController {

    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func placeOrder(_ sender: AnyObject) {
        
        APIManager.shared.getLatestOrder { (json) in
            
            if json["order"]["status"] == nil || json["order"]["status"] == "Delivered" {
                
                // Processing the payment and create an Order
                let card = self.cardTextField.cardParams
                
                STPAPIClient.shared().createToken(withCard: card, completion: { (token, error) in
                    if let myError = error {
                        print("Error: ", myError)
                    } else if let stripeToken = token {
                        APIManager.shared.createOrder(stripeToken: stripeToken.tokenId) { (json) in
                            Cart.currentCart.reset()
                            self.performSegue(withIdentifier: "ViewOrder", sender: self)
                        }
                    }
                })
                
            } else {
                // Showing an alert message - payment failed
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                let okAction = UIAlertAction(title: "Go to order", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "ViewOrder", sender: self)
                })
                
                let alertView = UIAlertController(title: "Already Order?", message: "Your current order is incomplete", preferredStyle: .alert)
                
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    

}
