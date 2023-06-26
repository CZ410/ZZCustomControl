//
//  UIScrollView+InsetView.swift
//  ZZBaseCustoms
//
//  Created by Czz on 2023/1/16.
//

import Foundation
import UIKit
import ZZBase

public extension UIScrollView{
    private var zz_topOldInsetView: UIView?{
        set { zz_objc_set(key: "zz_topOldInsetView", newValue) }
        get { return zz_objc_get(key: "zz_topOldInsetView", UIView.self) }
    }
    
    var zz_topInsetView: UIView?{
        set{
            guard newValue != zz_topOldInsetView else { return }
            zz_topOldInsetView?.removeFromSuperview()
            guard let v = newValue else {
                removeObserver()
                return
            }
            removeObserver()
            addObserver()
            zz_topOldInsetView = v
            refreshFrame()
        }
        get{
            return zz_topOldInsetView
        }
    }
    
    /// 顶部InsetView的真实高度
    var zz_topInsetViewHeight: CGFloat{
        set {
            zz_objc_set(key: "zz_topInsetViewHeight", newValue)
            self.contentInset = UIEdgeInsets(zz_top: newValue)
            self.scrollIndicatorInsets = UIEdgeInsets(zz_top: newValue)
            self.contentOffset = CGPoint(zz_y: -newValue)
            
            refreshFrame()
        }
        get { return zz_objc_get(key: "zz_topInsetViewHeight", CGFloat.self) ?? 0 }
    }
    
    var zz_topInsetViewWidth: CGFloat{
        set {
            zz_objc_set(key: "zz_topInsetViewWidth", newValue)
            refreshFrame()
        }
        get { return zz_objc_get(key: "zz_topInsetViewWidth", CGFloat.self) ?? 0 }
    }
    
    /// 顶部InsetView 在向⬆️拖拽时固定显示的高度，类似TableView的SectionHeader
    var zz_topInsetViewIgnoreHeight: CGFloat{
        set {
            zz_objc_set(key: "zz_topInsetViewIgnoreHeight", newValue)
            refreshFrame()
        }
        get { return zz_objc_get(key: "zz_topInsetViewIgnoreHeight", CGFloat.self) ?? 0 }
    }
    
    ///  是否固定InsetView在最顶部，向下拖拽超过inset top依然处于最顶部
    var zz_topInsetViewBindingTop: Bool{
        set { zz_objc_set(key: "zz_topInsetViewBindingTop", newValue) }
        get { return zz_objc_get(key: "zz_topInsetViewBindingTop", Bool.self) ?? false }
    }
    
    private func addObserver(){
        removeObserver()
        
        self.zz_addObservers(["frame", "bounds", "contentOffset"]) { [weak self] value in
            guard let `self` = self else { return }
            self.refreshFrame()
//            ZZLog(value.newValue)
        }
        
    }
    
    private func removeObserver(){
        zz_remoAllObservers()
    }
    
    private func refreshFrame(){
        guard let headerView = self.zz_topInsetView else { return }
        self.addSubview(headerView)

        var h_Frame = CGRect(x: 0, y: 0, width: (self.zz_topInsetViewWidth == 0) ? self.frame.width : self.zz_topInsetViewWidth, height: self.zz_topInsetViewHeight)
        h_Frame.zz_x = (self.frame.width - h_Frame.width) / 2.0
        let offsetY = self.contentOffset.y
        if offsetY <= -self.zz_topInsetViewHeight {
            h_Frame.origin.y = self.zz_topInsetViewBindingTop ? offsetY : -self.zz_topInsetViewHeight
        }else if (offsetY >= -self.zz_topInsetViewIgnoreHeight){
//            if offsetY > 0 {
//                self.contentInset = UIEdgeInsets(top: self.zz_headerViewShowHeight, left: 0, bottom: 0, right: 0)
//            }else{
//                self.contentInset = UIEdgeInsets(top: self.zz_headerViewHeight, left: 0, bottom: 0, right: 0)
//            }
            h_Frame.origin.y = offsetY - (self.zz_topInsetViewHeight - self.zz_topInsetViewIgnoreHeight)
        }else{
            h_Frame.origin.y = -self.zz_topInsetViewHeight
        }

        headerView.frame = h_Frame
    }
    
    
}
