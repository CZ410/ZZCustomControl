//
//  ZZTabControl.swift
//  Pods
//
//  Created by 陈钟 on 2023/10/7.
//

import Foundation
import ZZBase

public extension ZZTabControl{
    enum ContentAlignment {
        case left, center, right
    }

    enum ScrollIndicatorAlignment {
        case top, center, bottom
    }

}

open class ZZTabControl: UIView{
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }

    open func initUI(){
        self.addSubview(contentView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(origin: .zero, size: zz_size)
        refreshTitlesFrame()
        refreshSelectedIndex(animate: false)
    }


    /// 选中的位置
    open var seletedIndex: Int = 0

    open func setSelectedIndex(_ index: Int, animate: Bool){
        refreshSelectedLastIndex(animate: animate)
        seletedIndex = index
        refreshSelectedIndex(animate: animate)
    }
    
    open var selectedIndexBlock: ((_ index: Int) -> Void)?
    open var clickedIndexBlock: ((_ index: Int) -> Void)?
    
    open private(set) var titleViewsArr = [(view: UIView, normalSize: CGSize, seletedSize: CGSize)]()
    open func titleView(for index: Int) -> (view: UIView, normalSize: CGSize, seletedSize: CGSize)?{
        return titleViewsArr.zz_objAt(index: index)
    }

    /// 选中是指示器固定到ZZTabControl中间位置
    open var isScrollCenter: Bool = true
    
    /// 标题 确保customViews 为空，优先customViews
    open var titles = [String](){
        didSet{
            refreshTitles()
        }
    }
    
    /// 自定义标题 设置之后 titles 失效.
    open var customViews: [UIView] = []{
        didSet{
            refreshCustomTitles()
        }
    }

    open var contentAlignment: ContentAlignment = .center{
        didSet{
            refreshTitlesFrame()
            refreshSelectedIndex(animate: false)
        }
    }

    open var scrollIndicatorAlignment: ScrollIndicatorAlignment = .center{
        didSet{
            refreshTitlesFrame()
            refreshSelectedIndex(animate: false)
        }
    }

    open var normalTitleColor: UIColor = .black{
        didSet{
            refreshTitles()
        }
    }
    
    open var selectedTitleColor: UIColor = .systemBlue{
        didSet{
            refreshTitles()
        }
    }
    
    open var itemBackgroundColor: UIColor = .clear{
        didSet{
            refreshTitles()
        }
    }
    
    open var itemSelectedBackgroundColor: UIColor = .clear{
        didSet{
            refreshTitles()
        }
    }
    

    open var titleFont: UIFont = .systemFont(ofSize: 14, weight: .regular){
        didSet{
            refreshTitles()
        }
    }

    open var selectedScale: CGFloat = 1.5{
        didSet{
            refreshTitles()
            refreshCustomTitles()
        }
    }

    /// 动画时间
    open var animateTime: TimeInterval = 0.25

    open var inset: UIEdgeInsets = .zero{
        didSet{
            refreshTitlesFrame()
            refreshSelectedIndex(animate: false)
        }
    }

    open var itemOffset: CGPoint = .zero {
        didSet{
            refreshTitlesFrame()
            refreshSelectedIndex(animate: false)
        }
    }

    open var itemFixedSize: CGSize = .zero{
        didSet{
            refreshTitlesFrame()
            refreshSelectedIndex(animate: false)
        }
    }

    open var itemMoreSize: CGSize = .zero{
        didSet{
            refreshTitles()
        }
    }

    open var itemSpacing: CGFloat = 10{
        didSet{
            refreshTitlesFrame()
            refreshSelectedIndex(animate: false)
        }
    }

    open var scrollIndicatorFixedWidth: CGFloat = 0{
        didSet{
            refreshSelectedIndex(animate: false)
        }
    }

    open var scrollIndicatorFixedHeight: CGFloat = 0{
        didSet{
            refreshSelectedIndex(animate: false)
        }
    }

    open var scrollIndicatorMoreSize: CGSize = .zero{
        didSet{
            refreshSelectedIndex(animate: false)
        }
    }

    open var scrollIndicatorOffset: CGPoint = .zero{
        didSet{
            refreshSelectedIndex(animate: false)
        }
    }

    open var isBackScrollIndicator: Bool = false{
        didSet{
            refreshSelectedIndex(animate: false)
        }
    }
    
    private func refreshCustomTitles(){
        guard !self.customViews.isEmpty else { return }
        titleViewsArr.forEach({ $0.view.superview != nil ? $0.view.removeFromSuperview() : nil })
        titleViewsArr.removeAll()
        
        customViews.forEach { view in
            view.sizeToFit()
            let textSize = view.frame.size
            let selectedSize = CGSize(width: (textSize.width * selectedScale) , height: textSize.height * selectedScale)
            titleViewsArr.append((view, textSize, selectedSize))
            contentView.addSubview(view)
        }
        refreshTitlesFrame()
        refreshSelectedIndex(animate: false)
    }
    
    private func refreshTitles(){
        guard self.customViews.isEmpty else { return }
        titleViewsArr.forEach({ $0.view.superview != nil ? $0.view.removeFromSuperview() : nil })
        titleViewsArr.removeAll()
        for i in 0 ..< titles.count {
            let title = titles[i]
            let label = UILabel().zz_textAlignment(.center)
            label.text = title
            label.font = titleFont
            label.textColor = normalTitleColor
            label.backgroundColor = itemBackgroundColor

            label.zz_addTap { [weak self] sender in
                guard let `self` = self else { return }
                self.clickedIndexBlock?(i)
                if self.seletedIndex == i { return }
                self.setSelectedIndex(i, animate: true)
                self.selectedIndexBlock?(i)
            }

            let textSize = title.zz_textSize(font: titleFont, maxSize: CGSize(width: .zz_max, height: zz_height))
            let selectedSize = CGSize(width: (textSize.width * selectedScale) , height: textSize.height * selectedScale)
            titleViewsArr.append((label, textSize, selectedSize))
            contentView.addSubview(label)
        }
        refreshTitlesFrame()
        refreshSelectedIndex(animate: false)
    }

    private func refreshTitlesFrame(){
        var x = inset.left
        for i in 0 ..< titleViewsArr.count {
            let item = titleViewsArr[i]
            var size = i == seletedIndex ? item.seletedSize : item.normalSize
            size.height = zz_height - inset.top - inset.bottom
            size = itemFixedSize == .zero ? size : itemFixedSize
            size += itemMoreSize

            x += itemOffset.x
            let y = inset.top + ((zz_height - inset.top - inset.bottom - size.height) * 0.5) + itemOffset.y

            item.view.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            x = (x + size.width + itemSpacing)
        }
        contentView.contentSize = .zz_only(width: x + inset.right - itemSpacing)
        if contentView.contentSize.width < contentView.zz_width{
            switch self.contentAlignment {
                case .left:
                    contentView.contentInset = .zero
                case .center:
                    let inset: CGFloat = (frame.width - contentView.contentSize.width) / 2.0
                    contentView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
                case .right:
                    let inset: CGFloat = (frame.width - contentView.contentSize.width)
                    contentView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
            }
        }else{
            contentView.contentInset = UIEdgeInsets.zero
        }
    }


    /// 恢复之前选中Item的样式
    private func refreshSelectedLastIndex(animate: Bool){
        if titleViewsArr.isEmpty { return }
        let item = titleViewsArr[seletedIndex]
        let selLabel = item.view as? UILabel
        selLabel?.animateTextColor(to: normalTitleColor, animateTime: animateTime)
        if animate{
            UIView.animate(withDuration: animateTime)  {
                item.view.transform = .identity
                item.view.zz_backgroundColor(self.itemBackgroundColor)
            }
        }else {
            item.view.transform = .identity
            item.view.zz_backgroundColor(self.itemBackgroundColor)
        }
    }


    /// 跟新选中Item的样式
    private func refreshSelectedIndex(animate: Bool){
        if titleViewsArr.isEmpty { return }
        let item = titleViewsArr[seletedIndex]
        let selLabel = item.view as? UILabel
        selLabel?.animateTextColor(to: selectedTitleColor, animateTime: animateTime)
//        item.view.transform = .identity

        if isBackScrollIndicator{
            contentView.sendSubviewToBack(scrollIndicator)
        } else {
            contentView.bringSubviewToFront(scrollIndicator)
        }

        func refresh(){
            item.view.zz_backgroundColor(itemSelectedBackgroundColor)
            item.view.transform = CGAffineTransform(scaleX: self.selectedScale, y: self.selectedScale)
            self.refreshTitlesFrame()
            let indicatorWidth = self.scrollIndicatorFixedWidth == 0 ? item.view.zz_size.width : self.scrollIndicatorFixedWidth
            let indicatorHeight = self.scrollIndicatorFixedHeight == 0 ? item.view.zz_size.height : self.scrollIndicatorFixedHeight
            let size = CGSize(width: indicatorWidth, height: indicatorHeight) + self.scrollIndicatorMoreSize
            self.scrollIndicator.zz_size(size)
            switch self.scrollIndicatorAlignment {
                case .top:
                    self.scrollIndicator.zz_center(CGPoint(x: item.view.zz_centerX + scrollIndicatorOffset.x, 
                                                           y: size.height * 0.5 + inset.top + scrollIndicatorOffset.y))
                case .center:
                    self.scrollIndicator.zz_center(CGPoint(x: item.view.zz_centerX + scrollIndicatorOffset.x,
                                                           y: self.zz_height * 0.5 + scrollIndicatorOffset.y))
                case .bottom:
                    self.scrollIndicator.zz_center(CGPoint(x: item.view.zz_centerX + scrollIndicatorOffset.x,
                                                           y: self.zz_height - (size.height * 0.5 + inset.bottom) + scrollIndicatorOffset.y))
            }

            if isScrollCenter{
                if self.contentView.contentInset.left != 0 { return }
                if self.contentView.contentSize.width < self.contentView.frame.width { return }
                let selectedItemFrame = item.view.frame
                let wid = zz_width / 2.0
                let selectItemCenterX = selectedItemFrame.origin.x + selectedItemFrame.width / 2.0
                if selectItemCenterX > wid && selectItemCenterX < self.contentView.contentSize.width - wid {
                    self.contentView.contentOffset = CGPoint(x: selectItemCenterX - wid, y: 0)
                }else if (selectItemCenterX < wid){
                    self.contentView.contentOffset = .zero
                }else if (selectItemCenterX > self.contentView.contentSize.width - wid){
                    self.contentView.contentOffset = CGPoint(x: self.contentView.contentSize.width - self.frame.width, y: 0)
                }
            }
        }
        if animate{
            UIView.animate(withDuration: animateTime) {
                refresh()
            }
        }else {
            refresh()
        }
    }

    open lazy var contentView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()

    open lazy var scrollIndicator: UIImageView = {
        let view = UIImageView()
            .zz_backgroundColor(.systemBlue)
        contentView.addSubview(view)
        return view
    }()
}

extension ZZTabControl: UIScrollViewDelegate{
//    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        ZZLog(scrollView.contentOffset)
//    }
}


fileprivate extension UILabel{
    @discardableResult
    func animateTextColor(to color: UIColor, animateTime: TimeInterval) -> Self {
        UIView.transition(with: self,
                          duration: animateTime,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            guard let `self` = self else { return }
            self.textColor = color
        })
        return self
    }

    @discardableResult
    func animateFont(to font: UIFont, animateTime: TimeInterval) -> Self{
        UIView.transition(with: self,
                          duration: animateTime,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            guard let `self` = self else { return }
            self.font = font
        })
        return self
    }
}
