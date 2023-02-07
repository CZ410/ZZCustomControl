//
//  ZZLabel.swift
//  CzzSwTest
//
//  Created by 陈钟 on 2018/9/30.
//  Copyright © 2018年 陈钟. All rights reserved.
//

import UIKit
import ZZBase

public class ZZUILabel: UILabel {

    public struct ChangeFrameWithSetText : OptionSet {
        public var rawValue: UInt

        public init(rawValue: ZZUILabel.ChangeFrameWithSetText.RawValue) {
            self.rawValue = rawValue
        }

        public static let Width    = ChangeFrameWithSetText(rawValue: 1 << 0)
        public static let Height  = ChangeFrameWithSetText(rawValue: 1 << 1)
        public static let Nothing  = ChangeFrameWithSetText(rawValue: 1 << 2)

        public static let All: ChangeFrameWithSetText = [.Width, .Height]
    }

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    //MARK: - 配置
    
    /// 当settext是改变frame的类型 默认nothing 不改变
    public var changeType : ChangeFrameWithSetText! = [.Nothing]
    
    @discardableResult
    open func changeType(_ type: ChangeFrameWithSetText) -> Self{
        self.changeType = type
        return self
    }
    
    
    /// 修改label的最大宽度  默认0
    public var willChangedMaxWidth : CGFloat = 0
    
    @discardableResult
    open func willChangedMaxWidth(_ width: CGFloat) -> Self{
        self.willChangedMaxWidth = width
        return self
    }
    
    /// 修改label的最大高度  默认0
    public var willChangedMaxHeight : CGFloat = 0
    
    @discardableResult
    open func willChangedMaxHeight(_ height: CGFloat) -> Self{
        self.willChangedMaxHeight = height
        return self
    }
    
    /// textChangedBlock
    public typealias textChangedAlias = (_ label:UILabel) -> ()
    public var textChangedBlock : textChangedAlias?
    
    @discardableResult
    open func textChangedBlock(_ block: textChangedAlias?) -> Self{
        self.textChangedBlock = block
        return self
    }
    
    
    /// textChangedBlock
    public typealias textAutoLayoutChangedAlias = (_ label:UILabel,_ size:CGSize) -> ()
    public var textAutoLayoutChangedBlock : textAutoLayoutChangedAlias?
    
    open func setTextAutoLayoutChanged(block:@escaping textAutoLayoutChangedAlias) -> Void {
        self.textAutoLayoutChangedBlock = block
    }
    
    @discardableResult
    open func textAutoLayoutChangedBlock(_ block: textAutoLayoutChangedAlias?) -> Self{
        self.textAutoLayoutChangedBlock = block
        return self
    }
    
    override public var text: String?{
        didSet{
            self.refreshFrame()
        }
    }
    
//    @discardableResult
//    open func text(_ text: String?) -> Self{
//        self.text = text
//        return self
//    }
    
    
    private var _attributedText: NSAttributedString?
    override public var attributedText: NSAttributedString?{
        willSet{
            _attributedText = newValue
        }
        didSet{
            self.refreshFrame()
        }
    }
//    @discardableResult
//    open func attributedText(_ text: NSAttributedString) -> Self{
//        self.attributedText = text
//        return self
//    }
    
    public var moreSize: CGSize = CGSize.zero{
        didSet{
            self.refreshFrame()
        }
    }
    @discardableResult
    open func moreSize(_ size: CGSize) -> Self{
        self.moreSize = size
        return self
    }

    public var calculateMoreSize: CGSize = CGSize.zero{
        didSet{
            self.refreshFrame()
        }
    }
    @discardableResult
    open func calculateMoreSize(_ size: CGSize) -> Self{
        self.calculateMoreSize = size
        return self
    }

    public override var font: UIFont!{
        didSet{
            self.refreshFrame()
        }
    }
    
    
    public func refreshFrame(){
        if changeType.contains(.Nothing){
            return
        }
        var doSize = CGSize(width: self.zz_width, height: CGFloat(MAXFLOAT))
        if willChangedMaxWidth != 0 {
            doSize.width = CGFloat(ceilf(Float(willChangedMaxWidth)))
        }
        if willChangedMaxHeight != 0 {
            doSize.height = CGFloat(ceilf(Float(willChangedMaxHeight)))
        }
        doSize.width += self.calculateMoreSize.width
        doSize.height += self.calculateMoreSize.height
        
        if self.numberOfLines > 0{
            let oneLineHeight = "一个字".zz_textSize(font: self.font, maxSize: CGSize(width: CGFloat.zz_max, height: 0)).height
            let linesHeight = CGFloat(self.numberOfLines) * oneLineHeight
            if willChangedMaxHeight == 0{
                doSize.height = linesHeight
            }else if (linesHeight < willChangedMaxHeight){
                doSize.height = linesHeight
            }
        }
        
        var size = (self.text ?? "").zz_textSize(font: self.font, maxSize: doSize)
        
        if (_attributedText != nil) {
            size = _attributedText!.zz_textSize(font: self.font, maxSize: CGSize(width: doSize.width, height: CGFloat.zz_max), line: self.numberOfLines)
        }
        
        var frame = self.frame
        if changeType.contains(.Width){
            frame.size.width = size.width
        }
        if changeType.contains(.Height){
            frame.size.height = size.height
        }
        
        if size.width == 0 || size.height == 0 {
            frame.size = CGSize.zero
        }else{
            frame.size.width += self.moreSize.width
            frame.size.height += self.moreSize.height
        }
        
        if self.textAutoLayoutChangedBlock != nil {
            self.textAutoLayoutChangedBlock?(self,frame.size)
            return
        }
        self.frame = frame
        self.textChangedBlock?(self)
    }
}
