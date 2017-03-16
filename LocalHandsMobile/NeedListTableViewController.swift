//
//  NeedListTableViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 2/8/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class NeedListTableViewController: UITableViewController {
    
    var scooper: Scooper?
    var needs = [Need]()
    var need: Need? // new
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scooperName = scooper?.name {
            self.navigationItem.title = scooperName
        }
        
        loadNeeds()
        
    }
    
    func loadNeeds() {
        
        Helpers.showActivityIndicator(activityIndicator, view)
        //showActivityIndicator()
        
        if let scooperId = scooper?.id {
            
            APIManager.shared.getTasks(scooperId: scooperId, completionHandler: { (json) in
                //print(json)
                
                if json != nil {
                    self.needs = []
                    
                    if let tempNeeds = json["needs"].array {
                        
                        for item in tempNeeds {
                            let need = Need(json: item)
                            self.needs.append(need)
                        }
                        
                        self.tableView.reloadData()
                        Helpers.hideActivityIndicator(self.activityIndicator)
                        //self.hideActivityIndicator()
                    }
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if segue.identifier == "NeedDetails" {
        if segue.identifier == "NeedList" {
            let controller = segue.destination as! NeedListTableViewController
            controller.need = needs[(tableView.indexPathForSelectedRow?.row)!]
            controller.scooper = scooper
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
    //            }.resume()
    //    }
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
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.needs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NeedCell", for: indexPath) as! NeedViewCell
        
        let need = needs[indexPath.row]
        cell.lbNeedName.text = need.name
        // cell.lbTaskShortDescription.text = need.short_description
        
        if let price = need.price {
            cell.lbNeedPrice.text = "$\(price)"
        }
        
        // not used for task images
        //        if let image = task.image {
        //            loadImage(imageView: cell.imgTaskImage, urlString: "\(image)")
        //        }
        
        //show scooper logo for task list view instead using Helper
        if let logo = scooper?.logo {
            Helpers.loadImage(cell.imgNeedLogo, "\(logo)")
        }
        
        return cell
    }
    
}

