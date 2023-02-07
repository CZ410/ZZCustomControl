//
//  ZZButton.swift
//  CzzSwTest
//
//  Created by 陈钟 on 2018/9/30.
//  Copyright © 2018年 陈钟. All rights reserved.
//

import UIKit
import ZZBase

@objcMembers @IBDesignable open class ZZUIButton: UIControl {
    public struct ZZState : OptionSet {
        public var rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let normal = ZZState(rawValue: 1 << 0)
        public static let highlighted = ZZState(rawValue: 1 << 1)
        public static let disable = ZZState(rawValue: 1 << 2)
        public static let selected = ZZState(rawValue: 1 << 3)
    }

    public struct Alignment : OptionSet {
        public var rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let Center    = Alignment(rawValue: 1 << 0)
        public static let Left  = Alignment(rawValue: 1 << 1)
        public static let Top   = Alignment(rawValue: 1 << 2)
        public static let Right   = Alignment(rawValue: 1 << 3)
        public static let Bottom   = Alignment(rawValue: 1 << 4)
        
        public static let LeftCenter: Alignment = [.Left, .Center]
        public static let RightCenter: Alignment = [.Right, .Center]
        public static let TopCenter: Alignment = [.Top, .Center]
        public static let BottomCenter: Alignment = [.Bottom, .Center]
        public static let TopLeft: Alignment = [.Top, .Left]
        public static let TopRight: Alignment = [.Top, .Right]
        public static let BottomLeft: Alignment = [.Bottom, .Left]
        public static let BottomRight: Alignment = [.Bottom, .Right]
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        _init()
    }

    public init(normal title:String? = nil ,image:UIImage? = nil, state: ZZState = .normal, contentAlignment: Alignment = .Center, imageAlignment: Alignment = .TopCenter) {
        super.init(frame: CGRect.zero)
        self.contentAlignment = contentAlignment
        self.imageAlignment = imageAlignment
        self.set(image: image, state: state)
        self.set(title: title, state: state)
        _init()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        _init()
    }
    
    private var widthA: NSLayoutConstraint!
    private var heightA: NSLayoutConstraint!

    private func _init(){
        self.backgroundColor = UIColor.clear
        
        self.translatesAutoresizingMaskIntoConstraints = false
        widthA = self.widthAnchor.constraint(equalToConstant: 0)
        heightA = self.heightAnchor.constraint(equalToConstant: 0)
        widthA.isActive = true
        heightA.isActive = true
        widthA.priority = .defaultLow
        heightA.priority = .defaultLow
    }

    open private(set) var defaultBackgroundColor : UIColor = UIColor.clear
    open private(set) var highlightedBackgroundColor : UIColor? = nil
    open private(set) var disableBackgroundColor : UIColor? = nil
    open private(set) var selectedBackgroundColor : UIColor? = nil
    
    open private(set) var defaultContentBgColor : UIColor = UIColor.clear
    open private(set) var highlightedContentBgColor : UIColor? = nil
    open private(set) var disableContentBgColor : UIColor? = nil
    open private(set) var selectedContentBgColor : UIColor? = nil

    // NSAttributedString 和 title 冲突，优先使用NSAttributedString
    @IBInspectable open private(set) var defaultTitle : String? = nil
    open private(set) var highlightedTitle : String? = nil
    open private(set) var disableTitle : String? = nil
    open private(set) var selectedTitle : String? = nil
    
    @IBInspectable open private(set) var defaultTitleColor : UIColor = UIColor.black
    open private(set) var highlightedTitleColor : UIColor? = nil
    open private(set) var disableTitleColor : UIColor? = nil
    open private(set) var selectedTitleColor : UIColor? = nil

    // NSAttributedString 和 title 冲突，优先使用NSAttributedString
    @IBInspectable open private(set) var defaultAttributedString : NSAttributedString? = nil
    open private(set) var highlightedAttributedString : NSAttributedString? = nil
    open private(set) var disableAttributedString : NSAttributedString? = nil
    open private(set) var selectedAttributedString : NSAttributedString? = nil

    open private(set) var defaultBackgroundImage: UIImage? = nil
    open private(set) var highlightedBackgroundImage: UIImage? = nil
    open private(set) var disableBackgroundImage: UIImage? = nil
    open private(set) var selectedBackgroundImage: UIImage? = nil

    open private(set) var defaultContentBackgroundImage: UIImage? = nil
    open private(set) var highlightedContentBackgroundImage: UIImage? = nil
    open private(set) var disableContentBackgroundImage: UIImage? = nil
    open private(set) var selectedContentBackgroundImage: UIImage? = nil

    private var _defaultImage : UIImage? = nil
    @IBInspectable open private(set) var defaultImage : UIImage?{
        set{
            _defaultImage = newValue
        }
        get{
            if self.imageSize.equalTo(CGSize.zero){
                self.imageView.zz_size = _defaultImage?.size ?? CGSize.zero
                self.flushAll()
            }
            return _defaultImage
        }
    }
    private var _highlightedImage : UIImage? = nil
    open private(set) var highlightedImage : UIImage?{
        set{
            _highlightedImage = newValue
        }
        get{
            if self.imageSize.equalTo(CGSize.zero){
                self.imageView.zz_size = _highlightedImage?.size ?? CGSize.zero
                self.flushAll()
            }
            return _highlightedImage
        }
    }

    private var _disableImage : UIImage? = nil
    open private(set) var disableImage : UIImage?{
        set{
            _disableImage = newValue
        }
        get{
            if self.imageSize.equalTo(CGSize.zero){
                self.imageView.zz_size = _disableImage?.size ?? CGSize.zero
                self.flushAll()
            }
            return _disableImage
        }
    }
    
    private var _selectedImage : UIImage? = nil
    open private(set) var selectedImage : UIImage? {
        set{
            _selectedImage = newValue
        }
        get{
            if self.imageSize.equalTo(CGSize.zero){
                self.imageView.zz_size = _selectedImage?.size ?? CGSize.zero
                self.flushAll()
            }
            return _selectedImage
        }
    }
    //MARK: - 配置
    
    /// 图片和title的间隔 默认 4
    @IBInspectable open var space : CGFloat = 4{
        didSet{
            self.flushAll()
        }
    }
    
    @discardableResult
    open func space(_ space: CGFloat) -> Self {
        self.space = space
        return self
    }
    
    /// contentView 多出的大小
    var contentMoreSize: CGSize = CGSize.zero{
        didSet{
            self.flushAll()
        }
    }
    
    @discardableResult
    open func contentMoreSize(_ size: CGSize) -> Self {
        self.contentMoreSize = size
        return self
    }

    ///  contentView 最小大小
    var contentMinSize: CGSize = .zero{
        didSet{
            self.flushAll()
        }
    }

    @discardableResult
    open func contentMinSize(_ size: CGSize) -> Self {
        self.contentMinSize = size
        return self
    }

    ///  contentView 最大框时候 inset
    var contentInset: UIEdgeInsets = .zero{
        didSet{
            self.flushAll()
        }
    }

    @discardableResult
    open func contentInset(_ size: UIEdgeInsets) -> Self {
        self.contentInset = size
        return self
    }


    /// return view 必须为ZZUIButton 内部View 否则按照默认配置
    var paopaoBindView: ((ZZUIButton) -> UIView?)?

    @discardableResult
    open func paopaoBindView(_ block: ((ZZUIButton) -> UIView?)?) -> Self{
        self.paopaoBindView = block
        return self
    }

    @discardableResult
    open func set(contentViewBgColor color:UIColor?,state:ZZState) -> Self {
        if state.contains(.highlighted) {
            self.highlightedContentBgColor = color
        }
        if state.contains(.selected) {
            self.selectedContentBgColor = color
        }
        if state.contains(.disable) {
            self.disableContentBgColor = color
        }
        if state.contains(.normal) {
            self.defaultContentBgColor = color ?? UIColor.clear
        }
        self.flushBtnStyle(isSelected: self.isSelected)
        return self
    }

    @discardableResult
    open func set(contentViewBgImage image: UIImage?,state:ZZState) -> Self {
        if state.contains(.highlighted) {
            self.highlightedContentBackgroundImage = image
        }
        if state.contains(.selected) {
            self.selectedContentBackgroundImage = image
        }
        if state.contains(.disable) {
            self.disableContentBackgroundImage = image
        }
        if state.contains(.normal) {
            self.defaultContentBackgroundImage = image
        }
        self.flushBtnStyle(isSelected: self.isSelected)
        return self
    }
    
    @discardableResult
    open func set(backgroundColor color:UIColor?,state:ZZState) -> Self {
        if state.contains(.highlighted) {
            self.highlightedBackgroundColor = color
        }
        if state.contains(.selected) {
            self.selectedBackgroundColor = color
        }
        if state.contains(.disable) {
            self.disableBackgroundColor = color
        }
        if state.contains(.normal) {
            self.defaultBackgroundColor = color ?? UIColor.clear
        }
        self.flushBtnStyle(isSelected: self.isSelected)
        return self
    }
    
    @discardableResult
    open func set(titleColor color:UIColor?,state:ZZState) -> Self {
        if state.contains(.highlighted) {
            self.highlightedTitleColor = color
        }
        if state.contains(.selected) {
            self.selectedTitleColor = color
        }
        if state.contains(.disable) {
            self.disableTitleColor = color
        }
        if state.contains(.normal) {
            self.defaultTitleColor = color ?? UIColor.black
        }
        self.flushBtnStyle(isSelected: self.isSelected)
        return self
    }
    
    @discardableResult
    open func set(title:String?, state: ZZState) -> Self {
        if state.contains(.highlighted) {
            self.highlightedTitle = title
        }
        if state.contains(.selected) {
            self.selectedTitle = title
        }
        if state.contains(.disable) {
            self.disableTitle = title
        }
        if state.contains(.normal) {
            self.defaultTitle = title
        }
        self.flushBtnStyle(isSelected: self.isSelected)
        return self
    }

    @discardableResult
    open func set(attString: NSAttributedString?, state: ZZState) -> Self{
        if state.contains(.highlighted) {
            self.highlightedAttributedString = attString
        }
        if state.contains(.selected) {
            self.selectedAttributedString = attString
        }
        if state.contains(.disable) {
            self.disableAttributedString = attString
        }
        if state.contains(.normal) {
            self.defaultAttributedString = attString
        }
        self.flushBtnStyle(isSelected: self.isSelected)
        return self
    }

    @discardableResult
    open func set(image:UIImage?, state:ZZState) -> Self {
        if state.contains(.highlighted) {
            self.highlightedImage = image
        }
        if state.contains(.selected) {
            self.selectedImage = image
        }
        if state.contains(.disable) {
            self.disableImage = image
        }
        if state.contains(.normal) {
            self.defaultImage = image
        }
        self.flushBtnStyle(isSelected: self.isSelected)
        return self
    }

    @discardableResult
    open func set(backgroundImage image:UIImage?, state:ZZState) -> Self {
        if state.contains(.highlighted) {
            self.highlightedBackgroundImage = image
        }
        if state.contains(.selected) {
            self.selectedBackgroundImage = image
        }
        if state.contains(.disable) {
            self.disableBackgroundImage = image
        }
        if state.contains(.normal) {
            self.defaultBackgroundImage = image
        }
        self.flushBtnStyle(isSelected: self.isSelected)
        return self
    }
    
    @discardableResult
    open func flushBtnStyle(isSelected:Bool) -> Self {
        self.contentView.alpha = 1
        if !self.isEnabled {
            refreshEnable()
            return self
        }
        if isSelected {
            self.backgroundView.image = self.selectedBackgroundImage ?? self.defaultBackgroundImage
            self.backgroundView.backgroundColor = self.selectedBackgroundColor ?? self.defaultBackgroundColor
            self.contentView.backgroundColor = self.selectedContentBgColor ?? self.defaultContentBgColor
            self.contentView.image = self.selectedContentBackgroundImage ?? self.defaultContentBackgroundImage
            self.imageView.image = self.selectedImage ?? self.defaultImage
            if self.selectedAttributedString != nil || self.defaultAttributedString != nil {
                self.titleLabel.attributedText = self.selectedAttributedString ?? self.defaultAttributedString
            }else{
                self.titleLabel.text = self.selectedTitle ?? self.defaultTitle
                self.titleLabel.textColor = self.selectedTitleColor ?? self.defaultTitleColor
            }
        }else{
            self.backgroundView.image = self.defaultBackgroundImage
            self.backgroundView.backgroundColor = self.defaultBackgroundColor
            self.contentView.backgroundColor = self.defaultContentBgColor
            self.contentView.image = self.defaultContentBackgroundImage
            self.imageView.image = self.defaultImage
            if let attStr = self.defaultAttributedString {
                self.titleLabel.attributedText = attStr
            }else{
                self.titleLabel.text = self.defaultTitle
                self.titleLabel.textColor = self.defaultTitleColor
            }
        }
        return self
    }
    
    override open var isSelected: Bool {
        didSet{
            self.flushBtnStyle(isSelected: self.isSelected)
        }
    }

    open override var isEnabled: Bool{
        didSet{
//            self.refreshEnable()
            self.flushBtnStyle(isSelected: self.isSelected)
        }
    }

    private func refreshEnable(){
        guard !self.isEnabled else {
            return
        }
        self.backgroundView.image = self.disableBackgroundImage ?? (self.isSelected ? self.selectedBackgroundImage ?? self.defaultBackgroundImage : self.defaultBackgroundImage)
        self.backgroundView.backgroundColor = self.disableBackgroundColor ?? (self.isSelected ? self.selectedBackgroundColor ?? self.defaultBackgroundColor : self.defaultBackgroundColor)
        self.contentView.backgroundColor = self.disableContentBgColor ??  (self.isSelected ? self.selectedContentBgColor ?? self.defaultContentBgColor : self.defaultContentBgColor)
        self.contentView.image = self.disableContentBackgroundImage ?? (self.isSelected ? self.selectedContentBackgroundImage ?? self.defaultContentBackgroundImage : self.defaultContentBackgroundImage)
        self.imageView.image = self.disableImage ?? (self.isSelected ? self.selectedImage ?? self.defaultImage : self.defaultImage)
        if (self.isSelected && self.selectedAttributedString != nil) || self.disableAttributedString != nil{
            self.titleLabel.attributedText = self.disableAttributedString ?? self.selectedAttributedString
        }else if (!self.isSelected && self.defaultAttributedString != nil) || self.disableAttributedString != nil{
            self.titleLabel.attributedText = self.disableAttributedString ?? self.defaultAttributedString
        }else{
            self.titleLabel.text = self.disableTitle ?? (self.isSelected ? self.selectedTitle ?? self.defaultTitle : self.defaultTitle)
            self.titleLabel.textColor = self.disableTitleColor ?? (self.isSelected ? self.selectedTitleColor ?? self.defaultTitleColor : self.defaultTitleColor)
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for touch : AnyObject in touches {
            self.beginTracking((touch as! UITouch), with: event)
        }
        if !self.isEnabled {
            return
        }
//        if self.isSelected {
//            return
//        }
        self.backgroundView.image = self.highlightedBackgroundImage ?? (self.isSelected ? (self.selectedBackgroundImage ?? self.defaultBackgroundImage) : self.defaultBackgroundImage)
        self.backgroundView.backgroundColor = self.highlightedBackgroundColor ?? (self.isSelected ? (self.selectedBackgroundColor ?? self.defaultBackgroundColor) : self.defaultBackgroundColor)
        self.contentView.backgroundColor = self.highlightedContentBgColor ?? (self.isSelected ? (self.selectedContentBgColor ?? self.defaultContentBgColor) : self.defaultContentBgColor)
        self.contentView.image = self.highlightedContentBackgroundImage ?? (self.isSelected ? (self.selectedContentBackgroundImage ?? self.defaultContentBackgroundImage) : self.defaultContentBackgroundImage)
        self.imageView.image = self.highlightedImage ?? (self.isSelected ? (self.selectedImage ?? self.defaultImage) : self.defaultImage)
        if self.highlightedAttributedString != nil || self.defaultAttributedString != nil {
            self.titleLabel.attributedText = self.highlightedAttributedString ?? (self.isSelected ? (self.selectedAttributedString ?? self.defaultAttributedString) : self.defaultAttributedString)
        }else{
            self.titleLabel.text = self.highlightedTitle  ?? (self.isSelected ? (self.selectedTitle ?? self.defaultTitle) : self.defaultTitle)
            self.titleLabel.textColor = self.highlightedTitleColor ?? (self.isSelected ? (self.selectedTitleColor ?? self.defaultTitleColor) : self.defaultTitleColor)
        }
//        self.backgroundView.image = (self.highlightedBackgroundImage ?? self.selectedBackgroundImage) ?? self.defaultBackgroundImage
//        self.backgroundView.backgroundColor = (self.highlightedBackgroundColor ?? self.selectedBackgroundColor) ?? self.defaultBackgroundColor
//        self.contentView.backgroundColor = (self.highlightedContentBgColor ?? self.selectedContentBgColor) ?? self.defaultContentBgColor
//        self.contentView.image = (self.highlightedContentBackgroundImage ?? self.selectedContentBackgroundImage) ?? self.defaultContentBackgroundImage
//        self.imageView.image = (self.highlightedImage ?? self.selectedImage) ?? self.defaultImage
//        if self.highlightedAttributedString != nil || self.selectedAttributedString != nil || self.defaultAttributedString != nil {
//            self.titleLabel.attributedText = (self.highlightedAttributedString ?? self.selectedAttributedString) ?? self.defaultAttributedString
//        }else{
//            self.titleLabel.text = (self.highlightedTitle ?? self.selectedTitle) ?? self.defaultTitle
//            self.titleLabel.textColor = UIColor.changeAlpha(color: (self.highlightedTitleColor ?? self.selectedTitleColor) ?? self.defaultTitleColor,
//                                                            alpha: 0.8)
//        }
        self.contentView.alpha = 0.8
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch : AnyObject in touches {
            self.endTracking((touch as! UITouch), with: event)
        }
        if !self.isEnabled {
            return
        }
//        if self.isSelected {
//            return
//        }
        self.flushBtnStyle(isSelected: self.isSelected)
    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        for touch : AnyObject in touches {
            self.continueTracking((touch as! UITouch), with: event)
        }
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.cancelTracking(with: event)
        if !self.isEnabled {
            return
        }
//        if self.isSelected {
//            return
//        }
        self.flushBtnStyle(isSelected: self.isSelected)
    }
    
    /// contentview的偏移量
    open var contentOffset : CGPoint = CGPoint.zero {
        didSet {
            self.flushContentOffSet()
        }
    }
    
    @discardableResult
    open func contentOffset(_ offset: CGPoint) -> Self{
        self.contentOffset = offset
        return self
    }
    
    /// 图片的对其位置
    open var imageAlignment : Alignment = .TopCenter {
        didSet{
            self.flushAll()
        }
    }
    
    @discardableResult
    open func imageAlignment(_ location: Alignment) -> Self{
        self.imageAlignment = location
        return self
    }
    
    /// contentView 的对齐方式
   open var contentAlignment : Alignment = .Center {
        didSet{
            self.flushContentAlignment()
        }
    }

    @discardableResult
    open func contentAlignment(_ alignment: Alignment) -> Self{
        self.contentAlignment = alignment
        return self
    }
    
    /// 图片的大小
    @IBInspectable  open var imageSize : CGSize = CGSize.zero {
        didSet{
            self.imageView.zz_size = self.imageSize
            self.flushBtnStyle(isSelected: self.isSelected)
        }
    }
    
    @discardableResult
    open func imageSize(_ size: CGSize) -> Self{
        self.imageSize = size
        return self
    }
    
    open lazy var backgroundView : UIImageView = {
        let view = UIImageView.init()
        view.isUserInteractionEnabled = false
        self.addSubview(view)
        return view
    }()
    
    ///backgroundView
    @discardableResult
    open func backgroundView(_ block: (_ view: UIImageView) -> Void) -> Self{
        block(self.backgroundView)
        return self
    }

    private var isShowPaopaoLabel: Bool = false
    
    //MARK: - views
    open lazy var paopaoLabel: PaopaoView = {
        let view = PaopaoView.init(bindingView: self.contentView, addView: self)
        view.backgroundColor = UIColor.red
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12)
        view.zz_cornerRadius = 7.5
        view.moreSize = CGSize.init(width: 6, height: 0)
        view.minSize = CGSize.init(width: 15, height: 15)
        self.isShowPaopaoLabel = true
        return view
    }()
    
    /// paopaoLabel
    @discardableResult
    open func paopaoLabel(_ block: (_ view: PaopaoView) -> Void) -> Self{
        block(self.paopaoLabel)
        return self
    }
    
    open lazy var titleLabel : ZZUILabel = {
        let label = ZZUILabel.init()
        label.changeType = .All
        label.isUserInteractionEnabled = false
        label.numberOfLines = 0
        label.willChangedMaxWidth = self.zz_width
        label.textChangedBlock = {[weak self] label in
            self?.flushAll()
        }
        self.contentView.addSubview(label)
        return label
    }()
    
    /// titleLabel
    @discardableResult
    open func titleLabel(_ block: (_ view: ZZUILabel) -> Void) -> Self{
        block(self.titleLabel)
        return self
    }
    
    open lazy var imageView : UIImageView = {
        let view = UIImageView.init()
        view.isUserInteractionEnabled = false
        view.zz_size = self.imageSize
        self.contentView.addSubview(view)
        return view
    }()
    
    /// imageView
    @discardableResult
    open func imageView(_ block: (_ view: UIImageView) -> Void) -> Self{
        block(self.imageView)
        return self
    }
    
    open lazy var contentView : UIImageView = {
        let content = UIImageView.init()
        content.isUserInteractionEnabled = false
        self.addSubview(content)
        return content
    }()
    
    /// contentView
    @discardableResult
    open func contentView(_ block: (_ view: UIImageView) -> Void) -> Self{
        block(self.contentView)
        return self
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView.frame = self.bounds
        self.sendSubviewToBack(self.backgroundView)
        self.titleLabel.willChangedMaxWidth = self.willChangeMaxWidth()
        self.titleLabel.refreshFrame()
        self.flushAll()
    }
    
    open func flushAll() {
        self.flushContentStyle()
        self.flushContentAlignment()
        self.refreshPaopaoView()
    }
    
    /// 计算在不同状态下 文字最大计算宽度
    open func willChangeMaxWidth() -> CGFloat {
        var textMaxWidth: CGFloat = self.zz_width
        if imageAlignment.contains(.Left) || imageAlignment.contains(.Right){
            textMaxWidth = (self.zz_width - self.willChangeSpace() - self.imageView.zz_width - abs(self.contentOffset.x))
        }
        if textMaxWidth < self.contentMinSize.width && self.contentMinSize != .zero{
            textMaxWidth = self.contentMinSize.width
        }
        textMaxWidth -= (self.contentMoreSize.width)

        if (textMaxWidth + self.contentInset.left + self.contentInset.right) >= self.zz_width {
            textMaxWidth -= (self.contentInset.left + self.contentInset.right)
        }
        return textMaxWidth
    }
    
    /// 计算不同状态下 图片和文字的间隔
    open func willChangeSpace() -> CGFloat {
        if self.imageView.zz_size == CGSize.zero || self.titleLabel.zz_size == CGSize.zero {
            return 0
        }
        return self.space
    }
    
    /// 刷新imageview 和 title 的布局
    open func flushContentStyle() -> Void {
        self.imageView.zz_origin = .zero
        self.titleLabel.zz_origin = .zero
        
        var maxWidth = max(self.imageView.zz_width, self.titleLabel.zz_width)
        var maxHeight = max(self.imageView.zz_height, self.titleLabel.zz_height)
        
        let willChangeSpace = self.willChangeSpace()
        
        if imageAlignment.contains(.Left) || imageAlignment.contains(.Right){
            maxWidth = self.imageView.zz_width + self.titleLabel.zz_width + willChangeSpace
        }
        if imageAlignment.contains(.Bottom) || imageAlignment.contains(.Top) {
            maxHeight = self.imageView.zz_height + self.titleLabel.zz_height + willChangeSpace
        }
        
        maxWidth += self.contentMoreSize.width
        maxHeight += self.contentMoreSize.height

        if self.contentMinSize != .zero{
            if maxWidth < self.contentMinSize.width{
                maxWidth = self.contentMinSize.width
            }

            if maxHeight < self.contentMinSize.height{
                maxHeight = self.contentMinSize.height
            }
        }

        if (maxWidth + self.contentInset.left + self.contentInset.right) >= self.zz_width {
            maxWidth -= (self.contentInset.left + self.contentInset.right)
        }

        if (maxHeight + self.contentInset.top + self.contentInset.bottom) >= self.zz_height{
            maxHeight -= (self.contentInset.top + self.contentInset.bottom)
        }
        
        if imageAlignment.contains(.Center){
            self.imageView.center = CGPoint.init(x: maxWidth / 2.0, y: maxHeight / 2.0)
            self.titleLabel.center = CGPoint.init(x: maxWidth / 2.0, y: maxHeight / 2.0)
        }
        
        if imageAlignment.contains(.Top) {
            self.imageView.zz_y = self.contentMoreSize.height / 2.0
            self.titleLabel.zz_y = self.imageView.zz_maxY + willChangeSpace
        }
        if imageAlignment.contains(.Bottom) {
            self.titleLabel.zz_y = self.contentMoreSize.height / 2.0
            self.imageView.zz_y = self.titleLabel.zz_maxY + willChangeSpace
        }
        if imageAlignment.contains(.Left){
            if imageAlignment.contains(.Bottom) || imageAlignment.contains(.Top) {
                maxWidth = max(self.imageView.zz_width, self.titleLabel.zz_width)
                if self.contentMinSize != .zero{
                    if maxWidth < self.contentMinSize.width{
                        maxWidth = self.contentMinSize.width
                    }
                }
                if (maxWidth + self.contentInset.zz_left + self.contentInset.zz_right) >= self.zz_width {
                    maxWidth -= (self.contentInset.left + self.contentInset.right)
                }

                self.imageView.zz_x = self.contentMoreSize.width / 2.0
                self.titleLabel.zz_x = self.contentMoreSize.width / 2.0
            }else{
                self.imageView.zz_x = self.contentMoreSize.width / 2.0
                self.titleLabel.zz_x = self.imageView.zz_maxX + willChangeSpace
            }
        }
        if imageAlignment.contains(.Right) {
            if imageAlignment.contains(.Bottom) || imageAlignment.contains(.Top) {
                maxWidth = max(self.imageView.zz_width, self.titleLabel.zz_width)
                if self.contentMinSize != .zero{
                    if maxWidth < self.contentMinSize.width{
                        maxWidth = self.contentMinSize.width
                    }
                }
                if (maxWidth + self.contentInset.left + self.contentInset.right) >= self.zz_width {
                    maxWidth -= (self.contentInset.left + self.contentInset.right)
                }

                self.imageView.zz_x = maxWidth - self.imageView.zz_width
                self.titleLabel.zz_x = maxWidth - self.titleLabel.zz_width
            }else{
                self.imageView.zz_x = maxWidth - self.imageView.zz_width - self.contentMoreSize.width / 2.0
                self.titleLabel.zz_x = self.imageView.zz_x - self.titleLabel.zz_width - willChangeSpace
            }
        }
        self.contentView.zz_size = CGSize.init(width: maxWidth, height: maxHeight)
        
        widthA.constant = maxWidth
        heightA.constant = maxHeight
    }
    
    /// 刷新content对其方式
    open func flushContentAlignment() -> Void {
        if contentAlignment.contains(.Center) {
            self.contentView.zz_center = CGPoint.init(x: self.zz_width / 2.0, y: self.zz_height / 2.0)
        }
        if contentAlignment.contains(.Left) {
            self.contentView.zz_x = self.contentInset.left
        }
        if contentAlignment.contains(.Top) {
            self.contentView.zz_y = self.contentInset.top
        }
        if contentAlignment.contains(.Right) {
            self.contentView.zz_x = self.zz_width - self.contentView.zz_width - self.contentInset.zz_right
        }
        if contentAlignment.contains(.Bottom) {
            self.contentView.zz_y = self.zz_height - self.contentView.zz_height - self.contentInset.zz_bottom
        }
        self.flushContentOffSet()
    }
    
    open func flushContentOffSet() -> Void {
        if self.contentOffset == CGPoint.zero {
            return
        }
        self.contentView.zz_x  = self.contentView.zz_x + self.contentOffset.zz_x
        self.contentView.zz_y  = self.contentView.zz_y + self.contentOffset.zz_y
    }

    open func refreshPaopaoView() -> Void {
        guard isShowPaopaoLabel else { return }
        if let view = self.paopaoBindView?(self){
            if self.zz_isHave(view: view){
                self.paopaoLabel.bindingView = view
                self.paopaoLabel.refreshFrame()
                return
            }
        }
        if imageAlignment.contains(.Top){
            self.paopaoLabel.bindingView = self.imageView
        }else if(imageAlignment.contains(.Bottom)){
            self.paopaoLabel.bindingView = self.titleLabel
        }else{
            self.paopaoLabel.bindingView = self.contentView
        }
        self.paopaoLabel.refreshFrame()
    }
}
