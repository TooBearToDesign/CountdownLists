//
//  ColorItem.swift
//  stopwatch
//
//  Created by jenkins on 08.10.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import Foundation
import UIKit

class ColorItem: NSObject, NSCoding {
    
    var defaultButtonColor: UIColor!
    var defaultDisplayColor: UIColor!
    var defaultSwitchOnColor: UIColor!
    var defaultCellLableColor: UIColor!
    
    init(button: UIColor, display: UIColor, switchon: UIColor, celllabel: UIColor){
        self.defaultButtonColor = button
        self.defaultDisplayColor = display
        self.defaultSwitchOnColor = switchon
        self.defaultCellLableColor = switchon
    }
    
    func redefineColors(button: UIColor, display: UIColor, switchon: UIColor, celllabel: UIColor){
        self.defaultButtonColor = button
        self.defaultDisplayColor = display
        self.defaultSwitchOnColor = switchon
        self.defaultCellLableColor = switchon
    }

    // MARK: NSCoding
    
    required init (coder decoder: NSCoder){
        self.defaultButtonColor = decoder.decodeObjectForKey("defaultButtonColor") as! UIColor
        self.defaultDisplayColor = decoder.decodeObjectForKey("defaultDisplayColor") as! UIColor
        self.defaultSwitchOnColor = decoder.decodeObjectForKey("defaultSwitchOnColor") as! UIColor
        self.defaultCellLableColor = decoder.decodeObjectForKey("defaultCellLableColor") as! UIColor
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.defaultButtonColor, forKey: "defaultButtonColor")
        coder.encodeObject(self.defaultDisplayColor, forKey: "defaultDisplayColor")
        coder.encodeObject(self.defaultSwitchOnColor, forKey: "defaultSwitchOnColor")
        coder.encodeObject(self.defaultCellLableColor, forKey: "defaultCellLableColor")
    }
}