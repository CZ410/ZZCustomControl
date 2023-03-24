//
//  ZZGrayLayerView.swift
//  DrivingBible
//
//  Created by Czz on 2023/3/23.
//

import Foundation
import UIKit

/// 创建一个灰色滤镜的View（实现哀悼模式可将此View添加到window最上层）
@available(iOS 12.0, *)
class ZZGrayLayerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView(){
        self.zz_backgroundColor(.lightGray)
        self.layer.compositingFilter = "saturationBlendMode"
    }
    
    /// 不处理任何事件
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
