//
//  TransparentTableView.swift
//
//  Created by Luke on 23/08/2018.
//  Copyright © 2018 Luke. All rights reserved.
//

import UIKit

/// By default transparent tableView intended to allow displaying sibling views positioned -
/// in the table's content inset. The table view propagets touches detected on its content insets.
/// Note: Simple implementation for sibling view positioned at top content inset.
open class TransparentTableView: UITableView {

    let visibleBackgroundView = UIView()

    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        showsVerticalScrollIndicator = false
        backgroundView = UIView()
        backgroundView!.addSubview(visibleBackgroundView)
        estimatedSectionHeaderHeight = 10 // Any value above zero.
        backgroundColor = .clear
        visibleBackgroundView.backgroundColor = .groupTableViewBackground
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override var backgroundColor: UIColor? {
        get { return visibleBackgroundView.backgroundColor }
        set(color) {
            super.backgroundColor = .clear
            visibleBackgroundView.backgroundColor = color
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateVisibleBackgroundViewFrame()
    }

    func updateVisibleBackgroundViewFrame() {
        visibleBackgroundView.frame = backgroundView!.bounds
            .adding(dy: contentOffset.y + styleOffset, toBottom: false)
    }

    func isTouchPointInContentInset(_ point: CGPoint) -> Bool {
        return convert(point, to: self).y < 0
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isTouchPointInContentInset(point) {
            return superview?.hitTest(point, with: event)
        }
        return super.hitTest(point, with: event)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    open override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        let update = {
            super.setContentOffset(contentOffset, animated: false)
            self.updateVisibleBackgroundViewFrame()
        }
        animated ?  UIView.animate(withDuration: 0.3, animations: update) : update()
    }

    func setContentOffset(_ contentOffset: CGPoint, options: UIViewAnimationOptions = [], duration: TimeInterval = 0.3, delay: TimeInterval = 0, completion: ((Bool) -> ())? = nil) {
        let update = {
            super.setContentOffset(contentOffset, animated: false)
            self.updateVisibleBackgroundViewFrame()
        }
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: update, completion: completion)
    }

    var verticalOffsets = TableViewStyleVerticalOffsets(edgesForExtendedLayout: { .top }, statusBarHeight: { 0 })

    open override var contentInset: UIEdgeInsets {
        get { return super.contentInset }
        set {
            super.contentInset = newValue.addingTo(top: styleOffset)
        }
    }

    open override var contentSize: CGSize {
        get { return super.contentSize }
        set {
            super.contentSize = newValue.adding(dy: barOffset + 1)
        }
    }

    private var styleOffset: CGFloat {
        guard style == .grouped else {
            return verticalOffsets.barHeight
        }
        return verticalOffsets.offset + verticalOffsets.barHeight
    }

    private var barOffset: CGFloat {
        guard style == .grouped else {
            return 0
        }
        return verticalOffsets.barHeight
    }
}

struct TableViewStyleVerticalOffsets {
    let edgesForExtendedLayout: () -> UIRectEdge
    let statusBarHeight: () -> CGFloat

    var offset: CGFloat {
        return -CGFloat(edgesForExtendedLayout().rawValue) - statusBarHeight()
    }

    var barHeight: CGFloat {
        return -statusBarHeight()
    }
}


