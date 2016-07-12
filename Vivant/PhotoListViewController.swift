//
//  PhotoListViewController.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

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
        else {
            fetchPosts()
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
    
    // MARK: -
    
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

// MARK: - PhotoListTableHeaderView Class
// MARK: -

final class PhotoListTableHeaderView: UITableViewHeaderFooterView {
    
    private(set) var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .Center
        return view
    }()
    
    private(set) var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBold)
        return label
    }()
    
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .Horizontal
        view.spacing = 6
        return view
    }()
    
    private var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .ExtraLight)
        return UIVisualEffectView(effect: effect)
    }()
    
    // MARK: - Overriden Methods
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(effectView)
        
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 50, right: 12)
        stackView.layoutMarginsRelativeArrangement = true
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        effectView.contentView.addSubview(stackView)
        
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultLow + 1, forAxis: .Horizontal)
        
        backgroundView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        effectView.frame = bounds
        stackView.frame = effectView.bounds
    }
    
}

// MARK: - NetworkCenter Class
// MARK: -

enum Error: ErrorType {
    
    case Posts
    case Photo
    
    var message: String {
        switch self {
        case .Posts:
            return "Can't refresh posts. Try again later."
        case .Photo:
            return "Can't get photo. Try again later."
        }
    }
}

final class NetworkCenter {
    
    static let defaultCenter = NetworkCenter()
    /// Default URL from which photo posts can be fetched
    private let postsBaseURL = NSURL(string: "https://files.vivant.com.au/tech_exam/photo_posts.json")
    private let photoBaseURL = NSURL(string: "https://files.vivant.com.au/tech_exam/photos/")
    /// Default session responsible for sending tasks
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    // MARK: - Public Methods
    
    func getPosts(completion: ([Post]?, Error?) -> ()) -> NSURLSessionTask? {
        guard let url = postsBaseURL else { return nil }
        
        let task = session.dataTaskWithURL(url) { [weak self] data, response, error in
            guard let data = data where error == nil else {
                completion(nil, .Posts)
                return
            }
            // Parse the data
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: [[String: AnyObject]]]
                let posts = self?.populatePosts(from: json?["posts"])
                completion(posts, nil)
            } catch {
                completion(nil, .Posts)
            }
        }
        task.resume()
        return task
    }
    
    func getPhoto(photo: String?, completion: (UIImage?, Error?) -> ()) -> NSURLSessionTask? {
        guard let photo = photo,
            url = NSURL(string: photo, relativeToURL: photoBaseURL)
            else { return nil }
        
        let task = session.downloadTaskWithURL(url) { imageURL, response, error in
            guard let imageURL = imageURL where error == nil  else {
                completion(nil, .Photo)
                return
            }
            var image: UIImage?
            if let data = NSData(contentsOfURL: imageURL) {
                image = UIImage(data: data)
            }
            completion(image, nil)
        }
        task.resume()
        return task
    }
    
    // MARK: - Private Methods
    
    /// Converts the given array of raw data from server to an array of app lication 'Post' model.
    private func populatePosts(from source: [[String: AnyObject]]?) -> [Post]? {
        guard let source = source else { return nil }
        
        var posts = [Post]()
        for post in source {
            guard let
                caption      = post["caption"]          as? String,
                photo        = post["photo_file_name"]  as? String,
                photographer = post["photographer"]     as? String,
                likes        = post["number_of_likes"]  as? Int,
                favourite    = post["is_favourite"]     as? Bool
                else { continue }
            posts.append(Post(photo, caption, photographer, likes, favourite))
        }
        return posts
    }
}
