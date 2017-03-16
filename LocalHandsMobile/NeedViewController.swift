//
//  NeedViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 2/7/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class NeedViewController: UIViewController {
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var tbvNeed: UITableView!
    @IBOutlet weak var lbNeedAddress: UILabel!
    @IBOutlet weak var lbNeedName: UILabel!
    @IBOutlet weak var searchNeed: UISearchBar!
    @IBOutlet weak var lbNeedPrice: UILabel!
    
    var needs = [Need]()
    var filteredNeeds = [Need]()
    
    let activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        loadNeeds()
    }
    
    
    func loadNeeds() {
        
        //showActivityIndicator()
        Helpers.showActivityIndicator(activityIndicator, view)
        
        APIManager.shared.getNeeds { (json) in
            
            if json != nil {
                
                self.needs = []
                
                print(json)
                
                if let listNeed = json["needs"].array {
                    for item in listNeed {
                        let need = Need(json: item)
                        self.needs.append(need)
                    }
                    self.tbvNeed.reloadData()
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
        if segue.identifier == "NeedList" {
            
            let controller = segue.destination as! NeedListTableViewController
            controller.need = needs[(tbvNeed.indexPathForSelectedRow?.row)!]
        }
    }
    
}


extension NeedViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredNeeds = self.needs.filter({ (res: Need) -> Bool in
            
            return res.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        self.tbvNeed.reloadData()
    }
}


extension NeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchNeed.text != "" {
            return self.filteredNeeds.count
        }
        
        return self.needs.count
        //return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NeedCell", for: indexPath) as! NeedViewCell
        
        let need: Need
        
        if searchNeed.text != "" {
            need = filteredNeeds[indexPath.row]
        } else {
            need = needs[indexPath.row]
        }
        
        
        cell.lbNeedName.text = need.name!
        cell.lbNeedAddress.text = need.short_description!
        
        if let price = need.price {
            cell.lbNeedPrice.text = "$\(price)"
        }
        
        if let logoName = need.image {
            //let url = "\(logoName)"
            Helpers.loadImage(cell.imgNeedLogo, "\(logoName)")
        }
        
        return cell
    }
    
}

