//
//  NetworkCenter.swift
//  Vivant
//
//  Created by Emad A. on 13/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

// MARK: - Error Enum
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

// MARK: - NetworkCenter Class
// MARK: -

final class NetworkCenter {
    
    static let defaultCenter = NetworkCenter()
    /// Default URL from which photo posts can be fetched
    private let postsBaseURL = NSURL(string: "https://files.vivant.com.au/tech_exam/photo_posts.json")
    /// Base URL from which a photo can be downloaded
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