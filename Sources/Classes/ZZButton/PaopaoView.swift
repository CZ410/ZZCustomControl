//
//  PaopaoView.swift
//  TianYiXing
//
//  Created by 陈钟 on 2019/8/5.
//  Copyright © 2019 陈钟. All rights reserved.
//

import UIKit

public class PaopaoView: ZZUILabel {

    public enum BindingAlignment {
        case TopRight
        case TopLeft
        case BottomRight
        case BottomLeft
        case LeftCenter
        case RightCenter
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    public override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        self.changeType = .All
        self.textAlignment = .center
        self.backgroundColor = UIColor.red
        self.addObserver()
    }
    /// 创建一个泡泡
    ///
    /// - Parameters:
    ///   - bindingView: 泡泡的位置相对位置View
    ///   - addView: 泡泡添加View
    public init(bindingView: UIView,addView: UIView) {
        super.init(frame: CGRect.zero)
        self.changeType = .All
        self.bindingView = bindingView
        self.superAddView = addView
        self.textAlignment = .center
        self.backgroundColor = UIColor.red
        self.addObserver()
    }
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "frame") {
            self.refreshContentFrame()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        self.removeObserver()
    }
    
    override public func refreshFrame() {
        super.refreshFrame()
        self.refreshContentFrame()
    }

    private func addObserver(){
        self.bindingView?.addObserver(self, forKeyPath: "frame", options: [.old,.new], context: nil)
        self.superAddView?.addObserver(self, forKeyPath: "frame", options: [.old,.new], context: nil)
        self.bindingView?.addObserver(self, forKeyPath: "bounds", options: [.old,.new], context: nil)
        self.superAddView?.addObserver(self, forKeyPath: "bounds", options: [.old,.new], context: nil)
    }

    private func removeObserver(){
        self.bindingView?.removeObserver(self, forKeyPath: "frame")
        self.superAddView?.removeObserver(self, forKeyPath: "frame")
        self.bindingView?.removeObserver(self, forKeyPath: "bounds")
        self.superAddView?.removeObserver(self, forKeyPath: "bounds")
    }

    //MARK: - datas
    public weak var bindingView: UIView?{
        willSet{
            self.bindingView?.removeObserver(self, forKeyPath: "frame")
            self.bindingView?.removeObserver(self, forKeyPath: "bounds")
        }
        didSet{
            self.bindingView?.addObserver(self, forKeyPath: "frame", options: [.old,.new], context: nil)
            self.bindingView?.addObserver(self, forKeyPath: "bounds", options: [.old,.new], context: nil)
            self.refreshContentFrame()
        }
    }

    public weak var superAddView: UIView?{
        willSet{
            self.superAddView?.removeObserver(self, forKeyPath: "frame")
            self.superAddView?.removeObserver(self, forKeyPath: "bounds")
        }
        didSet{
            self.superAddView?.addObserver(self, forKeyPath: "frame", options: [.old,.new], context: nil)
            self.superAddView?.addObserver(self, forKeyPath: "bounds", options: [.old,.new], context: nil)
            self.refreshContentFrame()
        }
    }

    public var bindingState: BindingAlignment = .TopRight{
        didSet{
            self.refreshContentFrame()
        }
    }
    
    /// 最小尺寸
    public var minSize:CGSize = CGSize.zero

    public var fiexSize:CGSize = CGSize.zero
    
    /// 中心点偏移量
    public var centerOffset: CGPoint = CGPoint.zero

    /// 当 bindView 为0时 默认一个计算的位置
    public var bindDefaultFrame: CGRect = CGRect.zero

    /// 是否以中心点排版 否则 以frame排版
    public var isBindToCenter: Bool = true{
        didSet{
            self.refreshContentFrame()
        }
    }
    
    
    //MARK: - methods
    private var isRefreshing: Bool = false
    public func refreshContentFrame() -> Void {
//        if isRefreshing { return }
        if self.text == "" || self.text?.count == 0 || self.text == nil {
            self.removeFromSuperview()
            return
        }
        isRefreshing = true
        if self.superview == nil {
            self.superAddView?.addSubview(self)
        }
        if self.fiexSize != CGSize.zero {
            self.zz_size = self.fiexSize
        }else{
            if self.zz_width < self.minSize.width && self.minSize != CGSize.zero {
                self.zz_width = self.minSize.width
            }
            if self.zz_height < self.minSize.height && self.minSize != CGSize.zero{
                self.zz_height = self.minSize.height
            }
        }
        guard let bindV = self.bindingView,let addView = self.superAddView else {
            isRefreshing = false
            return
        }

        var bindBounds = bindV.bounds
        if bindV.frame == CGRect.zero{
            bindBounds = self.bindDefaultFrame
        }
        let bindingFrame = bindV.convert(bindBounds, to: addView)

        if self.isBindToCenter {
            switch self.bindingState {
                case .TopLeft:
                    self.center = CGPoint(x: bindingFrame.minX + self.centerOffset.x,
                                          y: bindingFrame.minY + self.centerOffset.y)
                    break
                case .TopRight:
                    self.center = CGPoint(x: bindingFrame.maxX + self.centerOffset.x,
                                          y: bindingFrame.minY + self.centerOffset.y)
                    break
                case .BottomLeft:
                    self.center = CGPoint(x: bindingFrame.minX + self.centerOffset.x,
                                          y: bindingFrame.maxY + self.centerOffset.y)
                    break
                case .BottomRight:
                    self.center = CGPoint(x: bindingFrame.maxX + self.centerOffset.x,
                                          y: bindingFrame.maxY + self.centerOffset.y)
                    break
                case .LeftCenter:
                    self.center = CGPoint(x: bindingFrame.minX + self.centerOffset.x,
                                          y: bindingFrame.minY + (bindingFrame.height / 2) + self.centerOffset.y)
                    break
                case .RightCenter:
                    self.center = CGPoint(x: bindingFrame.maxX + self.centerOffset.x,
                                          y: bindingFrame.minY + (bindingFrame.height / 2) + self.centerOffset.y)
                    break
//                default:
//                    self.center = CGPoint.init(x: bindingFrame.maxX + self.centerOffset.x,
//                                               y: bindingFrame.minY + self.centerOffset.y)
//                    break
            }
        }else{
            var willChangeFrame = self.frame
            switch self.bindingState {
                case .TopLeft:
                    willChangeFrame.origin = CGPoint(x: bindingFrame.minX + self.centerOffset.x,
                                                     y: bindingFrame.minY + self.centerOffset.y)
                    break
                case .TopRight:
                    willChangeFrame.origin = CGPoint(x: bindingFrame.maxX + self.centerOffset.x,
                                                     y: bindingFrame.minY + self.centerOffset.y)
                    break
                case .BottomLeft:
                    willChangeFrame.origin = CGPoint(x: bindingFrame.minX + self.centerOffset.x,
                                                     y: bindingFrame.maxY + self.centerOffset.y)
                    break
                case .BottomRight:
                    willChangeFrame.origin = CGPoint(x: bindingFrame.maxX + self.centerOffset.x,
                                                     y: bindingFrame.maxY + self.centerOffset.y)
                    break
                case .LeftCenter:
                    willChangeFrame.origin = CGPoint(x: bindingFrame.minX + self.centerOffset.x,
                                                     y: bindingFrame.minY + ((bindingFrame.height - willChangeFrame.height) / 2) + self.centerOffset.y)
                    break
                case .RightCenter:
                    willChangeFrame.origin = CGPoint(x: bindingFrame.maxX + self.centerOffset.x,
                                                     y: bindingFrame.minY + ((bindingFrame.height - willChangeFrame.height) / 2) + self.centerOffset.y)
                    break
//                default:
//                    willChangeFrame.origin = CGPoint.init(x: bindingFrame.maxX + self.centerOffset.x,
//                                                          y: bindingFrame.minY + self.centerOffset.y)
//                    break
            }
            self.frame = willChangeFrame
        }
        isRefreshing = false
        self.superAddView?.bringSubviewToFront(self)
    }
    
    //MARK: - views
}
