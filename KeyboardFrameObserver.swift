//
//  Helpers.swift
//
//  Created by Luke on 09/09/2018.
//  Copyright © 2018 Luke. All rights reserved.
//

import UIKit

public protocol KeyboardFrameObserving: class {
    /// The keyboard height set by keyboard notification observer.
    ///
    /// * Appearing keyboard: value is set **before** _keyboardWillShow(withAnimation: duration:)_
    /// * Disappearing keyboard: value is set **after** _keyboardWillHide(withAnimation: duration:)_
    ///
    /// - Note: Never change this value manually.
    var keyboardHeight: CGFloat { get set }

    /// Initiate notification observing (call typically from init). **Implemented by default!**
    ///
    /// Pass a selector with `NSNotification` as its parameter.
    /// _didReceiveKeyboardNotification(: NSNotification)_
    /// must be called from the `selector`
    ///
    /// - Parameter selector: The selector that receives notifications.
    /// - Note: Ideally the selector would be implemented in extension, however
    ///         `@objc` can only be used in members of classes.
    func addKeyboardFrameObserver(selector: Selector, target: Any?)

    /// Keyboard will show with given animation `options` and `duration`
    /// `keyboardHeight` is set when this method is called.
    /// - Parameter options: Animation options used by the system.
    /// - Parameter duration: Animation duration used by the system.
    func keyboardWillShow(withAnimation options: UIView.AnimationOptions?, duration: TimeInterval?)

    /// Keyboard will hide with given animation `options` and `duration`
    /// `keyboardHeight` is set after this method is invoked.
    /// This is intended to allow operations that depend on `keyboardHeight` old value.
    /// - Parameter options: Animation options used by the system.
    /// - Parameter duration: Animation duration used by the system.
    func willHideKeyboard(withAnimation options: UIView.AnimationOptions?, duration: TimeInterval?)
}

public extension KeyboardFrameObserving {
    var notificationName: Notification.Name { return UIResponder.keyboardWillChangeFrameNotification }

    func addKeyboardFrameObserver(selector: Selector, target: Any? = nil) {
        NotificationCenter.default.addObserver(
            target ?? self,
            selector: selector,
            name: notificationName,
            object: nil)
    }

    func removeKeyboardFrameObserver(from target: Any? = nil) {
        NotificationCenter.default.removeObserver(target ?? self, name: notificationName, object: nil)
    }

    func didReceiveKeyboardNotification(_ notification: NSNotification) {
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
            return
        }

        if let userInfo = notification.userInfo {
            let height: CGFloat = {
                /// UIScreen to keyboard bounds symmetric difference (Screen.bounds - Keyboard.bounds).
                let symmetricDifference = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                let difference: CGRect = symmetricDifference?.cgRectValue ?? UIScreen.main.bounds
                return UIScreen.main.bounds.bottomY() - difference.origin.y
            }()

            let duration: TimeInterval? = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue

            let animationOptions: UIView.AnimationOptions? = {
                let rawValue: UInt? = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
                return  rawValue == nil ? nil : UIView.AnimationOptions.init(rawValue: rawValue!)
            }()

            if height > 0 {
                keyboardHeight = height
                keyboardWillShow(withAnimation: animationOptions, duration: duration)
            } else {
                willHideKeyboard(withAnimation: animationOptions, duration: duration)
                keyboardHeight = height
            }
        }
    }
}

public extension UIScrollView {
    /// Adjusts `contentInsets` for keyboard frame change.
    /// Initiate keyboaard observing to start `contentInsets` auto-adjustment.
    /// Remove keyboard observer to stop observing.
    public class ContentInsetsForKeyboardAdjuster: KeyboardFrameObserving {
        let scrollView: UIScrollView

        init(for scrollView: UIScrollView) {
            self.scrollView = scrollView
        }

        deinit {
            removeKeyboardFrameObserver()
        }

        public func startKeyboardFrameObserving() {
            addKeyboardFrameObserver(selector: #selector(keyboardNotification(notification:)))
        }

        @objc func keyboardNotification(notification: NSNotification) {
            didReceiveKeyboardNotification(notification)
        }

        private var initialContentInsets: UIEdgeInsets = .zero

        // MARK: KeyboardFrameObserver

        public var keyboardHeight: CGFloat = 0

        public func keyboardWillShow(withAnimation options: UIView.AnimationOptions?, duration: TimeInterval?) {
            initialContentInsets = scrollView.contentInset
            scrollView.contentInset = initialContentInsets.addingTo(bottom: keyboardHeight)
        }

        public func willHideKeyboard(withAnimation options: UIView.AnimationOptions?, duration: TimeInterval?) {
            scrollView.contentInset = initialContentInsets
        }
    }
}

/* Example usage:

 lazy var contentInsetsForKeyboardAdjuster: UITableView.ContentInsetsForKeyboardAdjuster = {
     return UITableView.ContentInsetsForKeyboardAdjuster(for: self.tableView)
 }()

 public override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     contentInsetsForKeyboardAdjuster.startKeyboardFrameObserving()
 }

 public override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     contentInsetsForKeyboardAdjuster.removeKeyboardFrameObserver()
 }

 */
