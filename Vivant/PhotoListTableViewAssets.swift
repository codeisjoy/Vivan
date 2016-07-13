//
//  PhotoListTableViewCell.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

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
        label.font = UIFont.boldSystemFontOfSize(14)
        return label
    }()
    
    private var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .ExtraLight)
        let view = UIVisualEffectView(effect: effect)
        view.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return view
    }()
    
    // MARK: - Overriden Methods
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(effectView)
        
        effectView.contentView.addSubview(imageView)
        effectView.contentView.addSubview(titleLabel)
        
        backgroundView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        effectView.frame = bounds
        
        let rect = UIEdgeInsetsInsetRect(effectView.bounds, effectView.layoutMargins)
        let imageViewSize = imageView.sizeThatFits(rect.size)
        let tmp = rect.divide(imageViewSize.width, fromEdge: .MinXEdge)
        imageView.frame = tmp.slice
        titleLabel.frame = tmp.remainder.insetBy(dx: 6, dy: 0)
    }
    
}

// MARK: - PhotoListTableViewCell Class
// MARK: -

final class PhotoListTableViewCell: UITableViewCell {
    
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
        // Cancel the current task to kill the previous download job
        downloadTask?.cancel()
        // Start loading new assign photo and display it
        downloadTask = network.getPhoto(photo) { [weak self] image, error in
            dispatch_async(dispatch_get_main_queue()) {
                self?.photoView?.contentMode = .ScaleAspectFill
                self?.photoView?.image = image
            }
        }
    }
}

// MARK: - DashedLabel Class
// MARK: -

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