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
    var pageTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addListHandler(0)
        
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
        vc.pageIndex = index
        vc.titleText = self.pageTitles[index]
        
        return vc
    }
    
    // Add list manager
    func addStopwatchList(title: String){
        self.pageTitles.insert(title, atIndex: self.pageTitles.count)
    }
    func addListHandler( index: Int) -> UIViewController?{
        addStopwatchList("Countdown List #1")
        addStopwatchList("Countdown List #2")
        return self.viewControllerAtIndex(index)
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
            return nil
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

