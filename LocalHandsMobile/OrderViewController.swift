//
//  OrderViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/26/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class OrderViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var tbvTasks: UITableView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lbStatus: UILabel!
    
    // display task ordered array in the table view
    var cart = [JSON]()
    
    // customer address
    var destination: MKPlacemark?
    
    // scooper address
    var source: MKPlacemark?
    
    // driver pin and timer to update
    var driverPin: MKPointAnnotation!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // START C - Hide all of the UI controllers - new dt
        self.tbvTasks.isHidden = true
        self.map.isHidden = true
        self.lbStatus.isHidden = true
        // END
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        getLatestOrder()
    }
    
    // GET THE MOST RECENT (LAST ORDER FOR CUSTOMER)
    func getLatestOrder() {
        
        APIManager.shared.getLatestOrder { (json) in
            // console debug json response
            print(json)
            
            let order = json["order"]
            
            // if order["status"] != nil { // ORIG
            if (order["status"] == "On the way" || order["status"] == "Delivered") {
                
                // START CHALLENGE - show all of the UI controllers
                self.tbvTasks.isHidden = false
                self.map.isHidden = false
                self.lbStatus.isHidden = false
                // END
                
                // show order
                if let orderDetails = order["order_details"].array {
                    
                    self.lbStatus.text = order["status"].string!.uppercased()
                    self.cart = orderDetails
                    self.tbvTasks.reloadData()
                }
                
                let from = order["scooper"]["address"].string!
                let to = order["address"].string!
                
                // Map pin overlay labels
                self.getLocation(from, "RES", { (src) in
                    self.source = src
                    
                    self.getLocation(to, "CUS", { (des) in
                        self.destination = des
                        self.getDirections()
                    })
                })
                
                if order["status"] != "Delivered" {
                    self.setTimer()
                }
            } else {
                // START CHALLENGE - show no order message and hide UI controls - NEW CHALLENGE #1
                let lbEmptyOrder = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
                lbEmptyOrder.center = self.view.center
                lbEmptyOrder.textAlignment = NSTextAlignment.center
                lbEmptyOrder.text = "No Active Orders!"
            
                self.view.addSubview(lbEmptyOrder)
                // END CHALLENGE
             }
        }
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(getDriverLocation(_:)),
            userInfo: nil, repeats: true)
    }
    
    func getDriverLocation(_ sender: AnyObject) {
        APIManager.shared.getDriverLocation { (json) in
            
            if let location = json["location"].string {
                
                self.lbStatus.text = "ON THE WAY"
                
                let split = location.components(separatedBy: ",")
                let lat = split[0]
                let lng = split[1]
                
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat)!, longitude: CLLocationDegrees(lng)!)
                
                // Create pin annotation for Driver
                if self.driverPin != nil {
                    self.driverPin.coordinate = coordinate
                } else {
                    self.driverPin = MKPointAnnotation()
                    self.driverPin.coordinate = coordinate
                    self.driverPin.title = "DRI"
                    self.map.addAnnotation(self.driverPin)
                }
                
                // Reset zoom rect to cover 3 locations
                self.autoZoom()
                
            } else {
                self.timer.invalidate()
            }
        }
    }
    
    func autoZoom() {
        var zoomRect = MKMapRectNull
        for annotation in self.map.annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        
        let insetWidth = -zoomRect.size.width * 0.2
        let insetHeight = -zoomRect.size.height * 0.2
        let insetRect = MKMapRectInset(zoomRect, insetWidth, insetHeight)
        
        self.map.setVisibleMapRect(insetRect, animated: true)
    }
    
}

extension OrderViewController: MKMapViewDelegate {
    
    // #1 - Delegate method of MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    // #2 - Convert an address string to a location on the map
    func getLocation(_ address: String,_ title: String,_ completionHandler: @escaping (MKPlacemark) -> Void) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                print("Error: ", error)
            }
            
            if let placemark = placemarks?.first {
                
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                // Create a pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = title
                
                self.map.addAnnotation(dropPin)
                completionHandler(MKPlacemark.init(placemark: placemark))
            }
        }
    }
    
    // #3 - Get direction and zoom to address
    func getDirections() {
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem.init(placemark: source!)
        request.destination = MKMapItem.init(placemark: destination!)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            
            if error != nil {
                print("Error: ", error)
            } else {
                // Show route
                self.showRoute(response: response!)
            }
        }
        
    }
    
    // #4 - Show route between locations and make a visible zoom
    func showRoute(response: MKDirectionsResponse) {
        
        for route in response.routes {
            self.map.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
    }
    
    // #5 - Customize map pin's with Images
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "Me"
        
        var annotationView: MKAnnotationView?
        if let dequeueAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            
            annotationView = dequeueAnnotationView
            annotationView?.annotation = annotation
        } else {
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView, let name = annotation.title! {
            switch name {
            case "DRI":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_car")
            case "RES":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_restaurant")
            case "CUS":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_customer")
            default:
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_car")
            }
        }
        
        return annotationView
    }
    
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderViewCell
        
        let item = cart[indexPath.row]
        cell.lbQty.text = String(item["quantity"].int!)
        cell.lbTaskName.text = item["task"]["name"].string
        
        // ORIG => (0.0)
        //cell.lbSubTotal.text = "$\(String(item["sub_total"].float!))"
        
        // NEW - float with 2 decimal places for currency (0.00)
        let value = item["sub_total"].float!
        cell.lbSubTotal.text = "$\(String(format:"%.2f", value))"
        // END
        
        return cell
    }
}
