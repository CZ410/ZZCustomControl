//
//  ZZDrawerView.swift
//  ZZBaseCustoms
//
//  Created by Czz on 2023/2/1.
//

import UIKit
import ZZBase

/// middle：展示中间位置
/// stretch：展开到最大位置
/// compress：收缩到最小位置
/// normal：默认状态关闭 showingHeight = 0
public enum ZZDrawerViewState {
    /// 默认状态关闭 showingHeight = 0
    case normal
    /// 展开到最大位置
    case stretch
    /// 收缩到最小位置
    case compress
    /// 展示中间位置
    case middle
}

public protocol ZZDrawerViewDelegate: NSObjectProtocol {
    func heightChanged(drawerView: ZZDrawerView, height: CGFloat)
    func stateChanged(drawerView: ZZDrawerView, state: ZZDrawerViewState)
    func stateWillChange(drawerView: ZZDrawerView, state: ZZDrawerViewState)
}

public extension ZZDrawerViewDelegate {
    func heightChanged(drawerView: ZZDrawerView, height: CGFloat) {}
    func stateChanged(drawerView: ZZDrawerView, state: ZZDrawerViewState) {}
    func stateWillChange(drawerView: ZZDrawerView, state: ZZDrawerViewState) {}
}

open class ZZDrawerView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }

    private weak var _superView: UIView?
    /// 父视图 设置时候调用设置的视图。 没设置自动获取superview
    open weak var superView: UIView? {
        set {
            _superView = newValue
            _init()
        }
        get {
            guard let v = _superView else {
                return superview
            }
            return v
        }
    }

    @discardableResult open func superView(_ v: UIView?) -> Self {
        superView = v
        return self
    }

    /// 顶部视图
    open var topView: UIView? {
        willSet {
            topView?.removeFromSuperview()
        }
        didSet {
            _init()
        }
    }

    @discardableResult open func topView(_ v: UIView?) -> Self {
        topView = v
        return self
    }

    /// 底部视图
    open var bottomView: UIView? {
        willSet {
            bottomView?.removeFromSuperview()
        }
        didSet {
            _init()
        }
    }

    @discardableResult open func bottomView(_ v: UIView?) -> Self {
        bottomView = v
        return self
    }

    /// 可拖动视图
    open var scrollView: UIScrollView? {
        willSet {
            scrollView?.zz_remoAllObservers()
            scrollView?.removeFromSuperview()
        }
        didSet {
            scrollView?.addObserver(self, forKeyPath: "contentOffset", context: nil)
            scrollView?.addGestureRecognizer(contentViewTableTap)
            _init()
        }
    }

    @discardableResult open func scrollView(_ v: UIView?) -> Self {
        bottomView = v
        return self
    }

    /// 最大展开状态下的高度
    open var maxHeight: CGFloat = zz_screen_height * 0.9 {
        didSet {
            if state == .stretch {
                showingHeight = maxHeight
                refreshContentFrame(to: showingHeight)
            }
        }
    }

    @discardableResult open func maxHeight(_ v: CGFloat) -> Self {
        maxHeight = v
        return self
    }

    /// 中间位置状态下的高度
    open var middleHeight: CGFloat = zz_screen_height * 0.6 {
        didSet {
            if state == .middle {
                showingHeight = middleHeight
                refreshContentFrame(to: showingHeight)
            }
        }
    }

    @discardableResult open func middleHeight(_ v: CGFloat) -> Self {
        middleHeight = v
        return self
    }

    /// 最小展开状态下的高度
    open var minHeight: CGFloat = zz_screen_height * 0.25 {
        didSet {
            if state == .compress {
                showingHeight = minHeight
                refreshContentFrame(to: showingHeight)
            }
        }
    }

    @discardableResult open func minHeight(_ v: CGFloat) -> Self {
        minHeight = v
        return self
    }

    /// 顶部高度
    open var topViewHeight: CGFloat = 0 {
        didSet {
            var animationToHeigh: CGFloat = 0
            if state == .stretch {
                animationToHeigh = maxHeight
            } else if state == .compress {
                animationToHeigh = minHeight
            } else if state == .middle {
                animationToHeigh = middleHeight
            }
            refreshContentFrame(to: animationToHeigh)
        }
    }

    @discardableResult open func topViewHeight(_ v: CGFloat) -> Self {
        topViewHeight = v
        return self
    }

    /// 底部高度
    open var bottomViewHeight: CGFloat = 0

    @discardableResult open func bottomViewHeight(_ v: CGFloat) -> Self {
        bottomViewHeight = v
        return self
    }

    /// 当前展示的高度
    public private(set) var showingHeight: CGFloat = 0
    /// 是否禁用拖动手势
    open var isDisableTap: Bool = false

    @discardableResult open func isDisableTap(_ v: Bool) -> Self {
        isDisableTap = v
        return self
    }

    open weak var delegate: ZZDrawerViewDelegate?

    @discardableResult open func delegate(_ v: ZZDrawerViewDelegate?) -> Self {
        delegate = v
        return self
    }

    /// 是否点击背景关闭窗体 默认：true
    open var isCloseByTapBg: Bool = true

    @discardableResult open func isCloseByTapBg(_ v: Bool) -> Self {
        isCloseByTapBg = v
        return self
    }

    public var state: ZZDrawerViewState {
        if showingHeight == minHeight {
            return .compress
        }
        if showingHeight == maxHeight {
            return .stretch
        }
        if showingHeight == middleHeight {
            return .middle
        }
        return .normal
    }

    override open var isHidden: Bool {
        didSet {
            bgView.isHidden = isHidden
        }
    }

    private var dismissBlock: (() -> Void)?
    private var isDismiss: Bool = false

    deinit {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }

    private func _init() {
        zz_backgroundColor(.white)
        guard let superView = superView else { return }

        layer.masksToBounds = true
        bgView.frame = superView.bounds
//        superView.addSubview(bgView)

//        superView.addSubview(self)

        if let topView = topView {
            addSubview(topView)
        }

        if let bottomView = bottomView {
            addSubview(bottomView)
        }

        addGestureRecognizer(contentViewTap)

        if let scrollView = scrollView {
            addSubview(scrollView)
            scrollView.contentOffset = .zero
        }
        refreshContentFrame(to: showingHeight)
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = superview { // 被addSubview到了其他View上了
            _superView = nil
            _init()
        }
    }

    override open func removeFromSuperview() {
        super.removeFromSuperview()
        bgView.removeFromSuperview()
    }

    open func show(state: ZZDrawerViewState = .middle, animation: Bool = true) {
        superView?.addSubview(bgView)
        superView?.addSubview(self)

        set(state: state, animation: animation)
    }

    open func dismiss(animation: Bool, block: (() -> Void)? = nil) {
        dismissBlock = block
        isDismiss = true
        refreshContentFrameToHeight(0, animation: true)
    }

    /// 设置折叠状态
    /// - Parameters:
    ///   - state: 状态
    ///   - animation: 是否动画 默认false
    @discardableResult open func set(state: ZZDrawerViewState, animation: Bool = false) -> Self {
        var animationToHeight: CGFloat = 0
        if state == .stretch {
            animationToHeight = maxHeight
        } else if state == .compress {
            animationToHeight = minHeight
        } else if state == .middle {
            animationToHeight = middleHeight
        } else {
            return self
        }
        refreshContentFrameToHeight(animationToHeight, animation: animation)
        return self
    }

    @discardableResult open func set(height: CGFloat, to state: ZZDrawerViewState, animation: Bool) -> Self {
        switch state {
        case .stretch:
            maxHeight = height
        case .compress:
            minHeight = height
        case .middle:
            middleHeight = height
        default: return self
        }
        return set(state: state, animation: animation)
    }

    @discardableResult open func set(height: CGFloat, for state: ZZDrawerViewState, animation: Bool) -> Self {
        let isChangeHeight = state == self.state
        switch state {
        case .stretch:
            maxHeight = height
        case .compress:
            minHeight = height
        case .middle:
            middleHeight = height
        default: return self
        }
        if isChangeHeight {
            return set(state: state, animation: animation)
        }
        return self
    }

    private func refreshContentFrameToHeight(_ height: CGFloat, animation: Bool = false) {
        guard let superView = superView else { return }

        if bgView.superview != nil {
            superView.insertSubview(bgView, belowSubview: self)
        }
//        if bgView.superview == nil{
//            superView.insertSubview(bgView, belowSubview: self)
//        }

//        if self.superview == nil {
//            superView.addSubview(self)
//        }

        showingHeight = height
        if animation {
            callStateWillChangeDelegate()
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
                guard let `self` = self else { return }
                var selfFrame = self.frame
                selfFrame.zz_y(superView.zz_height - self.showingHeight)
                selfFrame.zz_height(self.showingHeight)
                self.frame = selfFrame
                var scrollViewHeight = self.showingHeight - self.topViewHeight - self.bottomViewHeight
                if scrollViewHeight < 0 { scrollViewHeight = 0 }
                self.scrollView?.frame = CGRect(x: 0, y: self.topViewHeight, width: self.frame.zz_width, height: scrollViewHeight)

                if self.showingHeight <= self.middleHeight {
                    self.bgView.zz_backgroundColor(.clear)
                } else {
                    self.bgView.zz_backgroundColor(.init(white: 0, alpha: 0.5))
                }

                if let t = self.topView {
                    t.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.topViewHeight)
                }
                if let b = self.bottomView {
                    var footerViewY = self.showingHeight - self.bottomViewHeight
                    if footerViewY < 0 { footerViewY = 0 }
                    b.frame = CGRect(x: 0, y: footerViewY, width: self.frame.size.width, height: self.bottomViewHeight)
                }
            } completion: { [weak self] finished in
                guard let `self` = self else { return }
                guard finished else { return }
                self.zz_height(self.showingHeight)
                self.callStateChangedDelegate()
            }
        } else {
            callStateWillChangeDelegate()
            frame = CGRect(x: 0, y: superView.frame.size.height - showingHeight, width: superView.frame.size.width, height: showingHeight)
            if let t = topView {
                t.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: topViewHeight)
            }
            if let b = bottomView {
                var footerViewY = showingHeight - bottomViewHeight
                if footerViewY < 0 { footerViewY = 0 }
                b.frame = CGRect(x: 0, y: footerViewY, width: frame.size.width, height: bottomViewHeight)
            }
            var scrollViewHeight = showingHeight - topViewHeight
            if scrollViewHeight < 0 { scrollViewHeight = 0 }
            scrollView?.frame = CGRect(x: 0, y: topViewHeight, width: frame.size.width, height: scrollViewHeight)
            if showingHeight <= middleHeight {
                bgView.zz_backgroundColor(.clear)
            } else {
                bgView.zz_backgroundColor(.init(white: 0, alpha: 0.5))
            }
            callStateChangedDelegate()
        }
    }

    private func refreshContentFrame(to height: CGFloat) {
        guard let superView = superView else { return }
        frame = CGRectMake(0, superView.zz_height - height, superView.zz_width, height)
        if let t = topView {
            t.frame = CGRectMake(0, 0, frame.size.width, topViewHeight)
        }
        if let b = bottomView {
            var footerViewY = zz_height - bottomViewHeight
            if footerViewY < 0 { footerViewY = 0 }
            b.frame = CGRectMake(0, footerViewY, zz_width, bottomViewHeight)
        }
        var scrollViewHeight = frame.size.height - topViewHeight - bottomViewHeight
        if scrollViewHeight < 0 { scrollViewHeight = 0 }
        scrollView?.frame = CGRectMake(0, topViewHeight, frame.size.width, scrollViewHeight)

        contentViewTap.isEnabled = height <= maxHeight
        contentViewTableTap.isEnabled = height <= maxHeight

        var alpha = (height - middleHeight) / (maxHeight - middleHeight)
        if alpha < 0 { alpha = 0 }
        if alpha > 1 { alpha = 1 }
        bgView.zz_backgroundColor(.init(white: 0, alpha: alpha * 0.5))

        if let sc = scrollView, height < maxHeight {
            sc.contentOffset = CGPointMake(0, -sc.contentInset.top)
        }
    }

    private func callStateChangedDelegate() {
        if isDismiss {
            isDismiss = false
            dismissBlock?()
            delegate?.stateChanged(drawerView: self, state: .normal)
            removeFromSuperview()
            return
        }
        switch showingHeight {
        case minHeight:
            delegate?.stateChanged(drawerView: self, state: .compress)
        case maxHeight:
            delegate?.stateChanged(drawerView: self, state: .stretch)
        case middleHeight:
            delegate?.stateChanged(drawerView: self, state: .middle)
        default: break
        }
    }

    private func callStateWillChangeDelegate() {
        if isDismiss {
            delegate?.stateWillChange(drawerView: self, state: .normal)
            return
        }
        switch showingHeight {
        case minHeight:
            delegate?.stateWillChange(drawerView: self, state: .compress)
        case maxHeight:
            delegate?.stateWillChange(drawerView: self, state: .stretch)
        case middleHeight:
            delegate?.stateWillChange(drawerView: self, state: .middle)
        default: break
        }
    }

    @objc private func tapAction(tap: UIPanGestureRecognizer) {
        guard !isDisableTap else { return } // 禁用了手势
        let point = tap.translation(in: self)
        switch tap.state {
        case .began: break
        case .changed:
            var height = showingHeight - point.y
            if height > maxHeight {
                height = maxHeight
            }
            if height < minHeight {
                height = minHeight
            }
            refreshContentFrame(to: height)
            delegate?.heightChanged(drawerView: self, height: height)
        case .ended:
            let speed = tap.velocity(in: tap.view)
            // 如果拖动咱开高度在默认展开高度
            let toMaxHeight = middleHeight + ((maxHeight - middleHeight) / 2.0)
            let toMinHeight = minHeight + ((middleHeight - minHeight) / 2.0)
            let height = frame.size.height
            if abs(speed.y) > 1000 { // speed.y 小于0向上 否则向下
                if speed.y > 0 {
                    switch state {
                    case .stretch:
                        if height < middleHeight {
                            refreshContentFrameToHeight(minHeight, animation: true)
                        } else {
                            refreshContentFrameToHeight(middleHeight, animation: true)
                        }
                        return;
                    case .middle:
                        refreshContentFrameToHeight(minHeight, animation: true)
                        return;
                    default: break
                    }
                } else {
                    switch state {
                    case .compress:
                        if height > middleHeight {
                            refreshContentFrameToHeight(maxHeight, animation: true)
                        } else {
                            refreshContentFrameToHeight(middleHeight, animation: true)
                        }
                        return
                    case .middle:
                        refreshContentFrameToHeight(maxHeight, animation: true)
                        return
                    default: break
                    }
                }
            }

            var animationToHeight: CGFloat = 0
            if height > toMaxHeight {
                animationToHeight = maxHeight
            } else if height < toMinHeight {
                animationToHeight = minHeight
            } else {
                animationToHeight = middleHeight
            }
            showingHeight = animationToHeight
            refreshContentFrameToHeight(showingHeight, animation: true)

        default: break
        }
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        contentViewTap.isEnabled = true
        contentViewTableTap.isEnabled = true
        if let sc = scrollView, zz_height >= maxHeight {
            contentViewTap.isEnabled = ((sc.contentOffset.y + sc.contentInset.top) == 0)
            contentViewTableTap.isEnabled = ((sc.contentOffset.y + sc.contentInset.top) == 0)
        }
    }

    /// 背景窗体
    open lazy var bgView: UIView = {
        let view = UIView()
        view
            .zz_backgroundColor(.clear)
            .zz_isUserInteractionEnabled(true)
            .zz_addTap { [weak self] _ in
                guard let `self` = self else { return }
                guard self.isCloseByTapBg else { return }
                self.dismiss(animation: true)
            }
        return view
    }()

    private lazy var contentViewTap: UIPanGestureRecognizer = {
        let tap = UIPanGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        tap.delegate = self
        return tap
    }()

    private lazy var contentViewTableTap: UIPanGestureRecognizer = {
        let tap = UIPanGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        tap.delegate = self
        return tap
    }()
}

extension ZZDrawerView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard !isDisableTap else { return false }
        let tapView = gestureRecognizer.view
        if let scrollView = scrollView, tapView == scrollView {
            let vel = scrollView.panGestureRecognizer.velocity(in: self)
            if vel.y > 0 {
                if scrollView.contentOffset.y + scrollView.contentInset.top > 0 {
                    return true
                }
            } else {
                if showingHeight == maxHeight {
                    return true
                }
                if scrollView.contentOffset.y + scrollView.contentInset.top > 0 {
                    return true
                }
            }
        }
        return false
    }
}

public extension ZZDrawerView {
    @discardableResult
    func makeTopView(height: CGFloat? = nil, _ viewBlock: ((_ view: UIView) -> Void)?) -> Self {
        let view = UIView()
        topView = view
        if let h = height {
            topViewHeight = h
        }
        viewBlock?(view)
        return self
    }

    @discardableResult
    func makeBottompView(height: CGFloat? = nil, _ viewBlock: ((_ view: UIView) -> Void)?) -> Self {
        let view = UIView()
        bottomView = view
        if let h = height {
            bottomViewHeight = h
        }
        viewBlock?(view)
        return self
    }

    @discardableResult
    func makeTable<C: UITableViewCell, H: UITableViewHeaderFooterView>(
        style: UITableView.Style = .plain,
        delegate: UITableViewProtocol,
        dataSource: UITableViewProtocol? = nil,
        registerCells: [C.Type]? = nil,
        registerHeaders: [H.Type]? = nil,
        registerFooters: [H.Type]? = nil,
        viewBlock: ((_ view: UITableView) -> Void)? = nil) -> Self {
        let table = UITableView.zz_make(
            style: style,
            delegate: delegate,
            dataSource: dataSource,
            registerCells: registerCells,
            registerHeaders: registerHeaders,
            registerFooters: registerFooters
        )
        scrollView = table
        viewBlock?(table)
        return self
    }

    @discardableResult
    func makeCollection<C: UICollectionViewCell, H: UICollectionReusableView>(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource,
        layout: UICollectionViewLayout,
        registerCells: [C.Type]? = nil,
        registerHeaders: [H.Type]? = nil,
        registerFooters: [H.Type]? = nil,
        viewBlock: ((_ view: UICollectionView) -> Void)? = nil) -> Self {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = delegate
        collection.dataSource = dataSource
        registerCells?.forEach({ collection.zz_register(cell: $0) })
        registerHeaders?.forEach({ collection.zz_register(header: $0) })
        registerHeaders?.forEach({ collection.zz_register(footer: $0) })
        scrollView = collection
        viewBlock?(collection)
        return self
    }
}
