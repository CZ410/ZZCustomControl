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

open class ZZScrollView: UIScrollView {
    @objc public class ZZScrollItem: Item{ }
    
    @objc public class Item: NSObject {
        
        /// 初始化一个ZZScrollView.Item
        /// - Parameters:
        ///   - view: 内容View
        ///   - inset: 内容相对缩进量
        ///   - minHeight: 最低高度
        ///   - fixedWidth: 固定宽度 与inset 冲突  当大于0 时 inset left right 失效
        @objc public init(view: UIView, inset: UIEdgeInsets = .zero, minHeight: CGFloat = 0, fixedWidth: CGFloat = 0, maxHeight: CGFloat = 0) {
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
        @objc public init(line color: UIColor = UIColor.lightGray, inset: UIEdgeInsets = .zero, height: CGFloat = 6, fixedWidth: CGFloat = 0, maxHeight: CGFloat = 0){
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
            self.removeObserver()
            self.view.zz_remoAllObservers()
        }

        private(set) public var minHeight: CGFloat = 0
        private(set) public var maxHeight: CGFloat = 0 // 当view 不为 uiscorollview及其子类时生效
        private(set) public var fixedWidth: CGFloat = 0 // 与inset 冲突  当大于0 时 inset left right 失效
        private(set) public var view: UIView!
        @objc public dynamic var inset: UIEdgeInsets = .zero
        @objc private(set) public dynamic var contentSize: CGSize = .zero
        @objc private(set) public dynamic var isHidden: Bool = false

        private func addObserver(){
            if self.view is UIScrollView{
                let scView = self.view as! UIScrollView
                scView.isScrollEnabled = false
                scView.zz_addObserver("contentSize", block: { [weak self] _ in
                    guard let `self` = self else { return }
                    var size = scView.contentSize
                    if size.height < self.minHeight, self.minHeight > 0 { size.height = self.minHeight }
                    self.contentSize = size
                })
                var size = scView.contentSize
                if size.height < self.minHeight { size.height = self.minHeight }
                self.contentSize = size
            }else if self.view is WKWebView{
                let webView = self.view as! WKWebView
                webView.scrollView.isScrollEnabled = false
                webView.zz_addObserver("scrollView.contentSize", block: {[weak self] _ in
                    guard let `self` = self else { return }
                    var size = webView.scrollView.contentSize
                    if size.height < self.minHeight, self.minHeight > 0 { size.height = self.minHeight }
                    self.contentSize = size
                })
                var size = webView.scrollView.contentSize
                if size.height < self.minHeight, self.minHeight > 0 { size.height = self.minHeight }
                self.contentSize = size
            }else{
                self.view.zz_addObserver("frame", block: {[weak self] _ in
                    guard let `self` = self else { return }
                    if self.view.zz_size != self.contentSize{
                        var size = self.view.zz_size
                        if size.height > self.maxHeight, self.maxHeight > 0 { size.height = self.maxHeight }
                        self.contentSize = size
                    }
                })
                var size = self.view.zz_size
                if size.height > self.maxHeight, self.maxHeight > 0 { size.height = self.maxHeight }
                self.contentSize = size
            }
            self.view.zz_addObserver("hidden") { [weak self] (_) in
                self?.isHidden = self?.view.isHidden ?? false
            }
        }

        private func removeObserver(){
            if self.view is UIScrollView{
                let scView = self.view as! UIScrollView
                scView.zz_removeObserver("contentSize")
            }else if self.view is WKWebView{
                let webView = self.view as! WKWebView
                webView.zz_removeObserver("scrollView.contentSize")
            }else{
                self.view.zz_removeObserver("frame")
            }
        }
    }

    deinit {
        self.zz_remoAllObservers()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self._init()
    }

    public init(items: [Item] = []) {
        super.init(frame: .zero)
        self.items = items
        self._init()
        self.addItems()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self._init()
    }

    private func _init(){
        self.zz_addObserver("contentOffset", block: { [weak self] _ in
            self?.refreshOffset()
        })
        self.refreshOffset()
    }

    open var items: [Item] = []{
        willSet{
            self.items.forEach({ $0.view.removeFromSuperview() })
        }
        didSet{
            self.addItems()
        }
    }

    private func addItems(){
        self.items.forEach({
            self.addSubview($0.view)
            $0.zz_addObservers(["contentSize", "inset", "isHidden"], block: {[weak self] _ in
                self?.refreshOffset()
            })
        })
        self.refreshOffset()
    }

    open func refreshOffset(){
        let offset = self.contentOffset.y
        /*
         1、contentSize.height 在页面内 跟着父窗体滚动
         2、contentSize.height 超出了界面 滚动子窗体。当子窗体滚动位置在界面中完全显示之后跟着父窗体滚动
         */
        var totalHeight: CGFloat = 0
        for index in 0 ..< self.items.count {
            let item = self.items[index]
            guard !item.view.isHidden else { continue }
            var viewHeight = item.contentSize.height
            var y = totalHeight + item.inset.top
            if (item.view is UIScrollView || item.view is WKWebView){
                if viewHeight > self.zz_height{
                    viewHeight = self.zz_height
                }
                var scView: UIScrollView?
                if item.view is UIScrollView{
                    scView = item.view as? UIScrollView
                }else if item.view is WKWebView{
                    scView = (item.view as? WKWebView)?.scrollView
                }
                
                let maxScrolY = totalHeight + item.contentSize.height + item.inset.top + item.inset.bottom
                let minScrolY = totalHeight + item.inset.top
                if item.contentSize.height <= self.zz_height {
                    scView?.contentOffset = .zero
                }else if offset >= minScrolY && offset < maxScrolY{ // scrollview 拖拽到进入 显示 到结束显示
                    if offset >= (maxScrolY - viewHeight - item.inset.bottom) {
                        y = (item.contentSize.height - viewHeight) + minScrolY
                        let subOffset = item.contentSize.height - viewHeight
                        scView?.contentOffset = CGPoint(x: 0, y: subOffset)
                    }else{
                        y = offset
                        let subOffset = offset - minScrolY
                        scView?.contentOffset = CGPoint(x: 0, y: subOffset)
                    }
                }else{
                    scView?.contentOffset = .zero
                }
            }
            var viewX:CGFloat = item.inset.left
            if viewHeight < item.minHeight, item.minHeight > 0 { viewHeight = item.minHeight }
            var viewWidth: CGFloat = self.zz_width - item.inset.left - item.inset.right
            if item.fixedWidth > 0 {
                viewWidth = item.fixedWidth
                viewX = (self.zz_width - viewWidth) / 2
            }
            
            let newFrame = CGRect(x: viewX, y: y, width: viewWidth, height: viewHeight)
            if item.view.frame != newFrame{
                item.view.frame = newFrame
            }
            totalHeight += (item.contentSize.height + item.inset.top + item.inset.bottom)
        }
        let newContentSize = CGSize(width: self.zz_width, height: totalHeight)
        if self.contentSize != newContentSize{
            self.contentSize = newContentSize
        }

    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.refreshOffset()
    }

}
