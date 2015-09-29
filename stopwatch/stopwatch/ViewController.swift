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
    var pageTables:NSMutableArray!
    
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
    func addListHandler( index: Int) -> UIViewController?{
        addStopwatchList("Title+"+String(index))
        print(String(self.pageTitles.count))
        if (index == self.pageTitles.count){
            print("return nil:")
            return nil
        }else{
            print("return index:"+String(index))
            return self.viewControllerAtIndex(index)
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

