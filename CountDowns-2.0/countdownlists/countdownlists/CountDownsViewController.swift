//
//  CountDownsViewController.swift
//  countdownlists
//
//  Created by Ivan Boychuk on 6/7/16.
//  Copyright © 2016 Ivan Boychuk. All rights reserved.
//

import UIKit

class CountDownsViewController: UIViewController {

    
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            MenuButton.target = self.revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
