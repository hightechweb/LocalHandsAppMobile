//
//  DeliveryViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/31/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit
import MapKit

class DeliveryViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var lbCustomerName: UILabel!
    @IBOutlet weak var lbCustomerAddress: UILabel!
    @IBOutlet weak var imgCustomerAvatar: UIImageView!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bComplete: UIButton!
    
    var orderId: Int?
    
    var destination: MKPlacemark?
    var source: MKPlacemark?
    
    var locationManager: CLLocationManager!
    var driverPin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    var timer = Timer()
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Show current drivers's location
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
        
        // Running updating location process
        timer = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(updateLocation(_:)),
            userInfo: nil,
            repeats: true
        )
    }
    
    // call every 3 seconds to update drivers location on server
    func updateLocation(_ sender: AnyObject) {
        APIManager.shared.updateLocation(location: self.lastLocation) { (json) in
            // blank
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        
        //Helpers.showActivityIndicator(activityIndicator, self.view)
        
        APIManager.shared.getCurrentDriverOrder { (json) in
            //print(json)
            
            let order = json["order"]
            
            if let id = order["id"].int, order["status"] == "On the way" {
                
                self.orderId = id
                
                // 1. - customers order address on map
                let from = order["address"].string! //let customerAddress = order["address"].string!
                
                // 2. - drivers origin address on map, based on scooper/handler address
                let to = order["scooper"]["address"].string!
                
                let customerName = order["customer"]["name"].string!
                let customerAvatar = order["customer"]["avatar"].string!
                
                self.lbCustomerName.text = customerName
                self.lbCustomerAddress.text = from
                
                self.imgCustomerAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: customerAvatar)!))
                self.imgCustomerAvatar.layer.cornerRadius = 50/2
                self.imgCustomerAvatar.clipsToBounds = true
                
                // Map pin overlay labels
                self.getLocation(from, "CUS", { (src) in
                    self.source = src
                    
                    self.getLocation(to, "DRI", { (des) in
                        self.destination = des
                        // show blue line direction between endpoints
                        // self.getDirections()
                    })
                })
                // Helpers.hideActivityIndicator(self.activityIndicator)
                
            } else {
                self.map.isHidden = true
                self.viewInfo.isHidden = true
                self.bComplete.isHidden = true
                
                // Show message here for no pending orders
                let lbMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
                lbMessage.center = self.view.center
                lbMessage.textAlignment = NSTextAlignment.center
                lbMessage.text = "No orders for delivery."
                
                self.view.addSubview(lbMessage)
                // Helpers.hideActivityIndicator(self.activityIndicator)
            }
            
            // self.tableView.reloadData()
            
        }
    }
    
    @IBAction func completeOrder(_ sender: AnyObject) {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            APIManager.shared.compeleteOrder(orderId: self.orderId!, completionHandler: { (json) in
                if json != nil {
                    // Stop updating driver location
                    self.timer.invalidate()
                    self.locationManager.stopUpdatingLocation()
                    
                    // Redirect driver to Ready Order View
                    self.performSegue(withIdentifier: "ViewOrders", sender: self)
                }
            })
        }
        
        let alertView = UIAlertController(title: "Complete Order", message: "Are you sure?", preferredStyle: .alert)
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    
}


extension DeliveryViewController: MKMapViewDelegate {
    
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
    
//    // #3 - Get direction and zoom to address
//    func getDirections() {
//        
//        let request = MKDirectionsRequest()
//        request.source = MKMapItem.init(placemark: source!)
//        request.destination = MKMapItem.init(placemark: destination!)
//        request.requestsAlternateRoutes = false
//        
//        let directions = MKDirections(request: request)
//        directions.calculate { (response, error) in
//            
//            if error != nil {
//                print("Error: ", error)
//            } else {
//                // show route
//                self.showRoute(response: response!)
//            }
//            
//        }
//    }
//    
//    // #4 - Show route between location and make visible zoom
//    func showRoute(response: MKDirectionsResponse) {
//        
//        for route in response.routes {
//            self.map.add(route.polyline, level: MKOverlayLevel.aboveRoads)
//        }
//        
//        var zoomRect = MKMapRectNull
//        for annotation in self.map.annotations {
//            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
//            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
//            zoomRect = MKMapRectUnion(zoomRect, pointRect)
//        }
//        
//        let insetWidth = -zoomRect.size.width * 0.2
//        let insetHeight = -zoomRect.size.height * 0.2
//        let insetRect = MKMapRectInset(zoomRect, insetWidth, insetHeight)
//        
//        self.map.setVisibleMapRect(insetRect, animated: true)
//        
//    }
    
}


// CoreLocation Framework (self) for UI Map view get current location
extension DeliveryViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        self.lastLocation = location.coordinate
        
        // Create pin annotation for driver
        if driverPin != nil {
            driverPin.coordinate = self.lastLocation
        } else {
            driverPin = MKPointAnnotation()
            driverPin.coordinate = self.lastLocation
            self.map.addAnnotation(driverPin)
        }
        
        // Reset the zoom rect to cover 3 locations
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
        
//        let center = CLLocationCoordinate2D (
//            latitude: location.coordinate.latitude,
//            longitude: location.coordinate.longitude)
//        
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        
//        self.map.setRegion(region, animated: true)
        
    }
}

