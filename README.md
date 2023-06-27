# ZZCustomControl

[![CI Status](https://img.shields.io/travis/czz_8023/ZZCustomControl.svg?style=flat)](https://travis-ci.org/czz_8023/ZZCustomControl)
[![Version](https://img.shields.io/cocoapods/v/ZZCustomControl.svg?style=flat)](https://cocoapods.org/pods/ZZCustomControl)
[![License](https://img.shields.io/cocoapods/l/ZZCustomControl.svg?style=flat)](https://cocoapods.org/pods/ZZCustomControl)
[![Platform](https://img.shields.io/cocoapods/p/ZZCustomControl.svg?style=flat)](https://cocoapods.org/pods/ZZCustomControl)

![Image text](https://github.com/CZ410/ZZCustomControl/blob/main/Images/data.png)

基于[ZZBase](https://github.com/CZ410/ZZBase)开发的工具库（包含：ZZScrollView、ZZDrawerView、ZZUINavigationCtrl、ZZPageControl、ZZUIButton、UIScrollView+InsetView等 ）

# ZZUICollectionViewSectionBgLayout

实现UICollection Section背景功能（以一个分组为单位）

```
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
```

# UIScrollView+InsetView

在UIScrollView及其子类顶部添加一个Header，可设置顶部跟着手势拖动或固定于顶部。

```
    var zz_topInsetView: UIView?
    
    /// 顶部InsetView的真实高度
    var zz_topInsetViewHeight: CGFloat
    
    var zz_topInsetViewWidth: CGFloat
    
    /// 顶部InsetView 在向⬆️拖拽时固定显示的高度，类似TableView的SectionHeader
    var zz_topInsetViewIgnoreHeight: CGFloat
    
    ///  是否固定InsetView在最顶部，向下拖拽超过inset top依然处于最顶部
    var zz_topInsetViewBindingTop: Bool
```

# ZZScrollView
ZZScrollView继承至UIScrollView，实现可将任意自定义组件串联，并流畅的上下滑动。比如：UIView + UITableView + UIView + WKWebView + UIScrollView + UICollectionView 等 任意组合。实用中如新闻详情页（上部为新闻台头，中部为web页面的新闻类容，底部是评论）都可快速的实现，不用再去计算对应组件的滚动高度。

ZZScrollView.Item
```
        /// 初始化一个ZZScrollView.Item
        /// - Parameters:
        ///   - view: 内容View
        ///   - inset: 内容相对缩进量
        ///   - minHeight: 最低高度
        ///   - fixedWidth: 固定宽度 与inset 冲突  当大于0 时 inset left right 失效
        public init(view: UIView, inset: UIEdgeInsets = .zero, minHeight: CGFloat = 0, fixedWidth: CGFloat = 0, maxHeight: CGFloat = 0) 
        
        /// 创建一条分割线
        /// - Parameters:
        ///   - color: 颜色
        ///   - inset: insets
        ///   - height: 高度
        ///   - fixedWidth: 如果需要固定宽度  传大于0
        public init(line color: UIColor = UIColor.lightGray, inset: UIEdgeInsets = .zero, height: CGFloat = 6, fixedWidth: CGFloat = 0, maxHeight: CGFloat = 0)
        
        private(set) public var minHeight: CGFloat = 0
        private(set) public var maxHeight: CGFloat = 0 // 当view 不为 uiscorollview及其子类时生效
        private(set) public var fixedWidth: CGFloat = 0 // 与inset 冲突  当大于0 时 inset left right 失效
        private(set) public var view: UIView!
        @objc public dynamic var inset: UIEdgeInsets = .zero
        private(set) public dynamic var contentSize: CGSize = .zero
        private(set) public dynamic var isHidden: Bool = false
```

使用方式如下： 
```
    let customItem1 = ZZScrollView.Item(view: customView1, maxHeight: 268)
    let customItem2 = ZZScrollView.Item(view: customView2)
    
    let scrollItem1 = ZZScrollView.Item(view: scrollView1)
    let scrollItem2 = ZZScrollView.Item(view: scrollView2)
    
    let webItem1 = ZZScrollView.Item(view: webView1)
    let webItem2 = ZZScrollView.Item(view: webView3)
    
    let zzScrollView = ZZScrollView(items: [customItem1, scrollItem1, webItem1, webItem2, scrollItem2, customItem2])
```

# ZZUIButton
可设置内容对其方式 和 图片对其方式的按钮

对其方式：
```
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
```

使用方式如下：
```
    let button = ZZUIButton()
    button.backgroundColor(color: .red, state: .normal)
        .backgroundColor(color: .blue, state: .highlighted)
        .backgroundColor(color: .orange, state: .selected)
        .backgroundColor(color: .yellow, state: .disable)
        .title(title: "normal", state: .normal)
        .title(title: "highlighted", state: .highlighted)
        .title(title: "selected", state: .selected)
        .title(title: "disable", state: .disable)
        .image(image: UIImage.name("icon_timeout"), state: .normal)
        .title(title: title, state: .normal)
        .contentAlignment(contentAlignment)// 内容对其
        .imageAlignment(imageAlignment) // image相对内容对其
        .space(20)
        .contentViewBgColor(color: .green, state: .normal)
        .contentInset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
```

# ZZDrawerView
一个抽屉效果的View（包含四种状态： middle：展示中间位置 stretch：展开到最大位置 compress：收缩到最小位置 normal：默认状态关闭 showingHeight = 0）
ZZDrawerView由 topView + UIScrollView + bommtomView组成

```
    /// 顶部视图
    open var topView: UIView?
    
    /// 底部视图
    open var bottomView: UIView?
    
    /// 可拖动视图
    open var scrollView: UIScrollView?
    
    /// 最大展开状态下的高度
    open var maxHeight: CGFloat = zz_screen_height * 0.9
    
    /// 中间位置状态下的高度
    open var middleHeight: CGFloat = zz_screen_height * 0.6
    
    /// 最小展开状态下的高度
    open var minHeight: CGFloat = zz_screen_height * 0.25
    
    /// 顶部高度
    open var topViewHeight: CGFloat = 0
    
    /// 底部高度
    open var bottomViewHeight: CGFloat = 0
    
    /// 当前展示的高度
    public private(set) var showingHeight: CGFloat = 0
    
    /// 是否禁用拖动手势
    open var isDisableTap: Bool = false
    
    open weak var delegate: ZZDrawerViewDelegate?
    
    /// 是否点击背景关闭窗体 默认：true
    open var isCloseByTapBg: Bool = true
    
    open func show(state: ZZDrawerViewState = .middle, animation: Bool = true)
    
    open func dismiss(animation: Bool, block: (()->())? = nil)
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS11及以上版本

## Installation

### CocoaPods

ZZCustomControl is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZZCustomControl'
```


### Swift Package

Add it to the dependencies value of your Package.swift:

```
dependencies: [
    .package(url: "https://github.com/CZ410/ZZCustomControl.git", .upToNextMajor(from: "0.2.0"))
]
```

## Author

CzzBoom, 1039776732@qq.com

## License

ZZCustomControl is available under the MIT license. See the LICENSE file for more info.
