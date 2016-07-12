//
//  PhotoListViewController.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

enum SegueIdentifier: String {
    case PresentIntroduction
}

final class PhotoListViewController: UITableViewController {
    
    private var network = NetworkCenter.defaultCenter
    private var posts: [Post]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl?.addTarget(self, action: #selector(fetchPosts), forControlEvents: .ValueChanged)
        
        tableView.sectionHeaderHeight = 38
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(PhotoListTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "PhotoHeader")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let ud = NSUserDefaults.standardUserDefaults()
        // If user has not been logged in before present intoroduction and login view ...
        if ud.boolForKey(UserHasLoggedIn) != true {
            performSegueWithIdentifier(SegueIdentifier.PresentIntroduction.rawValue, sender: self)
        }
        // Otherwise, fetch the posts from server and move on.
        else if posts == nil {
            fetchPosts()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let destination = segue.destinationViewController as? PhotoDetailViewController,
            selectedIndex = tableView.indexPathForSelectedRow?.section
        {
            destination.post = posts?[selectedIndex]
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func fetchPosts() {
        refreshControl?.beginRefreshing()
        network.getPosts { [weak self] posts, error in
            defer { self?.refreshControl?.endRefreshing() }
            guard error == nil else {
                self?.displayErrorController(error)
                return
            }
            self?.posts = posts
            dispatch_async(dispatch_get_main_queue()) {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func displayErrorController(error: Error?) {
        guard let error = error else { return }
        let controller = UIAlertController(title: "Oopsie", message: error.message, preferredStyle: .Alert)
        presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource / UITableViewDelegate Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("PhotoHeader")
        
        let post = posts?[section]
        if let header = header as? PhotoListTableHeaderView {
            header.titleLabel.text = post?.photographer
            header.imageView.image = UIImage(named: "user")
        }
        
        return header
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath)
        
        let post = posts?[indexPath.section]
        if let cell = cell as? PhotoListTableViewCell {
            cell.photo = post?.photo
            cell.captionLabel?.text = post?.caption
            cell.numberOfLikesLabel?.text = post?.numberOfLikes
        }
        
        return cell
    }
    
}
