//
//  Helpers.swift
//
//  Created by Luke on 09/09/2018.
//  Copyright © 2018 Luke. All rights reserved.
//

import UIKit

public protocol KeyboardFrameObserver: class {
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
    func keyboardWillShow(withAnimation options: UIViewAnimationOptions?, duration: TimeInterval?)

    /// Keyboard will hide with given animation `options` and `duration`
    /// `keyboardHeight` is set after this method is invoked.
    /// This is intended to allow operations that depend on `keyboardHeight` old value.
    /// - Parameter options: Animation options used by the system.
    /// - Parameter duration: Animation duration used by the system.
    func willHideKeyboard(withAnimation options: UIViewAnimationOptions?, duration: TimeInterval?)
}

public extension KeyboardFrameObserver {
    var notificationName: Notification.Name { return NSNotification.Name.UIKeyboardWillChangeFrame }

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
        guard notification.name == NSNotification.Name.UIKeyboardWillChangeFrame else {
            return
        }

        if let userInfo = notification.userInfo {
            let height: CGFloat = {
                /// UIScreen to keyboard bounds symmetric difference (Screen.bounds - Keyboard.bounds).
                let symmetricDifference = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
                let difference: CGRect = symmetricDifference?.cgRectValue ?? UIScreen.main.bounds
                return UIScreen.main.bounds.bottomY() - difference.origin.y
            }()

            let duration: TimeInterval? = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue

            let animationOptions: UIViewAnimationOptions? = {
                let rawValue: UInt? = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
                return  rawValue == nil ? nil : UIViewAnimationOptions.init(rawValue: rawValue!)
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
