//
//  ContentViewController.swift
//  stopwatch
//
//  Created by jenkins on 28.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.titleText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
