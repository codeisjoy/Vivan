//
//  PhotoListTableViewCell.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

class PhotoListTableViewCell: UITableViewCell {
    
    @IBOutlet var photoView: UIImageView?
    @IBOutlet var numberOfLikesLabel: UILabel?
    @IBOutlet var captionLabel: UILabel?
    
    var photo: String? {
        didSet { loadPhoto() }
    }
    
    private let network = NetworkCenter.defaultCenter
    private var downloadTask: NSURLSessionTask?
  
    private func loadPhoto() {
        photoView?.contentMode = .Center
        photoView?.image = UIImage(named: "Image")
        
        downloadTask?.cancel()
        downloadTask = network.getPhoto(photo) { [weak self] image, error in
            dispatch_async(dispatch_get_main_queue()) {
                self?.photoView?.contentMode = .ScaleAspectFill
                self?.photoView?.image = image
            }
        }
    }
}

final class DashedLabel: UILabel {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineDash(context, 0, [2, 1], 2)
        CGContextSetLineWidth(context, 1 / UIScreen.mainScreen().scale)
        CGContextSetStrokeColorWithColor(context, UIColor(white: 0.6, alpha: 1).CGColor)
        
        CGContextMoveToPoint(context, rect.minX, rect.maxY)
        CGContextAddLineToPoint(context, rect.maxX, rect.maxY)
        CGContextStrokePath(context)
        
        super.drawRect(rect)
    }
    
}