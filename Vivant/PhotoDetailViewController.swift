//
//  PhotoDetailViewController.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

final class PhotoDetailViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var photographerLabel: UILabel?
    @IBOutlet private var captionLabel: UILabel?
    
    @IBOutlet private var tView: UIView?
    @IBOutlet private var bView: UIView?
    
    @IBOutlet private var favouriteButton: HeartButton?
    
    var post: Post?
    
    private let network = NetworkCenter.defaultCenter
    private var downloadTask: NSURLSessionTask?
    
    private var displayInfoVisible: Bool = false
    
    // MARK: - Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tView?.hidden = true
        bView?.hidden = true
        
        photographerLabel?.text = post?.photographer
        captionLabel?.text = post?.caption
        
        favouriteButton?.selected = post?.isFavourite ?? false
        
        loadPhoto()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        downloadTask?.cancel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tView?.transform = CGAffineTransformMakeTranslation(0, (tView?.bounds.height ?? 0) * -1)
        bView?.transform = CGAffineTransformMakeTranslation(0, (bView?.bounds.height ?? 0))
        
        tView?.hidden = false
        bView?.hidden = false
        
        setDisplayInfo(visible: true)
    }
    
    // MARK: - Private Methods
    
    private func loadPhoto() {
        imageView?.contentMode = .Center
        imageView?.image = UIImage(named: "Image")
        // Cancel the current task to kill the previous download job
        downloadTask?.cancel()
        // Start loading new assign photo and display it
        downloadTask = network.getPhoto(post?.photo) { [weak self] image, error in
            dispatch_async(dispatch_get_main_queue()) {
                self?.imageView?.contentMode = .ScaleAspectFit
                self?.imageView?.image = image
            }
        }
    }
    
    private func setDisplayInfo(visible visible: Bool) {
        displayInfoVisible = visible
        
        let tViewTransform = visible ?
            CGAffineTransformIdentity :
            CGAffineTransformMakeTranslation(0, (tView?.bounds.height ?? 0) * -1)
        let bViewTransform = visible ?
            CGAffineTransformIdentity :
            CGAffineTransformMakeTranslation(0, (bView?.bounds.height ?? 0))
        
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: 7 << 16),
            animations: { [unowned self] in
                self.tView?.transform = tViewTransform
                self.bView?.transform = bViewTransform
            },
            completion: nil)
    }
    
    @objc private func didTap() {
        setDisplayInfo(visible: !displayInfoVisible)
    }
    
}

// MARK: - HeartButton Class
// MARK: -

final class HeartButton: UIButton {
    
    override var selected: Bool {
        didSet {
            setImage(UIImage(named: selected ? "like_filled" : "like_outline"), forState: .Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(didTouchUpInside), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Private Methods
    
    @objc private func didTouchUpInside() {
        selected = !selected
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0.8, 1.2, 0.9, 1]
        animation.duration = 0.25
        
        layer.addAnimation(animation, forKey: "bounce")
    }
    
}
