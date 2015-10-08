//
//  ContentViewController.swift
//  stopwatch
//
//  Created by jenkins on 28.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import UIKit
import AudioToolbox

class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stopwatchLabel: UILabel!
    @IBOutlet weak var countsTabel: UITableView!
    @IBOutlet weak var startStopOutlet: UIButton!
    @IBOutlet weak var addToListOutlet: UIButton!
    @IBOutlet weak var stepperOutlet: UIStepper!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var repeatSwitchOutlet: UISwitch!
    @IBOutlet weak var repeatTittleOutlet: UILabel!
    @IBOutlet weak var colorizeButtonOutlet: UIButton!
    
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
    
    //
    //Page view controller
    //
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
        self.updateColors()
    }
    //
    //      TableView Methods
    //
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
        } else if buttonTitle == "Back to list" {
            self.storeTimersList[self.timerIdChangedFromList].switchState = true
        }
        self.countsTabel.reloadData()
        self.updateColors()
        self.saveData()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.countsTabel.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = String(indexPath.row+1)+") "+self.storeTimersList[indexPath.row].cellLabel
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storeTimersList.count
    }
    //
    //      Colorized functions
    //
    func changeCellColor(index: Int, color: UIColor) {
        //Change cell color
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        let cell = self.countsTabel.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.textColor = color
    }
    func updateColors() {
        //Color variables
        var timersColor = UIColor.whiteColor()
        for var i in self.storeTimersList {
            timersColor = UIColor.blackColor()
            if !i.switchState {
                timersColor = UIColor.lightGrayColor()
            }
            self.changeCellColor(i.my_index, color: timersColor)
        }
    }
    //
    //      Hardware methods
    //
    func saveData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfListsKey = self.titleText
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.storeTimersList)
        defaults.setObject(data, forKey: arrayOfListsKey)
    }
    func loadData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfListsKey = self.titleText
        let unarchivedData = defaults.dataForKey(arrayOfListsKey)
        if unarchivedData != nil{
            self.storeTimersList = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedData!) as! [TimerItem]
            if self.storeTimersList.count != 0{
                self.isListEmpty = false
            }
        }
        
        defaults.synchronize()
    }
    func showNotification() {
        let localNotify = UILocalNotification()
        localNotify.alertBody = self.titleText+" has finished!"
        localNotify.timeZone = NSTimeZone.defaultTimeZone()
        localNotify.soundName = UILocalNotificationDefaultSoundName
        localNotify.category = "COUNTDOWN_CATEGORY"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotify)
    }
    func setBadgeNumber(incDec: Bool) {
        if incDec {
            UIApplication.sharedApplication().applicationIconBadgeNumber += 1
        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
        }
    }
    //
    //      Popover controller (colorized func)
    //
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "colorizeView" {
            let vc = segue.destinationViewController 
            let controller = vc.popoverPresentationController
            if controller != nil {
                controller?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    //
    //      Countdown functions
    //
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
        if self.isListEmpty {
            self.clearButtonOutlet.setTitle("Reset", forState: .Normal)
        } else {
            self.clearButtonOutlet.setTitle("Clear", forState: .Normal)
        }
    }
    func countdownStopwatch(){
        if hours == 0.0 && minutes == 0.0 && seconds == 0.0{
            self.currentWatchIndex += 1
            if (self.storeTimersList.count > currentWatchIndex) {
                self.timer.invalidate()
                self.startCountdownTimer(currentWatchIndex)
            }else{
                if self.repeatSwitchOutlet.on{
                    self.timer.invalidate()
                    self.startCountdownTimer(0)
                } else {
                    self.stopCountdownTimer()
                }
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
    func startCountdownTimer(var index: Int){
        if !watchisRunning {
            self.startStopOutlet.setTitle("STOP", forState: UIControlState.Normal)
            self.addToListOutlet.enabled = false
            self.stepperOutlet.enabled = false
            self.clearButtonOutlet.enabled = false
            self.setBadgeNumber(true)
        }

        self.hours = self.storeTimersList[index].hours
        self.seconds = self.storeTimersList[index].seconds
        self.minutes = self.storeTimersList[index].minutes
        
        if self.storeTimersList[index].switchState {
            self.populateStopwatchLabel()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: ("countdownStopwatch"), userInfo: nil, repeats: true)
            self.watchisRunning = true
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
        self.setBadgeNumber(false)
        self.showNotification()
    }
    //
    //      Actions
    //
    @IBAction func colorizeButtonAction(sender: AnyObject) {
        self.performSegueWithIdentifier("colorizeView", sender: self)
    }
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
        self.updateColors()
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
        for i in self.storeTimersList {
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
            }else{
                self.stopCountdownTimer()
            }
        }
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
