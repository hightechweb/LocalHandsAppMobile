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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector
                (SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        getLatestOrder()
    }
    
    func getLatestOrder() {
        
        APIManager.shared.getLatestOrder { (json) in
            // console debug json response
            print(json)
            
            let order = json["order"]
            
            if let orderDetails = order["order_details"].array {
                
                self.lbStatus.text = order["status"].string!.uppercased()
                self.cart = orderDetails
                self.tbvTasks.reloadData()
            }
            
            let from = order["scooper"]["address"].string!
            let to = order["address"].string!
            
            // Map pin overlay labels
            self.getLocation(from, "Handler", { (src) in
                self.source = src
                
                self.getLocation(to, "Customer", { (des) in
                    self.destination = des
                    self.getDirections()
                })
            })
        }
    }
}

extension OrderViewController: MKMapViewDelegate {
    
    // #1 - Delegate mthod of MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    // #2 - Convert an address string to location on the map
    func getLocation(_ address: String,_ title: String,_ completionHandler: @escaping (MKPlacemark) -> Void) {
        

        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                print("Error: ", error)
            }
            
            if let placemark = placemarks?.first {
                
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                // Create map pin
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
                // show route
                self.showRoute(response: response!)
            }
            
        }
    }
    
    // #4 - Show route between location and make visible zoom
    func showRoute(response: MKDirectionsResponse) {
        
        for route in response.routes {
            self.map.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        
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
        cell.lbSubTotal.text = "$\(String(item["sub_total"].float!))"
        
        return cell
    }
}
