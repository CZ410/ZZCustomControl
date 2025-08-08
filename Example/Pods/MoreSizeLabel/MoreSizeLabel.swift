//
//  MoreSizeLabel.swift
//  Pods
//
//  Created by 陈钟 on 2025/7/31.
//

import UIKit
import ZZBase

class MoreSizeLabel: UILabel {
    var moreSize: CGSize = .zero
    
    override var intrinsicContentSize: CGSize{
        let size = super.intrinsicContentSize
        return size + moreSize
    }
}
