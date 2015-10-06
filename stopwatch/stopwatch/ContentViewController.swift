//
//  ContentViewController.swift
//  stopwatch
//
//  Created by jenkins on 28.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stopwatchLabel: UILabel!
    @IBOutlet weak var countsTabel: UITableView!
    @IBOutlet weak var startStopOutlet: UIButton!
    @IBOutlet weak var addToListOutlet: UIButton!
    @IBOutlet weak var stepperOutlet: UIStepper!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var addNewListOutlet: UIButton!
    
    // Variaables block
    var timer = NSTimer()
    var storeTimersList: [TimerItem] = []
    var hours = 0.0 as Double
    var minutes = 0.0 as Double
    var seconds = 0.0 as Double
    var stopwatchDisplay = ""
    var watchisRunning = false
    var addTimeToList = false
    var isListEmpty = true
    var currentWatchIndex = 0
    var timerIdChangedFromList = 0
    
    //Page view controller
    var pageIndex: Int!
    var titleText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.titleText
        self.loadData()
        if self.storeTimersList.count != 0 {
            self.isListEmpty = false
            self.clearButtonOutlet.enabled = true
            self.clearButtonOutlet.setTitle("Clear", forState: UIControlState.Normal)
        } else {
            self.clearButtonOutlet.enabled = false
            self.clearButtonOutlet.setTitle("Reset", forState: UIControlState.Normal)
        }
        self.countsTabel.reloadData()
    }
    
    // TableView Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var skipString = "Skip"
        if !self.storeTimersList[indexPath.row].switchState {
            skipString = "Back to list"
        }
        let alert = UIAlertView(title: "Manage timer", message: "You can delete or skip this timer", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete", skipString)
        self.timerIdChangedFromList = indexPath.row
        if !watchisRunning{
            alert.show()
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let buttonTitle = alertView.buttonTitleAtIndex(buttonIndex)
        if buttonTitle == "Delete" {
            self.storeTimersList.removeAtIndex(self.timerIdChangedFromList)
            if self.storeTimersList.count == 0 {
                self.isListEmpty = true
                self.clearButtonOutlet.setTitle("Reset", forState: UIControlState.Normal)
                if self.stopwatchDisplay == "00:00:00" {
                    self.clearButtonOutlet.enabled = false
                }
            }
        } else if buttonTitle == "Skip" {
            self.storeTimersList[self.timerIdChangedFromList].switchState = false
            self.storeTimersList[self.timerIdChangedFromList].skipLabel = "(skipped)"
        } else if buttonTitle == "Back to list" {
            self.storeTimersList[self.timerIdChangedFromList].switchState = true
            self.storeTimersList[self.timerIdChangedFromList].skipLabel = ""
        }
        self.countsTabel.reloadData()
        self.saveData()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PrototypeTableViewCell = self.countsTabel.dequeueReusableCellWithIdentifier("Cell") as! PrototypeTableViewCell
        cell.populateCell(String(indexPath.row+1)+") "+self.storeTimersList[indexPath.row].cellLabel+" "+self.storeTimersList[indexPath.row].skipLabel)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storeTimersList.count
    }
    //Save and load data
    func saveData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfListsKey = "savedTimersList"
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.storeTimersList)
        defaults.setObject(data, forKey: arrayOfListsKey)
    }
    func loadData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfListsKey = "savedTimersList"
        let unarchivedData = defaults.dataForKey(arrayOfListsKey)
        if unarchivedData != nil{
            self.storeTimersList = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedData!) as! [TimerItem]
            if self.storeTimersList.count != 0{
                self.isListEmpty = false
            }
        }
        
        defaults.synchronize()
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
        self.seconds = 0.0
        self.minutes = 0.0
        self.hours = 0.0
        self.stepperOutlet.value = 0.0
        self.populateStopwatchLabel()
        currentWatchIndex = 0
    }
    func countdownStopwatch(){
        if hours == 0.0 && minutes == 0.0 && seconds == 0.0{
            self.currentWatchIndex += 1
            if (self.storeTimersList.count > currentWatchIndex) {
                self.timer.invalidate()
                self.startCountdownTimer(currentWatchIndex)
            }else{
                stopCountdownTimer()
            }
        }else if seconds == 0.0 && minutes != 0.0{
            minutes -= 1.0
            seconds = 59.0
        }else{
            seconds--
        }
        if minutes == 0.0 && hours != 0.0 && seconds != 0.0 {
            hours -= 1.0
            minutes = 59.0
        }
        populateStopwatchLabel()
    }
    func reloadTimerList(){
        //TODO: When prototype switch has been changed - reload list with new values
    }
    func startCountdownTimer(var index: Int){
        if !watchisRunning {
            self.startStopOutlet.setTitle("STOP", forState: UIControlState.Normal)
            self.addToListOutlet.enabled = false
            self.stepperOutlet.enabled = false
            self.clearButtonOutlet.enabled = false
        }

        self.hours = self.storeTimersList[index].hours
        self.seconds = self.storeTimersList[index].seconds
        self.minutes = self.storeTimersList[index].minutes
        
        if self.storeTimersList[index].switchState {
            self.populateStopwatchLabel()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: ("countdownStopwatch"), userInfo: nil, repeats: true)
        } else {
            index += 1
            self.currentWatchIndex = index
            if self.storeTimersList.count != index{
                self.startCountdownTimer(index)
            } else {
                self.stopCountdownTimer()
            }
        }
    }
    func stopCountdownTimer(){
        timer.invalidate()
        self.startStopOutlet.setTitle("START", forState: UIControlState.Normal)
        self.addToListOutlet.enabled = true
        self.stepperOutlet.enabled = true
        self.clearButtonOutlet.enabled = true
        self.watchisRunning = false
        self.resetStopwatchLabel()
    }
    // Actions
    @IBAction func clearListAction(sender: AnyObject) {
        if self.stopwatchLabel.text == "00:00:00"{
            self.storeTimersList.removeAll()
            self.countsTabel.reloadData()
            self.resetStopwatchLabel()
            self.isListEmpty = true
            self.clearButtonOutlet.enabled = false
            self.clearButtonOutlet.setTitle("Reset", forState: .Normal)
            self.saveData()
        } else {
            self.resetStopwatchLabel()
            self.clearButtonOutlet.setTitle("Clear", forState: .Normal)
        }
    }
    @IBAction func addToListAction(sender: AnyObject) {
        if self.seconds == 0.0 && self.minutes == 0.0 && self.hours == 0.0 {
            //Null timer cannot be added
        } else {
            self.isListEmpty = false
            self.clearButtonOutlet.setTitle("Clear", forState: .Normal)
            self.storeTimersList.append(TimerItem(sec: self.seconds, min: self.minutes, hour: self.hours, swState: true, cLabel: stopwatchDisplay, index: self.storeTimersList.count))
            self.countsTabel.reloadData()
            self.resetStopwatchLabel()
            self.saveData()
        }
    }
    
    @IBAction func startStopAction(sender: AnyObject) {
        var nothingToStart = true
        for var i in self.storeTimersList {
            if i.switchState {
                nothingToStart = false
            }
        }
        if isListEmpty || nothingToStart {
            //nothing to do
        } else {
            if !watchisRunning{
                self.currentWatchIndex = 0
                self.startCountdownTimer(currentWatchIndex)
                self.watchisRunning = true
            }else{
                self.stopCountdownTimer()
                self.watchisRunning = false
            }
        }
    }
    
    @IBAction func addNewListAction(sender: AnyObject) {
    }
    
    @IBAction func stepperValueChanged(sender: AnyObject) {
        self.clearButtonOutlet.enabled = true
        self.clearButtonOutlet.setTitle("Reset", forState: .Normal)
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
