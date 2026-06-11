//
//  ZZScrollView.swift
//  AppleVineger
//
//  Created by CZZ on 2020/7/21.
//  Copyright © 2020 czz. All rights reserved.
//

import UIKit
import WebKit
import ZZBase

// MARK: - ZZScrollView扩展

public extension UIView {
    func zz_toZZScrollItem(inset: UIEdgeInsets = .zero, minHeight: CGFloat = 0, fixedWidth: CGFloat = 0, maxHeight: CGFloat = 0) -> ZZScrollView.Item {
        return ZZScrollView.Item(view: self, inset: inset, minHeight: minHeight, fixedWidth: fixedWidth, maxHeight: maxHeight)
    }
}

public class ZZScrollView: UIScrollView {

    private static let itemObserverKey = "zzScrollView"
    private static let itemObserverKeyPaths = ["contentSize", "inset", "isHidden"]
    private static let contentOffsetObserverKey = "zzScrollView"

    private var isRefreshOffsetPending = false

    public class ZZScrollItem: Item { }

    public class Item: NSObject {

        private static let viewObserverKey = "zzScrollViewItem"

        /// 初始化一个ZZScrollView.Item
        /// - Parameters:
        ///   - view: 内容View
        ///   - inset: 内容相对缩进量
        ///   - minHeight: 最低高度
        ///   - fixedWidth: 固定宽度 与inset 冲突  当大于0 时 inset left right 失效
        public init(view: UIView, inset: UIEdgeInsets = .zero, minHeight: CGFloat = 0, fixedWidth: CGFloat = 0, maxHeight: CGFloat = 0) {
            super.init()
            self.view = view
            self.inset = inset
            self.minHeight = minHeight
            self.fixedWidth = fixedWidth
            self.maxHeight = maxHeight
            self.addObserver()
        }

        /// 创建一条分割线
        /// - Parameters:
        ///   - color: 颜色
        ///   - inset: insets
        ///   - height: 高度
        ///   - fixedWidth: 如果需要固定宽度  传大于0
        public init(line color: UIColor = UIColor.lightGray, inset: UIEdgeInsets = .zero, height: CGFloat = 6, fixedWidth: CGFloat = 0, maxHeight: CGFloat = 0) {
            super.init()
            let view = UIView()
            view.backgroundColor = color
            self.view = view
            self.inset = inset
            self.minHeight = height
            self.fixedWidth = fixedWidth
            self.maxHeight = maxHeight
            self.addObserver()
        }

        deinit {
            view?.zz_remoAllObservers()
        }

        private(set) public var minHeight: CGFloat = 0
        private(set) public var maxHeight: CGFloat = 0
        private(set) public var fixedWidth: CGFloat = 0
        private(set) public var view: UIView!
        @objc public dynamic var inset: UIEdgeInsets = .zero
        @objc private(set) public dynamic var contentSize: CGSize = .zero
        @objc private(set) public dynamic var isHidden: Bool = false

        public var hidden: Bool {
            get {
                return view.isHidden
            }
            set {
                view.isHidden = newValue
            }
        }

        private func addObserver() {
            if view is UIScrollView {
                let scView = view as! UIScrollView
                scView.isScrollEnabled = false
                scView.zz_addObserver("contentSize", key: Item.viewObserverKey, block: { [weak self] _ in
                    guard let self = self else { return }
                    var size = scView.contentSize
                    if size.height < self.minHeight, self.minHeight > 0 { size.height = self.minHeight }
                    if self.contentSize != size { self.contentSize = size }
                })
                var size = scView.contentSize
                if size.height < self.minHeight { size.height = self.minHeight }
                contentSize = size
            } else if view is WKWebView {
                let webView = view as! WKWebView
                webView.scrollView.isScrollEnabled = false
                webView.zz_addObserver("scrollView.contentSize", key: Item.viewObserverKey, block: { [weak self] _ in
                    guard let self = self else { return }
                    var size = webView.scrollView.contentSize
                    if size.height < self.minHeight, self.minHeight > 0 { size.height = self.minHeight }
                    if self.contentSize != size { self.contentSize = size }
                })
                var size = webView.scrollView.contentSize
                if size.height < self.minHeight, self.minHeight > 0 { size.height = self.minHeight }
                contentSize = size
            } else {
                view.zz_addObserver("frame", key: Item.viewObserverKey, block: { [weak self] _ in
                    guard let self = self else { return }
                    if self.view.zz_size != self.contentSize {
                        var size = self.view.zz_size
                        if size.height > self.maxHeight, self.maxHeight > 0 { size.height = self.maxHeight }
                        self.contentSize = size
                    }
                })
                var size = view.zz_size
                if size.height > self.maxHeight, self.maxHeight > 0 { size.height = self.maxHeight }
                contentSize = size
            }
            view.zz_addObserver("hidden", key: Item.viewObserverKey) { [weak self] _ in
                guard let self = self else { return }
                let hidden = self.view.isHidden
                if self.isHidden != hidden { self.isHidden = hidden }
            }
            isHidden = view.isHidden
        }
    }

    deinit {
        removeAllItemObservers()
        zz_remoAllObservers()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }

    public init(items: [Item] = []) {
        super.init(frame: .zero)
        _init()
        self.items = items
        addItems()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }

    private func _init() {
        zz_addObserver("contentOffset", key: ZZScrollView.contentOffsetObserverKey, block: { [weak self] _ in
            self?.scheduleRefreshOffset()
        })
        scheduleRefreshOffset()
    }

    public var items: [Item] = [] {
        willSet {
            items.forEach { item in
                removeItemObservers(item)
                item.view.removeFromSuperview()
            }
        }
        didSet {
            addItems()
        }
    }

    private func removeItemObservers(_ item: Item) {
        item.zz_removeObservers(ZZScrollView.itemObserverKeyPaths, key: ZZScrollView.itemObserverKey)
    }

    private func removeAllItemObservers() {
        items.forEach { removeItemObservers($0) }
    }

    private func bindItemObservers(_ item: Item) {
        removeItemObservers(item)
        item.zz_addObservers(ZZScrollView.itemObserverKeyPaths, key: ZZScrollView.itemObserverKey, block: { [weak self] _ in
            self?.scheduleRefreshOffset()
        })
    }

    private func addItems() {
        items.forEach { item in
            addSubview(item.view)
            bindItemObservers(item)
        }
        scheduleRefreshOffset()
    }

    private func scheduleRefreshOffset() {
        guard !isRefreshOffsetPending else { return }
        isRefreshOffsetPending = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isRefreshOffsetPending = false
            self.performRefreshOffset()
        }
    }

    public func refreshOffset() {
        scheduleRefreshOffset()
    }

    private func performRefreshOffset() {
        let offset = contentOffset.y
        var totalHeight: CGFloat = 0
        for index in 0 ..< items.count {
            let item = items[index]
            guard !item.view.isHidden else { continue }
            var viewHeight = item.contentSize.height
            var y = totalHeight + item.inset.top
            if item.view is UIScrollView || item.view is WKWebView {
                if viewHeight > zz_height {
                    viewHeight = zz_height
                }
                var scView: UIScrollView?
                if item.view is UIScrollView {
                    scView = item.view as? UIScrollView
                } else if item.view is WKWebView {
                    scView = (item.view as? WKWebView)?.scrollView
                }

                let maxScrolY = totalHeight + item.contentSize.height + item.inset.top + item.inset.bottom
                let minScrolY = totalHeight + item.inset.top
                if item.contentSize.height <= zz_height {
                    if scView?.contentOffset != .zero { scView?.contentOffset = .zero }
                } else if offset >= minScrolY && offset < maxScrolY {
                    if offset >= (maxScrolY - viewHeight - item.inset.bottom) {
                        y = (item.contentSize.height - viewHeight) + minScrolY
                        let subOffset = item.contentSize.height - viewHeight
                        let targetOffset = CGPoint(x: 0, y: subOffset)
                        if scView?.contentOffset != targetOffset { scView?.contentOffset = targetOffset }
                    } else {
                        y = offset
                        let subOffset = offset - minScrolY
                        let targetOffset = CGPoint(x: 0, y: subOffset)
                        if scView?.contentOffset != targetOffset { scView?.contentOffset = targetOffset }
                    }
                } else {
                    if scView?.contentOffset != .zero { scView?.contentOffset = .zero }
                }
            }
            var viewX: CGFloat = item.inset.left
            if viewHeight < item.minHeight, item.minHeight > 0 { viewHeight = item.minHeight }
            var viewWidth: CGFloat = zz_width - item.inset.left - item.inset.right
            if item.fixedWidth > 0 {
                viewWidth = item.fixedWidth
                viewX = (zz_width - viewWidth) / 2
            }

            let newFrame = CGRect(x: viewX, y: y, width: viewWidth, height: viewHeight)
            if item.view.frame != newFrame {
                item.view.frame = newFrame
            }
            totalHeight += (item.contentSize.height + item.inset.top + item.inset.bottom)
        }
        let newContentSize = CGSize(width: zz_width, height: totalHeight)
        if contentSize != newContentSize {
            contentSize = newContentSize
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        scheduleRefreshOffset()
    }
}
