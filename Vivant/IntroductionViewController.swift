//
//  IntroductionViewController.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

final class IntroductionViewController: UIViewController {
    
    @IBOutlet private var loginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginButton?.backgroundColor = UIColor(red: 114 / 255, green: 184 / 255, blue: 37 / 255, alpha: 1)
    }

}

final class IntroductionPageViewController: UIPageViewController {
    
    private var pages: [UIViewController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        guard let
            introPage1 = storyboard?.instantiateViewControllerWithIdentifier("IntroPage1"),
            introPage2 = storyboard?.instantiateViewControllerWithIdentifier("IntroPage2"),
            introPage3 = storyboard?.instantiateViewControllerWithIdentifier("IntroPage3")
            else { return }
        
        pages = [introPage1, introPage2, introPage3]
        setViewControllers([introPage1], direction: .Forward, animated: false, completion: nil)
    }
    
}

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
