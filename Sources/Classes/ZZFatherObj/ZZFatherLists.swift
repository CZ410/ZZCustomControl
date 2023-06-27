//
//  FatherTableViewCell.swift
//  KeDaLeDaoHang
//
//  Created by 陈钟 on 2019/5/13.
//  Copyright © 2019 陈钟. All rights reserved.
//

import UIKit

open class FatherTableHeaderFooterView: UITableViewHeaderFooterView{
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.createView()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.createView()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.createView()
    }

    open func createView() { }
}

open class FatherTableViewCell: UITableViewCell {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.createView()
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createView()
    }
    
    open var superTable: UITableView?
    open var indexPath: IndexPath?
    
    open func createView() { }
    
}

open class FatherCollectionViewCell: UICollectionViewCell {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createView()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.createView()
    }
    
    open func createView() { }
}

open class FatherCollectionHeaderFooterView: UICollectionReusableView{
    public override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        createView()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.createView()
    }
    
    open func createView() { }

}
