//
//  ContentViewController.swift
//  stopwatch
//
//  Created by jenkins on 28.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stopwatchLabel: UILabel!
    @IBOutlet weak var countsTabel: UITableView!
    @IBOutlet weak var startStopOutlet: UIButton!
    @IBOutlet weak var addToListOutlet: UIButton!
    @IBOutlet weak var stepperOutlet: UIStepper!
    
    // Variaables block
    var timer = NSTimer()
    var timersList: [String] = []
    var hours = 0 as Double
    var minutes = 0 as Double
    var seconds = 0 as Double
    var stopwatchDisplay = ""
    var watchisRunning = false
    var addTimeToList = false
    var isListEmpty = true
    
    //Page view controller
    var pageIndex: Int!
    var titleText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.titleText
    }
    
    // TableView Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PrototypeTableViewCell = self.countsTabel.dequeueReusableCellWithIdentifier("Cell") as! PrototypeTableViewCell
        cell.populateCell(self.timersList[indexPath.row], switchCellState: true)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timersList.count
    }
    
    //Functions to work with stopwatch
    func populateStopwatchLabel(){
        let secondsString = seconds > 9 ? "\(Int(seconds))" : "0\(Int(seconds))"
        let minutesString = minutes > 9 ? "\(Int(minutes))" :"0\(Int(minutes))"
        let hoursString = hours > 9 ? "\(Int(hours))" :"0\(Int(hours))"
        
        stopwatchDisplay = "\(hoursString):\(minutesString):\(secondsString)"
        stopwatchLabel.text = stopwatchDisplay
    }
    func resetStopwatchLabel(){
        seconds = 0.0
        minutes = 0.0
        hours = 0.0
        self.stepperOutlet.value = 0.0
        populateStopwatchLabel()
    }
    func reloadTimerList(){
        //TODO: When prototype switch has been changed - reload list with new values
    }
    //Button views
    func changeStartStopState(){
        if isListEmpty {
            //nothing to do
        } else {
            if watchisRunning{
                self.startStopOutlet.setTitle("STOP", forState: UIControlState.Normal)
                self.addToListOutlet.enabled = false
                self.stepperOutlet.enabled = false
            }else{
                self.startStopOutlet.setTitle("START", forState: UIControlState.Normal)
                self.addToListOutlet.enabled = true
                self.stepperOutlet.enabled = true
            }
        }
    }
    // Actions
    @IBAction func addToListAction(sender: AnyObject) {
        if self.seconds == 0.0 &&
        self.minutes == 0.0 &&
        self.hours == 0.0 {
            //Null timer cannot be added
        } else {
            self.isListEmpty = false
            self.timersList.insert(stopwatchDisplay, atIndex: timersList.count)
            self.countsTabel.reloadData()
            self.resetStopwatchLabel()
        }
    }
    
    @IBAction func startStopAction(sender: AnyObject) {
        watchisRunning = !watchisRunning
        changeStartStopState()
    }
    
    @IBAction func stepperValueChanged(sender: AnyObject) {
        seconds = sender.value
        if seconds == 60.0{
            minutes += 1.0
            stepperOutlet.value = 0.0
            seconds = stepperOutlet.value
        }
        if minutes == 60.0 {
            hours += 1.0
            minutes = 0.0
        }
        populateStopwatchLabel()
    }
    
    // Dont really know what this is.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
