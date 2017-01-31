//
//  TaskViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/26/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TaskViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var tbvTasks: UITableView!
    @IBOutlet weak var viewTotal: UIView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var tbAddress: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bAddPayment: UIButton!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector
                (SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        if Cart.currentCart.items.count == 0 {
            // Show message here
            
            let lbEmptyCart = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
            lbEmptyCart.center = self.view.center
            lbEmptyCart.textAlignment = NSTextAlignment.center
            lbEmptyCart.text = "No Active Tasks. Go Search!"
            
            self.view.addSubview(lbEmptyCart)
            
        } else {
            // Display all of the UI controllers
            self.tbvTasks.isHidden = false
            self.viewTotal.isHidden = false
            self.viewAddress.isHidden = false
            self.viewMap.isHidden = false
            self.bAddPayment.isHidden = false
            
            loadTasks()
        }
        
        // Show current user's location
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
    }
    
    
    func loadTasks() {
        self.tbvTasks.reloadData()
        self.lbTotal.text = "$\(Cart.currentCart.getTotal())"
    }
    
    
    @IBAction func addPayment(_ sender: AnyObject) {
        
        if self.tbAddress.text == "" {
            // show alert that this field is required
            
            let alertController = UIAlertController(title: "Error", message: "Delivery Address Required", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in self.tbAddress.becomeFirstResponder()
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            Cart.currentCart.address = tbAddress.text
            self.performSegue(withIdentifier: "AddPayment", sender: self)
        }
    }

}

// CoreLocation Framework (self) for UI Map view get current location
extension TaskViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D (
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
    }
}


extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cart.currentCart.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskItemCell", for: indexPath) as!
            CartViewCell
        
        let cart = Cart.currentCart.items[indexPath.row]
        cell.lbQty.text = "\(cart.qty)"
        cell.lbTaskName.text = cart.task.name
        cell.lbSubTotal.text = "$\(cart.task.price! * Float(cart.qty))"
        
        return cell
    }
}

// Show map pin based on user input address txtField
extension TaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let address = textField.text
        let geocoder = CLGeocoder()
        Cart.currentCart.address = address
        
        geocoder.geocodeAddressString(address!) { (placemarks, error) in
            
            if (error != nil) {
                print("Error: ", error)
            }
            
            if let placemark = placemarks?.first {
                
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                let region = MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpanMake(0.01, 0.01)
                )
                
                self.map.setRegion(region, animated: true)
                self.locationManager.stopUpdatingLocation()
                
                // Create map pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                self.map.addAnnotation(dropPin)
                
            }
        }
        
        return true
    }
}
