//
//  ZZPageControl.swift
//  ZZToolKit
//
//  Created by CZZ on 2020/5/28.
//  Copyright © 2020 陈钟. All rights reserved.
//

import UIKit
import ZZBase

/// 和系统UIPageControl类似 相对UIPageControl更方便使用
@IBDesignable open class ZZPageControl: UIView {
    
    @objc public enum PageControlAlignment : NSInteger{
        case Center,Left,Right
    }

    @IBInspectable open var numberOfPages: Int = 0{
        didSet{
            self.createDots()
        }
    }

    @IBInspectable open var currentPage: Int = 0{
        didSet{
            self.refreshDotsFrame()
        }
    }

    @IBInspectable open var pageImage: UIImage?{
        didSet{
            self.refreshDotsFrame()
        }
    }

    @IBInspectable open var currentPageImage: UIImage?{
        didSet{
            self.refreshDotsFrame()
        }
    }
    
    @IBInspectable open var indicatorSize: CGSize = CGSize(width: 6, height: 6){
        didSet{
            self.refreshDotsFrame()
        }
    }
    
    @IBInspectable open var alignment: PageControlAlignment = .Center

    @IBInspectable open var pageIndicatorTintColor: UIColor?

    @IBInspectable open var currentPageIndicatorTintColor: UIColor?

    @IBInspectable open var pageSpace: CGFloat = 6{
        didSet{
            self.refreshDotsFrame()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.refreshDotsFrame()
    }

    private(set) var dots: [UIImageView] = []
    private func createDots(){
        self.dots.forEach({$0.removeFromSuperview()})
        self.dots.removeAll()

        for _ in 0 ..< self.numberOfPages {
            let imageView = UIImageView()
            self.dots.append(imageView)
            self.contentView.addSubview(imageView)
        }
        self.refreshDotsFrame()
    }

    open func refreshDotsFrame(){
        var runPage: Int = self.currentPage
        if self.currentPage >= self.numberOfPages{
            runPage = self.numberOfPages - 1
        }
        if self.currentPage < 0{
            runPage = 0
        }
        var startX: CGFloat = 0
        for index in 0 ..< self.dots.count{
            let imageView = self.dots[index]
            let image = (index == runPage) ? currentPageImage : pageImage
            let color = (index == runPage) ? currentPageIndicatorTintColor: pageIndicatorTintColor
            let size = image?.size ?? indicatorSize
            imageView.zz_cornerRadius(size.height / 2)
            imageView.image = image
            imageView.backgroundColor = color

            imageView.frame = CGRect(origin: CGPoint(x: startX, y: (self.zz_height - size.height) / 2), size: size)
            startX += (size.width + pageSpace)
        }
        var frame = CGRect(x: 0, y: 0, width: startX - pageSpace, height: self.zz_height)
        switch self.alignment {
            case .Left:
                frame.zz_x = pageSpace
                break
            case .Center:
                frame.zz_x = (self.zz_width - frame.zz_width) / 2
                break
            case .Right:
                frame.zz_x = self.zz_width - frame.zz_width - pageSpace
                break
        }
        self.contentView.frame = frame

    }

    lazy public var contentView: UIView = {
        let view = UIView()
        self.addSubview(view)
        return view
    }()

//    @IBInspectable
//    open var currentPageImage: UIImage?
//
//    @IBInspectable
//    open var otherPagesImage: UIImage?
//
//    override
//    open var numberOfPages: Int {
//        didSet {
//            updateDots()
//        }
//    }
//
//    override
//    open var currentPage: Int {
//        didSet {
//            updateDots()
//        }
//    }
//
//    override
//    open func awakeFromNib() {
//        super.awakeFromNib()
////        pageIndicatorTintColor = .clear
////        currentPageIndicatorTintColor = .clear
//        clipsToBounds = false
//    }
//
//    private func updateDots() {
//
//        for (index, subview) in subviews.enumerated() {
//            let imageView: UIImageView
//            if let existingImageview = getImageView(forSubview: subview) {
//                imageView = existingImageview
//            } else {
//                imageView = UIImageView(image: otherPagesImage)
//
////                imageView.center = subview.center
//                subview.addSubview(imageView)
//                subview.clipsToBounds = false
//            }
//            let image = currentPage == index ? currentPageImage : otherPagesImage
//            imageView.size = image?.size ?? subview.size
//            subview.size = imageView.size
//            imageView.image = image
//        }
//    }
//
//    private func getImageView(forSubview view: UIView) -> UIImageView? {
//        if let imageView = view as? UIImageView {
//            return imageView
//        } else {
//            let view = view.subviews.first { (view) -> Bool in
//                return view is UIImageView
//                } as? UIImageView
//
//            return view
//        }
//    }
}
