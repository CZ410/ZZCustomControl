//
//  UICollectionViewSectionBgLayout.swift
//  DrivingBible
//
//  Created by Czz on 2023/3/23.
//

import Foundation
import UIKit
import ZZBase

public class ZZUICollectionViewLayoutSectionBgAttributes: UICollectionViewLayoutAttributes{
    var backgroundColor: UIColor?
    var backgroundImage: UIImage?
    var rectCorner: UIRectCorner = []
    var cornerRadii: CGFloat = 0
}

public class ZZUICollectionViewSectionBgView: UICollectionReusableView{
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        bgView.frame = bounds
        guard let att = layoutAttributes as? ZZUICollectionViewLayoutSectionBgAttributes else { return }
        backgroundColor = .clear
        bgView.zz_backgroundColor(att.backgroundColor ?? .clear)
        bgView.image = att.backgroundImage
        
        let bezierPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: att.rectCorner, cornerRadii: CGSize(att.cornerRadii))
        roundLayour.frame = bgView.bounds
        roundLayour.path = bezierPath.cgPath
    }
    
    fileprivate lazy var roundLayour: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    lazy var bgView: UIImageView = {
        let v = UIImageView()
        v.layer.mask = self.roundLayour
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
    func backgroundImage(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> UIImage?
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
    func backgroundImage(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> UIImage?{
        return nil
    }
}

/// 实现UICollection Section背景功能（以一个分组为单位）
public class ZZUICollectionViewSectionBgLayout : UICollectionViewFlowLayout{
    weak var delegate: ZZUICollectionViewSectionBgLayoutDelegate?
    fileprivate var decorationViewAttrs = [UICollectionViewLayoutAttributes]()
    
    private let section_bg_layout_id = "UICollectionViewSectionBgLayout_SectionBackground"
    
    init(delegate: ZZUICollectionViewSectionBgLayoutDelegate? = nil, decorationViewAttrs: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()) {
        super.init()
        self.delegate = delegate
        self.decorationViewAttrs = decorationViewAttrs
        registerBgLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerBgLayout()
    }
    
    private func registerBgLayout(){
        self .register(ZZUICollectionViewSectionBgView.self, forDecorationViewOfKind: section_bg_layout_id)
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
            
            var sectionFrame = CGRectUnion(firstAtt?.frame ?? .zero, lastAtt?.frame ?? .zero)
            sectionFrame.zz_x = 0
            sectionFrame.zz_y -= (sectionInsets.top + headerReferenceSize.height)
            
            if scrollDirection == .horizontal{
                sectionFrame.zz_width = sectionFrame.zz_width + (sectionInsets.left + sectionInsets.right + headerReferenceSize.width + footerReferenceSize.width)
                sectionFrame.zz_height = collectionView.zz_height
            }else{
                sectionFrame.zz_width = collectionView.zz_width
                sectionFrame.zz_height = sectionFrame.zz_height + (sectionInsets.top + sectionInsets.bottom + headerReferenceSize.height + footerReferenceSize.height)
            }
            
            let att = ZZUICollectionViewLayoutSectionBgAttributes(forDecorationViewOfKind: section_bg_layout_id, with: IndexPath(row: 0, section: section))
            att.frame = sectionFrame
            att.zIndex = -1
            
            if let bgColor = delegate.backgroundColor(collectionView: collectionView, layout: self, section: section){
                att.backgroundColor = bgColor
            }
            
            if let bgImage = delegate.backgroundImage(collectionView: collectionView, layout: self, section: section){
                att.backgroundImage = bgImage
            }
            
            if let rectCorner = delegate.rectCorner(collectionView: collectionView, layout: self, section: section){
                att.rectCorner = rectCorner
            }
            
            if let cornerRadii = delegate.cornerRaddi(collectionView: collectionView, layout: self, section: section){
                att.cornerRadii = cornerRadii
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
