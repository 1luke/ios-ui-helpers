//
//  Extensions.swift
//
//  Created by Luke on 23/08/2018.
//  Copyright © 2018 Luke. All rights reserved.
//

import UIKit

public extension CGRect {
    /// Returns orign at top right of the rect. Use `dx` and `dy` to apply offset on resulting origin.
    func topRight(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
        return CGPoint(x: origin.x + width + dx, y: origin.y + dy)
    }

    /// Returns orign at top right of the rect. Use `dx` and `dy` to apply offset on resulting origin.
    func topLeft(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
        return CGPoint(x: origin.x + dx, y: origin.y + height + dy)
    }

    /// Returns orign at bottom left of the rect. Use `dx` and `dy` to apply offset on resulting origin.
    func bottomLeft(dy: CGFloat = 0, dx: CGFloat = 0) -> CGPoint {
        return CGPoint(x: origin.x + dx, y: origin.y + height + dy)
    }

    /// Returns `y + height`.
    func bottomY(dy: CGFloat = 0) -> CGFloat {
        return bottomLeft(dy: dy).y
    }

    /// Returns orign at bottom right of the rect. Use `dx` and `dy` to apply offset on resulting origin.
    func bottomRight(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
        return CGPoint(x: topRight(dx: dx).x, y: bottomLeft(dy: dy).y)
    }

    /// Returns a rect adding given width `dx`. Moves `origin.x` if width is applied *not* `toRight`
    func adding(dx: CGFloat, toRight: Bool = true) -> CGRect {
        return CGRect(origin: toRight ? origin : origin.offsetting(xBy: -dx), width: width + dx, height: height)
    }

    func adding(dy: CGFloat, toBottom: Bool = true) -> CGRect {
        return CGRect(origin: toBottom ? origin : origin.offsetting(yBy: -dy), width: width, height: height + dy)
    }

    func substracting(dx: CGFloat, fromRight: Bool = true) -> CGRect {
        return CGRect(origin: fromRight ? origin : origin.offsetting(xBy: dx), width: width - dx, height: height)
    }

    init(origin: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(x: origin.x, y: origin.y, width: width, height: height)
    }

    init(origin: CGPoint, square: CGFloat) {
        self.init(x: origin.x, y: origin.y, width: square, height: square)
    }

    init(x: CGFloat, y: CGFloat, square: CGFloat) {
        self.init(x: x, y: y, width: square, height: square)
    }

    static var statusBar: CGRect {
        return UIApplication.shared.statusBarFrame
    }
}

public extension CGSize {
    init(square: CGFloat) {
        self.init(width: square, height: square)
    }

    static func +(lhs: CGSize, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.width + rhs.width, y: lhs.height + rhs.height)
    }

    func adding(dx: CGFloat = 0, dy: CGFloat = 0) -> CGSize {
        return CGSize(width: width + dx, height: height + dy)
    }
}

public extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    func offsetting(xBy dx: CGFloat = 0, yBy dy: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }

    func replacing(x dx: CGFloat? = nil, y dy: CGFloat? = nil) -> CGPoint {
        return CGPoint(x: dx ?? x, y: dy ?? y)
    }

    /// Mutates the `x` and/or `y` values of this CGPoint.
    mutating func set(x dx: CGFloat? = nil, y dy: CGFloat? = nil) {
        var point: CGPoint = .zero
        point.x = 8
        self = CGPoint(x: dx ?? x, y: dy ?? y)
    }

    init(dx: CGFloat = 0, dy: CGFloat = 0) {
        self.init(x: dx, y: dy)
    }
}

public extension UIScreen {
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
}

public extension UIEdgeInsets {
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }

    func addingTo(top t: CGFloat = 0, bottom b: CGFloat = 0, left l: CGFloat = 0, right r: CGFloat = 0) -> UIEdgeInsets {
        return UIEdgeInsets(top: top + t, bottom: bottom + b, left: left + l, right: right + r)
    }

    var horizontalInsets: CGFloat {
        return left + right
    }

    var verticalInsets: CGFloat {
        return top + bottom
    }
}

public extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview(_:))
    }
}

public extension UITextView {
    // Removes existing spell check redlines.
    func removeSpellCheckingFeedback() {
        let t = text
        text = t
    }
}

public extension UIViewController {
    /// The status bar frame currently displayed.
    /// Returns .zero for hidden status bar.
    var statusBarFrame: CGRect {
        return prefersStatusBarHidden ? .zero : CGRect.statusBar
    }
}
