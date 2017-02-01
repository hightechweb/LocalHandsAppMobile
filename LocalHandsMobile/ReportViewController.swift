//
//  ReportViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/31/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
    }

}
