//
//  LoginViewController.swift
//  Vivant
//
//  Created by Emad A. on 12/07/2016.
//  Copyright © 2016 Emad A. All rights reserved.
//

import UIKit

let UserHasLoggedIn = "UserHasLoggedIn"

class LoginViewController: UIViewController {
    
    @IBOutlet private var scrollView: UIScrollView?
    
    @IBOutlet private var usernameTextField: UITextField?
    @IBOutlet private var passwordTextField: UITextField?
    
    // MARK - Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter()
            .addObserver(
                self,
                selector: #selector(keyboardWillChangeFrame),
                name: UIKeyboardWillChangeFrameNotification,
                object: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func logIn() {
        forceResignFirstResponder()
        
        var isInvalid = false
        if let username = usernameTextField?.text where username == "vivan" {
            displayTextField(usernameTextField, invalid: false)
        } else {
            isInvalid = true
            displayTextField(usernameTextField, invalid: true)
        }
        
        if let password = passwordTextField?.text where password == "vivan" {
            displayTextField(passwordTextField, invalid: false)
        } else {
            isInvalid = true
            displayTextField(passwordTextField, invalid: true)
        }
        
        guard isInvalid == false else { return }
        
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setBool(true, forKey: UserHasLoggedIn)
        ud.synchronize()
        
        dismiss()
    }
    
    @IBAction func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func forceResignFirstResponder() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillChangeFrame(notice: NSNotification) {
        guard let
            scrollView = scrollView,
            frame = (notice.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            else { return }
        
        let duration = notice.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let curve = notice.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
        
        let scrollViewFrameInWindow = view.convertRect(scrollView.frame, toView: view.window)
        let bottomInset = CGRectGetMaxY(scrollViewFrameInWindow) - frame.origin.y
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        UIView.animateWithDuration(
            duration,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: curve << 16),
            animations: {
                scrollView.contentInset = inset
                scrollView.scrollIndicatorInsets = inset
            },
            completion: nil)
    }
    
    private func displayTextField(textField: UITextField?, invalid: Bool) {
        if textField?.rightView == nil {
            let error = UIImageView(image: UIImage(named: "error"))
            error.tintColor = UIColor(red: 208 / 255, green: 2 / 255, blue: 27 / 255, alpha: 1)
            textField?.rightView = error
        }
        
        textField?.rightViewMode = invalid ? .Always : .Never
    }
    
}

// MARK: - UITextFieldDelegate Extension
// MARK: -

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField?.becomeFirstResponder()
            return false
        } else if textField == passwordTextField {
            forceResignFirstResponder()
            return false
        }
        
        return true
    }
    
}

// MARK: - TextField Class
// MARK: -

final class RoundRectTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderStyle = .None
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextClearRect(context, rect)
        
        CGContextSetFillColorWithColor(context, UIColor(white: 0, alpha: 0.026).CGColor)
        
        let roundRect = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        CGContextAddPath(context, roundRect.CGPath)
        CGContextFillPath(context)
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        let rect = super.textRectForBounds(bounds)
        return rect.insetBy(dx: 6, dy: 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        let rect = super.editingRectForBounds(bounds)
        return rect.insetBy(dx: 6, dy: 0)
    }
    
    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.rightViewRectForBounds(bounds)
        rect.origin.x -= 6
        return rect
    }
    
}

final class RoundRectButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 4
    }
    
}
