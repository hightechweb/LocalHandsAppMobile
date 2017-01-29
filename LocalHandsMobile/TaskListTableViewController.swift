//
//  TaskListTableViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/22/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class TaskListTableViewController: UITableViewController {
    
    var scooper: Scooper?
    var tasks = [Task]()
    
    let activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scooperName = scooper?.name {
            self.navigationItem.title = scooperName
        }
        
        loadTasks()
        
    }
    
    func loadTasks() {
        
        Helpers.showActivityIndicator(activityIndicator, view)
        //showActivityIndicator()
        
        if let scooperId = scooper?.id {
            
            APIManager.shared.getTasks(scooperId: scooperId, completionHandler: { (json) in
                //print(json)
                
                if json != nil {
                    self.tasks = []
                    
                    if let tempTasks = json["tasks"].array {
                        
                        for item in tempTasks {
                            let task = Task(json: item)
                            self.tasks.append(task)
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
        if segue.identifier == "TaskDetails" {
            let controller = segue.destination as! TaskDetailsViewController
            controller.task = tasks[(tableView.indexPathForSelectedRow?.row)!]
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
        return self.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskViewCell
        
        let task = tasks[indexPath.row]
        cell.lbTaskName.text = task.name
        cell.lbTaskShortDescription.text = task.short_description
        
        if let price = task.price {
            cell.lbTaskPrice.text = "$\(price)"
        }
        
        // not used for task images
//        if let image = task.image {
//            loadImage(imageView: cell.imgTaskImage, urlString: "\(image)")
//        }
        
        //show scooper logo for task list view instead using Helper
        if let logo = scooper?.logo {
            Helpers.loadImage(cell.imgTaskImage, "\(logo)")
        }
        
        return cell
    }

}
