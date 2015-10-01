//
//  TimerItem.swift
//  stopwatch
//
//  Created by jenkins on 30.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import Foundation

class TimerItem {
    
    var seconds = 0.0
    var minutes = 0.0
    var hours = 0.0
    
    var switchState = false
    var cellLabel = ""
    
    var countdownDisplay = ""
    
    var my_index = 0
    
    init(sec: Double, min: Double, hour: Double, swState: Bool, cLabel: String, index: Int){
        self.seconds = sec
        self.minutes = min
        self.hours = hour
        self.switchState = swState
        self.my_index = index
        self.cellLabel = cLabel
    }
}