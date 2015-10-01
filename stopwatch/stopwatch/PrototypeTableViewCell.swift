//
//  PrototypeTableViewCell.swift
//  stopwatch
//
//  Created by jenkins on 30.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import UIKit

class PrototypeTableViewCell: UITableViewCell {

    @IBOutlet weak var prototypeLabelCell: UILabel!
    @IBOutlet weak var prototypeSwitchCell: UISwitch!
    
    var prototypeCellIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCell(labelCell: String, switchCellState: Bool, index: Int){
        self.prototypeSwitchCell.setOn(false, animated: true)
        self.prototypeLabelCell.text = labelCell
        self.prototypeCellIndex = index
    }
}
