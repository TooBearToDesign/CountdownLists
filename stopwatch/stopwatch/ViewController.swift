//
//  ViewController.swift
//  stopwatch
//
//  Created by jenkins on 25.09.15.
//  Copyright (c) 2015 Grow Association. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController!
    var pageTitles: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addStopwatchList("The first one!")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) 
        let viewCotrollers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewCotrollers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(index: Int) -> ContentViewController{
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)){
            return ContentViewController()
        }
        let vc: ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    // Add list manager
    func addStopwatchList(title: NSString){
        if (self.pageTitles == nil){
            self.pageTitles = NSMutableArray(objects: title)
        } else {
            self.pageTitles.addObject(title)
        }
        
    }
    // MARK: - page view controller data source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if ((index == 0) || (index == NSNotFound)){
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
    }
    
    func addListHandler(index: Int) -> UIViewController?{
        let alertController = UIAlertController(title: "Stopwatch", message: "Create a new list?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let createButton = UIAlertAction(title: "Create", style: UIAlertActionStyle.Default){ (ACTION) in
            self.addStopwatchList("A new one!"+String(index))
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(createButton)
        alertController.addAction(cancelButton)
        presentViewController(alertController, animated: true, completion: nil)
        
        if (index == self.pageTitles.count){
            return nil
        }else{
            return self.viewControllerAtIndex(index)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int

        if (index == NSNotFound){
            return nil
        }
        index++
        
        if (index == self.pageTitles.count){
            return addListHandler(index)
        }
        
        return self.viewControllerAtIndex(index)
    }
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

