//
//  ContentViewController.swift
//  stopwatch
//
//  Created by jenkins on 28.09.15.
//  Copyright © 2015 Grow Association. All rights reserved.
//

import UIKit
import AVFoundation

class ContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate {

    //
    //      Outlets
    //
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stopwatchLabel: UILabel!
    @IBOutlet weak var countsTabel: UITableView!
    @IBOutlet weak var startStopOutlet: UIButton!
    @IBOutlet weak var addToListOutlet: UIButton!
    @IBOutlet weak var stepperOutlet: UIStepper!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var repeatSwitchOutlet: UISwitch!
    @IBOutlet weak var muteSwitchOutlet: UISwitch!
    @IBOutlet weak var repeatTittleOutlet: UILabel!
    @IBOutlet weak var muteTittleOutlet: UILabel!
    @IBOutlet weak var colorizeButtonOutlet: UIButton!
    
    //
    //      Variables block
    //
    var timer = NSTimer()
    var storeTimersList: [TimerItem] = []
    var storeColorTimer: ColorItem!
    var hours = 0.0 as Double
    var minutes = 0.0 as Double
    var seconds = 0.0 as Double
    var countdownDisplay = ""
    var watchisRunning = false
    var addTimeToList = false
    var isListEmpty = true
    var isMuted = false
    var isChanging = false
    var currentWatchIndex = 0
    var timerIdChangedFromList = 0
    var audioContinuousURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Continuous", ofType: "mp3")!)
    var audioStartURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Start", ofType: "wav")!)
    var audioStopURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Stop", ofType: "wav")!)
    var audioContinuousPlayer = AVAudioPlayer()
    var audioStartPlayer = AVAudioPlayer()
    var audioStopPlayer = AVAudioPlayer()
    //
    //      Strings
    //
    
    
    //
    //      Page view controller
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
        self.updateCellColors()
        do {
            try self.audioContinuousPlayer = AVAudioPlayer(contentsOfURL: self.audioContinuousURL)
            self.audioContinuousPlayer.numberOfLoops = -1
            try self.audioStartPlayer = AVAudioPlayer(contentsOfURL: self.audioStartURL)
            try self.audioStopPlayer = AVAudioPlayer(contentsOfURL: self.audioStopURL)
        } catch {
            // I dont really know what todo here
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    //
    //      TableView Methods
    //
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var skipString = "Skip"
        if !self.storeTimersList[indexPath.row].switchState {
            skipString = "Back to list"
        }
        let alert = UIAlertView(title: "Manage timer", message: "You can delete, change or skip this timer", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete", "Change", skipString)
        self.timerIdChangedFromList = indexPath.row
        if !watchisRunning && !isChanging{
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
                if self.countdownDisplay == "00:00:00" {
                    self.clearButtonOutlet.enabled = false
                }
            }
        } else if buttonTitle == "Change" {
            self.storeTimersList[self.timerIdChangedFromList].cellLabel += " waiting..."
            let alertChange = UIAlertView(title: "Change time", message: "Change time using stepper and press ADD to save", delegate: self, cancelButtonTitle: "OK")
            self.isChanging = true
            alertChange.show()
        } else if buttonTitle == "Skip" {
            self.storeTimersList[self.timerIdChangedFromList].switchState = false
        } else if buttonTitle == "Back to list" {
            self.storeTimersList[self.timerIdChangedFromList].switchState = true
        }
        self.countsTabel.reloadData()
        self.updateCellColors()
        self.checkAllSkipped()
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
    func changeViewColors() {
        self.titleLabel.textColor = self.storeColorTimer.defaultDisplayColor
        self.stopwatchLabel.textColor = self.storeColorTimer.defaultDisplayColor
        self.repeatTittleOutlet.textColor = self.storeColorTimer.defaultDisplayColor
        self.muteTittleOutlet.textColor = self.storeColorTimer.defaultDisplayColor
        
        self.stepperOutlet.tintColor = self.storeColorTimer.defaultButtonColor
        self.repeatSwitchOutlet.tintColor = self.storeColorTimer.defaultButtonColor
        self.muteSwitchOutlet.tintColor = self.storeColorTimer.defaultButtonColor
        self.startStopOutlet.setTitleColor(self.storeColorTimer.defaultButtonColor, forState: UIControlState.Normal)
        self.addToListOutlet.setTitleColor(self.storeColorTimer.defaultButtonColor, forState: UIControlState.Normal)
        self.clearButtonOutlet.setTitleColor(self.storeColorTimer.defaultButtonColor, forState: UIControlState.Normal)
        self.colorizeButtonOutlet.setTitleColor(self.storeColorTimer.defaultButtonColor, forState: UIControlState.Normal)
        
        self.repeatSwitchOutlet.onTintColor = self.storeColorTimer.defaultSwitchOnColor
        self.muteSwitchOutlet.onTintColor = self.storeColorTimer.defaultSwitchOnColor
    }
    func randomizeColor() -> UIColor {
        var r_color: UIColor!
        let r_red = CGFloat(drand48())
        let r_green = CGFloat(drand48())
        let r_blue = CGFloat(drand48())
        r_color = UIColor(red: r_red, green: r_green, blue: r_blue, alpha: 1.0)
        
        return r_color
    }
    func updateColors() {
        //Color variables
        if self.storeColorTimer == nil {
            self.storeColorTimer = ColorItem(button: UIColor.blackColor(), display: UIColor.blackColor(), switchon: UIColor.blackColor(), celllabel: UIColor.blackColor())
        }
        self.changeViewColors()
    }
    func updateCellColors() {
        for i in self.storeTimersList {
            self.changeCellColor((self.storeTimersList.indexOf(i))!, color: i.switchState ?  self.storeColorTimer.defaultCellLableColor : UIColor.lightGrayColor())
        }
    }
    //
    //      Hardware methods
    //
    func saveData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfListsKey = self.titleText
        let colorOfListsKey = self.titleText+"color"
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.storeTimersList)
        let color = NSKeyedArchiver.archivedDataWithRootObject(self.storeColorTimer)
        defaults.setObject(data, forKey: arrayOfListsKey)
        defaults.setObject(color, forKey: colorOfListsKey)
    }
    func loadData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfListsKey = self.titleText
        let colorOfListsKey = self.titleText+"color"
        let unarchivedData = defaults.dataForKey(arrayOfListsKey)
        let unarchivedColor = defaults.dataForKey(colorOfListsKey)
        if unarchivedData != nil{
            self.storeTimersList = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedData!) as! [TimerItem]
            if self.storeTimersList.count != 0{
                self.isListEmpty = false
            }
        }
        if unarchivedColor != nil {
            self.storeColorTimer = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedColor!) as! ColorItem
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
    func checkAllSkipped(){
        var allSkipped=true as Bool!
        if self.storeTimersList.count != 0{
            for i in self.storeTimersList {
                if i.switchState {
                    allSkipped = false
                }
            }
        } else {
            allSkipped = false
        }
        self.startStopOutlet.enabled = !allSkipped
    }
    func populateStopwatchLabel(){
        let secondsString = seconds > 9 ? "\(Int(seconds))" : "0\(Int(seconds))"
        let minutesString = minutes > 9 ? "\(Int(minutes))" :"0\(Int(minutes))"
        let hoursString = hours > 9 ? "\(Int(hours))" :"0\(Int(hours))"
        
        countdownDisplay = "\(hoursString):\(minutesString):\(secondsString)"
        stopwatchLabel.text = countdownDisplay
    }
    func resetStopwatchLabel(){
        self.seconds = 0.0
        self.minutes = 0.0
        self.hours = 0.0
        self.stepperOutlet.value = 0.0
        self.populateStopwatchLabel()
        currentWatchIndex = 0
        if self.isListEmpty {
            self.clearButtonOutlet.setTitle("Reset", forState: UIControlState.Normal)
        } else {
            self.clearButtonOutlet.setTitle("Clear", forState: UIControlState.Normal)
        }
    }
    func countdownStopwatch(){
        if hours == 0.0 && minutes == 0.0 && seconds == 0.0{
            self.currentWatchIndex += 1
            if (self.storeTimersList.count > currentWatchIndex) {
                self.audioStopPlayer.play()
                self.timer.invalidate()
                self.startCountdownTimer(currentWatchIndex)
            }else{
                if self.repeatSwitchOutlet.on{
                    self.audioStopPlayer.play()
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
        if self.storeTimersList[index].switchState {
            if !watchisRunning {
                self.startStopOutlet.setTitle("STOP", forState: UIControlState.Normal)
                self.addToListOutlet.enabled = false
                self.stepperOutlet.enabled = false
                self.clearButtonOutlet.enabled = false
                self.setBadgeNumber(true)
                self.audioStartPlayer.play()
                self.audioContinuousPlayer.play()
            }
            
            self.hours = self.storeTimersList[index].hours
            self.seconds = self.storeTimersList[index].seconds
            self.minutes = self.storeTimersList[index].minutes
        
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
        self.audioContinuousPlayer.stop()
        self.audioStopPlayer.play()
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
        //self.performSegueWithIdentifier("colorizeView", sender: self)
        //Sets random colors to the elemnts of the view
        if self.storeColorTimer == nil {
            self.storeColorTimer = ColorItem(button: self.randomizeColor(), display: self.randomizeColor(), switchon: self.randomizeColor(), celllabel: self.randomizeColor())
        } else {
            self.storeColorTimer.redefineColors(true, button: self.randomizeColor(), display: self.randomizeColor(), switchon: self.randomizeColor(), celllabel: self.randomizeColor())
        }
        self.updateColors()
        self.updateCellColors()
        self.saveData()
    }
    @IBAction func clearListAction(sender: AnyObject) {
        if self.stopwatchLabel.text == "00:00:00"{
            self.storeTimersList.removeAll()
            self.countsTabel.reloadData()
            self.resetStopwatchLabel()
            self.isListEmpty = true
            self.isChanging = false
            self.clearButtonOutlet.enabled = false
            self.clearButtonOutlet.setTitle("Reset", forState: UIControlState.Normal)
            self.saveData()
        } else {
            self.resetStopwatchLabel()
            self.clearButtonOutlet.setTitle("Clear", forState: UIControlState.Normal)
        }
        self.updateCellColors()
    }
    @IBAction func addToListAction(sender: AnyObject) {
        if self.seconds == 0.0 && self.minutes == 0.0 && self.hours == 0.0 {
            //Null timer cannot be added
        } else {
            self.isListEmpty = false
            self.clearButtonOutlet.setTitle("Clear", forState: UIControlState.Normal)
            if self.isChanging {
                self.storeTimersList.removeAtIndex(self.timerIdChangedFromList)
                self.storeTimersList.insert(TimerItem(sec: self.seconds, min: self.minutes, hour: self.hours, swState: true, cLabel: countdownDisplay), atIndex: self.timerIdChangedFromList)
                self.isChanging = false
            } else {
                self.storeTimersList.append(TimerItem(sec: self.seconds, min: self.minutes, hour: self.hours, swState: true, cLabel: countdownDisplay))
            }
            self.countsTabel.reloadData()
            self.resetStopwatchLabel()
            self.saveData()
        }
        self.updateCellColors()
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
        self.clearButtonOutlet.setTitle("Reset", forState: UIControlState.Normal)
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
    
    @IBAction func muteSwitchChanged(sender: AnyObject) {
        if self.muteSwitchOutlet.on {
            self.audioContinuousPlayer.volume = 1.0
            self.audioStartPlayer.volume = 1.0
            self.audioStopPlayer.volume = 1.0
        } else {
            self.audioContinuousPlayer.volume = 0.0
            self.audioStartPlayer.volume = 0.0
            self.audioStopPlayer.volume = 0.0
        }
    }
    // Dont really know what this is.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
