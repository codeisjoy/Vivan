//
//  IntroductionViewController.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

final class IntroductionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
}

// MARK: - IntroductionPageViewController Class
// MARK: -

final class IntroductionPageViewController: UIPageViewController {
    
    private var pages: [UIViewController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        // Initialize the pages should be shown
        guard let
            introPage1 = storyboard?.instantiateViewControllerWithIdentifier("IntroPage1"),
            introPage2 = storyboard?.instantiateViewControllerWithIdentifier("IntroPage2"),
            introPage3 = storyboard?.instantiateViewControllerWithIdentifier("IntroPage3")
            else { return }
        
        pages = [introPage1, introPage2, introPage3]
        setViewControllers([introPage1], direction: .Forward, animated: false, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let ud = NSUserDefaults.standardUserDefaults()
        if ud.boolForKey(UserHasLoggedIn) == true {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}

// MARK: - UIPageViewControllerDataSource
// MARK: -

extension IntroductionPageViewController: UIPageViewControllerDataSource {
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages?.count ?? 0
    }
    
    func pageViewController(
        pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        guard let pages = pages,
            index = pages.indexOf(viewController)?.predecessor() where pages.indices ~= index
            else { return nil}
        
        return pages[index]
    }
    
    func pageViewController(
        pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        guard let pages = pages,
            index = pages.indexOf(viewController)?.successor() where pages.indices ~= index
            else { return nil }
        
        return pages[index]
    }
    
}
