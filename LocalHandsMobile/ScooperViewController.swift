//
//  ScooperViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/22/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class ScooperViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var searchScooper: UISearchBar!
    @IBOutlet weak var tbvScooper: UITableView!
    
    var scoopers = [Scooper]()
    var filteredScoopers = [Scooper]()
    
    let activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector
                (SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        loadScoopers()
    }
    
    
    func loadScoopers() {
        
        //showActivityIndicator()
        Helpers.showActivityIndicator(activityIndicator, view)
        
        APIManager.shared.getScoopers { (json) in
            
            if json != nil {
                
                self.scoopers = []
                
                // print(json)
                if let listScoop = json["scoopers"].array {
                    for item in listScoop {
                        let scooper = Scooper(json: item)
                        self.scoopers.append(scooper)
                    }
                    self.tbvScooper.reloadData()
                    Helpers.hideActivityIndicator(self.activityIndicator)
                }
                // TESTING
                //for s in self.scoopers {
                //print(s.name)
                //}
            }
        }
    }
    
    
//    func loadImage(imageView: UIImageView, urlString: String) {
//        let imgURL: URL = URL(string: urlString)!
//        
//        URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
//            
//            guard let data = data, error == nil else { return }
//            
//            DispatchQueue.main.async(execute : {
//                imageView.image = UIImage(data: data)
//            })
//        }.resume()
//    }
//    
//    
//    func showActivityIndicator() {
//        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
//        activityIndicator.center = view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
//        activityIndicator.color = UIColor.black
//        
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//    }
//    
//    
//    func hideActivityIndicator() {
//        activityIndicator.stopAnimating()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Pass data from one controller to another using seque, AKA Header Title of Object
        if segue.identifier == "TaskList" {
            
            let controller = segue.destination as! TaskListTableViewController
            controller.scooper = scoopers[(tbvScooper.indexPathForSelectedRow?.row)!]
        }
    }
    
}


extension ScooperViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredScoopers = self.scoopers.filter({ (res: Scooper) -> Bool in
            
            return res.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        self.tbvScooper.reloadData()
    }
}


extension ScooperViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchScooper.text != "" {
            return self.filteredScoopers.count
        }
        
        return self.scoopers.count
        //return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScooperCell", for: indexPath) as! ScooperViewCell
        
        let scooper: Scooper
        
        if searchScooper.text != "" {
            scooper = filteredScoopers[indexPath.row]
        } else {
            scooper = scoopers[indexPath.row]
        }

        
        cell.lbScooperName.text = scooper.name!
        cell.lbScooperAddress.text = scooper.address!
        
        if let logoName = scooper.logo {
            //let url = "\(logoName)"
            Helpers.loadImage(cell.imgScooperLogo, "\(logoName)")
        }
        
        return cell
    }
    
}
