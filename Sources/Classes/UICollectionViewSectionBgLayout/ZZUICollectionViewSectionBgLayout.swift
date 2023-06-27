//
//  UICollectionViewSectionBgLayout.swift
//  DrivingBible
//
//  Created by Czz on 2023/3/23.
//

import Foundation
import UIKit
import ZZBase

public struct ZZUICollectionViewLayoutSectionBgShadow{
    public var color: UIColor
    public var radius: CGFloat
    public var opacity: Float  = 1
    public var offset: CGSize  = .zero
    public var path: CGPath? = nil
    public var rectCorner: UIRectCorner = []
    
    public init(color: UIColor, radius: CGFloat, opacity: Float = 1, offset: CGSize = .zero, rectCorner: UIRectCorner = .allCorners, path: CGPath? = nil) {
        self.color = color
        self.radius = radius
        self.opacity = opacity
        self.offset = offset
        self.path = path
        self.rectCorner = rectCorner
    }
}

public struct ZZUICollectionViewLayoutSectionBgBorder{
    public var width: CGFloat
    public var color: UIColor
    
    public init(width: CGFloat, color: UIColor) {
        self.width = width
        self.color = color
    }
}

public class ZZUICollectionViewLayoutSectionBgAttributes: UICollectionViewLayoutAttributes{
    var backgroundColor: UIColor?
    var backgroundImage: UIImage?
    var rectCorner: UIRectCorner = []
    var cornerRadii: CGFloat = 0
    
    var border: ZZUICollectionViewLayoutSectionBgBorder?
    var shadow: ZZUICollectionViewLayoutSectionBgShadow?
}

public class ZZUICollectionViewSectionBgView: UICollectionReusableView{
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        bgView.frame = bounds
        guard let att = layoutAttributes as? ZZUICollectionViewLayoutSectionBgAttributes else { return }
        backgroundColor = .clear
        
        if let shadow = att.shadow{
            let bezierPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: shadow.rectCorner, cornerRadii: CGSize(shadow.radius))
            shadowLayer.frame = bgView.bounds
            shadowLayer.shadowColor = shadow.color.cgColor
            shadowLayer.shadowOpacity = shadow.opacity
            shadowLayer.shadowOffset = shadow.offset
            shadowLayer.shadowPath = shadow.path ?? bezierPath.cgPath
            
            shadowLayer.fillColor = UIColor.clear.cgColor
            shadowLayer.strokeColor = UIColor.clear.cgColor

            if shadowLayer.superlayer != bgView.layer{
                shadowLayer.removeFromSuperlayer()
                bgView.layer.insertSublayer(shadowLayer, below: roundLayour)
            }
        }
        
        
        let bezierPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: att.rectCorner, cornerRadii: CGSize(att.cornerRadii))
        roundLayour.frame = bgView.bounds
        
        if let img = att.backgroundImage{
            roundLayour.fillColor = UIColor(patternImage: img).cgColor
        }else{
            roundLayour.fillColor = att.backgroundColor?.cgColor
        }
        
        if let border = att.border{
            roundLayour.lineWidth = border.width
            roundLayour.strokeColor = border.color.cgColor
        }else{
            roundLayour.lineWidth = 0
            roundLayour.strokeColor = nil
        }
        roundLayour.path = bezierPath.cgPath
    }
    
    /// 仅处理阴影(当设置阴影时生效，且在roundLayer之下)
    fileprivate lazy var shadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    /// 处理圆角&背景颜色&边框
    fileprivate lazy var roundLayour: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    public lazy var bgView: UIView = {
        let v = UIView()
        v.layer.addSublayer(roundLayour)
        addSubview(v)
        return v
    }()
}

public protocol ZZUICollectionViewSectionBgLayoutDelegate: UICollectionViewDelegateFlowLayout {
    /// 背景颜色
    func backgroundColor(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> UIColor?
    /// 圆角位置UIRectCorner
    func rectCorner(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> UIRectCorner?
    /// 圆角大小
    func cornerRaddi(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> CGFloat?
    /// 背景图片
    func backgroundImage(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int, bgFrame: CGRect) -> UIImage?
    /// 背景Insets
    func backgroundInsets(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> UIEdgeInsets?
    /// 背景阴影
    func backgroundShadow(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> ZZUICollectionViewLayoutSectionBgShadow?
    /// 边框
    func backgroundBorder(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> ZZUICollectionViewLayoutSectionBgBorder?
}

// 实现可选
public extension ZZUICollectionViewSectionBgLayoutDelegate{
    func backgroundColor(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> UIColor?{
        return nil
    }
    func rectCorner(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> UIRectCorner?{
        return nil
    }
    func cornerRaddi(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> CGFloat?{
        return nil
    }
    
    func backgroundImage(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int, bgFrame: CGRect) -> UIImage?{
        return nil
    }
    
    func backgroundInsets(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> UIEdgeInsets?{
        return nil
    }
    
    func backgroundShadow(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> ZZUICollectionViewLayoutSectionBgShadow?{
        return nil
    }
    
    func backgroundBorder(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> ZZUICollectionViewLayoutSectionBgBorder?{
        return nil
    }
}

/// 实现UICollection Section背景功能（以一个分组为单位）
public class ZZUICollectionViewSectionBgLayout : UICollectionViewFlowLayout{
    public weak var delegate: ZZUICollectionViewSectionBgLayoutDelegate?
    fileprivate var decorationViewAttrs = [UICollectionViewLayoutAttributes]()
    
    private let section_bg_layout_id = "UICollectionViewSectionBgLayout_SectionBackground"
    
    public init(delegate: ZZUICollectionViewSectionBgLayoutDelegate? = nil, decorationViewAttrs: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()) {
        super.init()
        self.delegate = delegate
        self.decorationViewAttrs = decorationViewAttrs
        registerBgLayout()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerBgLayout()
    }
    
    private func registerBgLayout(){
        self.register(ZZUICollectionViewSectionBgView.self, forDecorationViewOfKind: section_bg_layout_id)
    }
    
    public override func prepare() {
        super.prepare()
        
        guard let numberOfSections = collectionView?.numberOfSections,
              numberOfSections > 0,
              let delegate = self.delegate,
              let collectionView = self.collectionView else {
            return
        }
        
        decorationViewAttrs.removeAll()
        
        for section in 0 ..< numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            guard numberOfItems > 0 else{  continue }
            
            
            let firstAtt = layoutAttributesForItem(at: IndexPath(row: 0, section: section))
            let lastAtt = layoutAttributesForItem(at: IndexPath(row: numberOfItems - 1, section: section))
            if firstAtt == nil || lastAtt == nil{
                continue
            }
            
            var sectionInsets = self.sectionInset
            if let delegateInsets = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: section),
               delegateInsets != .zero{
                sectionInsets = delegateInsets
            }
            
            var headerReferenceSize = self.headerReferenceSize
            if let delegateHeaderReferenceSize = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section){
                headerReferenceSize = delegateHeaderReferenceSize
            }
            
            var footerReferenceSize = self.footerReferenceSize
            if let delegateFooterReferenceSize = delegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section){
                footerReferenceSize = delegateFooterReferenceSize
            }
            
            var sectionFrame = CGRectUnion(firstAtt?.frame ?? .zero, lastAtt?.frame ?? .zero)
            sectionFrame.zz_x = sectionInsets.left
            sectionFrame.zz_y -= (sectionInsets.top + headerReferenceSize.height)
            
            if scrollDirection == .horizontal{
                sectionFrame.zz_width = sectionFrame.zz_width + (sectionInsets.left + sectionInsets.right + headerReferenceSize.width + footerReferenceSize.width)
                sectionFrame.zz_height = collectionView.zz_height
            }else{
                sectionFrame.zz_width = collectionView.zz_width - (sectionInsets.left + sectionInsets.right)
                sectionFrame.zz_height = sectionFrame.zz_height + (sectionInsets.top + headerReferenceSize.height + footerReferenceSize.height)
            }
            
            if let bgInset = delegate.backgroundInsets(collectionView: collectionView, layout: self, section: section){
                sectionFrame.zz_x += bgInset.left
                sectionFrame.zz_y += bgInset.top
                sectionFrame.zz_width += -(bgInset.left + bgInset.right)
                sectionFrame.zz_height += -(bgInset.top + bgInset.bottom)
            }
            
            let att = ZZUICollectionViewLayoutSectionBgAttributes(forDecorationViewOfKind: section_bg_layout_id, with: IndexPath(row: 0, section: section))
            att.frame = sectionFrame
            att.zIndex = -1
            
            if let bgColor = delegate.backgroundColor(collectionView: collectionView, layout: self, section: section){
                att.backgroundColor = bgColor
            }
            
            if let bgImage = delegate.backgroundImage(collectionView: collectionView, layout: self, section: section, bgFrame: sectionFrame){
                att.backgroundImage = bgImage
            }
            
            if let rectCorner = delegate.rectCorner(collectionView: collectionView, layout: self, section: section){
                att.rectCorner = rectCorner
            }
            
            if let cornerRadii = delegate.cornerRaddi(collectionView: collectionView, layout: self, section: section){
                att.cornerRadii = cornerRadii
            }
            
            if let shadow = delegate.backgroundShadow(collectionView: collectionView, layout: self, section: section){
                att.shadow = shadow
            }
            
            if let border = delegate.backgroundBorder(collectionView: collectionView, layout: self, section: section){
                att.border = border
            }
            
            decorationViewAttrs.append(att)
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let att = super.layoutAttributesForElements(in: rect) ?? []
        var atts = [UICollectionViewLayoutAttributes]()
        atts.append(contentsOf: att)
        decorationViewAttrs.forEach { layout in
            if rect.intersects(layout.frame){
                atts.append(layout)
            }
        }
        return atts
    }
}
