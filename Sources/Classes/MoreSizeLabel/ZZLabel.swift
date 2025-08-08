
import Foundation
import ZZBase

open class ZZLabel: UILabel{
    open var moreSize: CGSize = .zero{
        didSet{
            invalidateIntrinsicContentSize()
        }
    }
    
    @discardableResult
    func moreSize(_ size: CGSize) -> Self{
        self.moreSize = size
        return self
    }
    
    open override var intrinsicContentSize: CGSize{
        let size = super.intrinsicContentSize
        return size + moreSize
    }
}
