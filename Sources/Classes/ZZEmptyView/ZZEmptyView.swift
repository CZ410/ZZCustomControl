//
//  ZZEmptyView.swift
//  Pods
//
//  Created by 陈钟 on 2025/7/31.
//
import UIKit
import ZZBase

public class ZZEmptyView: UIView {
    public struct StyleConfig {
        var text: String
        var attributedString: NSAttributedString?
        var image: UIImage?
        var textColor: UIColor = .gray

        public init(text: String, attributedString: NSAttributedString? = nil, image: UIImage? = nil, textColor: UIColor = .gray) {
            self.text = text
            self.image = image
            self.textColor = textColor
        }

        public static var loading = StyleConfig(text: "Loading...")
        public static var nothing = StyleConfig(text: "No data available")
        public static var message = StyleConfig(text: "No data available")
        public static var error = StyleConfig(text: "No data available", textColor: .systemRed)

        public func copy(text: String? = nil, attributedString: NSAttributedString? = nil, image: UIImage? = nil, textColor: UIColor? = nil) -> Self {
            let config = StyleConfig(
                text: text ?? self.text,
                attributedString: attributedString ?? self.attributedString,
                image: image ?? self.image,
                textColor: textColor ?? self.textColor
            )
            return config
        }
    }

    public enum Style: Equatable {
        case none
        case loading
        case nothing
        case message
        case error

        var config: StyleConfig? {
            switch self {
            case .none:
                return nil
            case .loading:
                return .loading
            case .nothing:
                return .nothing
            case .message:
                return .message
            case .error:
                return .error
            }
        }
    }

    private(set) var style: Style = .none
    private(set) var config: StyleConfig?

    required init(style: Style, config: StyleConfig? = nil) {
        super.init(frame: .zero)
        reload(style: style, config: config)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        reloadConfig()
    }

    public lazy var titleLab = UILabel()
        .zz_font(.systemFont(ofSize: 14, weight: .semibold))
        .zz_textColor(.gray)
        .zz_textAlignment(.center)

    public lazy var reloadBtn = ZZUIButton().zz_isHidden(true)

    public lazy var imageView = UIImageView().zz_isHidden(true).zz_constrain { view in
        [
            view.widthAnchor.constraint(equalToConstant: 120),
            view.heightAnchor.constraint(equalToConstant: 120),
        ]
    }

    public lazy var loadingView = UIActivityIndicatorView(style: .medium)

    public lazy var contenView = UIStackView.zz_v([loadingView, imageView, titleLab, reloadBtn], alignment: .center, distribution: .equalSpacing, spacing: 15)

    public func reload(style: Style, config: StyleConfig?) {
        self.style = style
        self.config = config
        reloadConfig()
    }

    private func reloadConfig() {
        zz_addSubView(contenView) { superView in
            [
                contenView.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
                contenView.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: 20),
                contenView.rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -20),
            ]
        }
        let config = self.config ?? style.config
        switch style {
        case .loading:
            loadingView.startAnimating()
        default: break
        }
        contenView.isHidden = false
        loadingView.zz_isHidden(style != .loading)
        if let attributedString = config?.attributedString {
            titleLab
                .zz_isHidden(false)
                .zz_textColor(config?.textColor ?? .gray)
                .zz_attributedText(attributedString)
        } else if let text = config?.text{
            titleLab
                .zz_isHidden(false)
                .zz_textColor(config?.textColor ?? .gray)
                .zz_text(text)
        } else {
            titleLab.zz_isHidden(true)
        }
        imageView.image = config?.image
        imageView.isHidden = imageView.image == nil
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let tableView = superview as? UITableView {
            tableView.addObserver(self, forKeyPath: "contentSize", context: nil)
        } else if let collectionView = superview as? UICollectionView {
            collectionView.addObserver(self, forKeyPath: "contentSize", context: nil)
        }
    }

    deinit {
        if self.superview is UITableView || self.superview is UICollectionView {
            self.superview?.removeObserver(self, forKeyPath: "contentSize")
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let itemsCount = superview?.itemsCount ?? 0
        if itemsCount > 0 {
            removeFromSuperview()
        }
    }
}

public extension UIView {
    private var verticalOffset: CGFloat {
        set {
            zz_objc_set(key: "verticalOffset", newValue)
        }
        get {
            return zz_objc_get(key: "verticalOffset", CGFloat.self) ?? 0
        }
    }

    private(set) var emptyView: ZZEmptyView? {
        set {
            zz_objc_set(key: "emptyView", newValue)
        }
        get {
            return zz_objc_get(key: "emptyView", ZZEmptyView.self)
        }
    }

    typealias EmptyBlock = (_ emptyView: ZZEmptyView) -> Void

    @discardableResult
    func zz_emptyStyle(_ style: ZZEmptyView.Style, config: ZZEmptyView.StyleConfig? = nil, verticalOffset: CGFloat = 0, block: EmptyBlock? = nil) -> Self {
        if style == emptyView?.style {
            return self
        }
        self.verticalOffset = verticalOffset
        refreshStyle(style, config: config, block: block)
        return self
    }
    
    @discardableResult
    func zz_emptyButton(title: String? = "Reload Data", styleBlock: ((_ reloadButton: ZZUIButton) -> Void)? = nil, onTap: (() -> Void)? = nil) -> Self {
        guard let emptyView = self.emptyView else {
            return self
        }
        emptyView.reloadBtn.isHidden = false
        styleBlock?(emptyView.reloadBtn)
        let btn = emptyView.reloadBtn
        if let title = title {
            emptyView.reloadBtn.set(title: title, state: .normal)
        }
        btn.zz_removeTap()
        if let onTap = onTap {
            btn.zz_addTap { _ in onTap() }
        }
        return self
    }

    @discardableResult
    private func refreshStyle(_ style: ZZEmptyView.Style, config: ZZEmptyView.StyleConfig? = nil, block: EmptyBlock?) -> Self{
        emptyView?.removeFromSuperview()
        guard style != .none else { return self }
        func setEmptyView() {
            emptyView = ZZEmptyView(style: style, config: config)
            emptyView!.reloadBtn.isHidden = true
            zz_addSubView(emptyView!) { superView in
                [
                    emptyView!.widthAnchor.constraint(equalTo: superView.widthAnchor),
                    emptyView!.heightAnchor.constraint(equalTo: superView.heightAnchor),
                    emptyView!.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
                    emptyView!.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: verticalOffset),
                ]
            }
            block?(emptyView!)
        }

        if itemsCount == 0 {
            setEmptyView()
        } else {
            emptyView?.removeFromSuperview()
        }
        return self
    }

    fileprivate var itemsCount: Int {
        var items = 0

        // UITableView support
        if let tableView = self as? UITableView {
            var sections = 1

            if let dataSource = tableView.dataSource {
                if dataSource.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))) {
                    sections = dataSource.numberOfSections!(in: tableView)
                }
                if dataSource.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) {
                    for i in 0 ..< sections {
                        items += dataSource.tableView(tableView, numberOfRowsInSection: i)
                    }
                }
            }
        } else if let collectionView = self as? UICollectionView {
            var sections = 1

            if let dataSource = collectionView.dataSource {
                if dataSource.responds(to: #selector(UICollectionViewDataSource.numberOfSections(in:))) {
                    sections = dataSource.numberOfSections!(in: collectionView)
                }
                if dataSource.responds(to: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) {
                    for i in 0 ..< sections {
                        items += dataSource.collectionView(collectionView, numberOfItemsInSection: i)
                    }
                }
            }
        }

        return items
    }
}
