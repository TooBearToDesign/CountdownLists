//
//  PrototypeTableViewCell.swift
//  stopwatch
//
//  Created by jenkins on 30.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import UIKit

class PrototypeTableViewCell: UITableViewCell {

    //@IBOutlet weak var prototypeLabelCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCell(labelCell: String){
        self.prototypeLabelCell.text = labelCell
    }
}
