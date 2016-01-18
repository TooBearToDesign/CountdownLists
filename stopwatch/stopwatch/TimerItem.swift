//
//  TimerItem.swift
//  stopwatch
//
//  Created by jenkins on 30.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import Foundation

class TimerItem: NSObject, NSCoding {
    
    var seconds = 0.0 as Double
    var minutes = 0.0 as Double
    var hours = 0.0 as Double
    
    var switchState = true
    var cellLabel = "" as String
    
    var countdownDisplay = "" as String
    
    init(sec: Double, min: Double, hour: Double, swState: Bool, cLabel: String){
        self.seconds = sec
        self.minutes = min
        self.hours = hour
        self.switchState = swState
        self.cellLabel = cLabel
    }
    
    // MARK: NSCoding
    
    required init (coder decoder: NSCoder){
        self.seconds = decoder.decodeDoubleForKey("seconds")
        self.minutes = decoder.decodeDoubleForKey("minutes")
        self.hours = decoder.decodeDoubleForKey("hours")
        self.switchState = decoder.decodeBoolForKey("switchState")
        self.cellLabel = decoder.decodeObjectForKey("cellLabel") as! String
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeDouble(self.seconds, forKey: "seconds")
        coder.encodeDouble(self.minutes, forKey: "minutes")
        coder.encodeDouble(self.hours, forKey: "hours")
        coder.encodeBool(self.switchState, forKey: "switchState")
        coder.encodeObject(self.cellLabel, forKey: "cellLabel")
    }
}