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
    
    //Variables section
    var hours = 0 as Double
    var minutes = 0 as Double
    var seconds = 0 as Double
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCell(labelCell: String, switchCellState: Bool){
        self.prototypeSwitchCell.setOn(switchCellState, animated: true)
        self.prototypeLabelCell.text = labelCell
    }
    @IBAction func prototypeSwitchCellChanged(sender: AnyObject) {
    }

}
