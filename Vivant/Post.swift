//
//  Post.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import Foundation

struct Post {
    
    let photo: String
    let caption: String
    let photographer: String
    
    let likes: Int
    let isFavourite: Bool
    
    init(_ photo: String, _ caption: String, _ photographer: String, _ likes: Int, _ isFavourite: Bool) {
        self.photo = photo
        self.caption = caption
        self.photographer = photographer
        
        self.likes = likes
        self.isFavourite = isFavourite
    }
    
    var numberOfLikes: String {
        var value = (likes == 0 ? "No" : "\(likes)") + " Like"
        if likes > 1 { value += "s" }
        return value
    }
    
}