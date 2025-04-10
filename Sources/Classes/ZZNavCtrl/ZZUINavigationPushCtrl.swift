//
//  ZZUINavigationPushCtrl.swift
//  BuildingWeather
//
//  Created by 陈钟 on 2019/5/9.
//  Copyright © 2019 陈钟. All rights reserved.
//

import UIKit

public class ZZUINavigationPushCtrl: UINavigationController {

    /// PUSH
    public typealias pushViewCtrl = (_ viewCtrl:UIViewController,_ animation:Bool) -> ()
    /// PUSH 回调
    public var pushViewCtrlBlock : pushViewCtrl?
    
    /// PUSH
    public typealias pushClearLastViewCtrl = (_ viewCtrl:UIViewController, _ count: Int, _ animation:Bool) -> ()
    /// PUSH 回调
    public var pushClearLastViewCtrlBlock : pushClearLastViewCtrl?
    
    /// POP
    public typealias popViewCtrl = (_ animation:Bool) -> UIViewController?
    /// POP 回调
    public var popViewCtrlBlock : popViewCtrl?
    
    /// POP到rootviewcontrol
    public typealias popToRootViewCtrl = (_ animation:Bool) -> [UIViewController]?
    /// POP到rootviewcontrol 回调
    public var popToRootViewCtrlBlock : popToRootViewCtrl?
    
    /// POP到指定界面
    public typealias popToViewCtrl = (_ viewCtrl:UIViewController,_ animation:Bool) -> [UIViewController]?
    /// POP到指定界面 回调
    public var popToViewCtrlBlock : popToViewCtrl?
    
    /// POP到指定Class 遍历ViewControllers的第一个
    public typealias popToVcClass = (_ vcClass:AnyClass,_ animation:Bool) -> [UIViewController]?
    /// POP到Class 遍历ViewControllers的第一个 回调
    public var popToVcClasssBlock : popToVcClass?
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.pushViewCtrlBlock != nil {
            self.pushViewCtrlBlock!(viewController,animated)
        }else{
            super .pushViewController(viewController, animated: animated)
        }
    }
    
    override public func popViewController(animated: Bool) -> UIViewController? {
        if self.popViewCtrlBlock != nil {
            return self.popViewCtrlBlock!(animated)
        }else{
           return super.popViewController(animated: animated)
        }
    }
    
    override public func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if self.popToRootViewCtrlBlock != nil {
            return self.popToRootViewCtrlBlock!(animated)
        }else{
            return super.popToRootViewController(animated: animated)
        }
    }
    
    override public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if (self.popToViewCtrlBlock != nil) {
            return self.popToViewCtrlBlock!(viewController,animated)
        }else{
            return super.popToViewController(viewController, animated: animated)
        }
    }
    
    override public func popToClass(vcClass: AnyClass, animated: Bool) -> [UIViewController]? {
        if (self.popToVcClasssBlock != nil) {
            return self.popToVcClasssBlock!(vcClass,animated)
        }else{
            return super.popToClass(vcClass: vcClass, animated: animated)
        }
    }
    
    public override func pushViewController(_ viewController: UIViewController, clearLast count: Int, animated: Bool) {
        if (self.pushClearLastViewCtrlBlock != nil) {
            return self.pushClearLastViewCtrlBlock!(viewController, count, animated)
        }else{
            return super.pushViewController(viewController, clearLast: count, animated: animated)
        }
    }
    
}

public extension UINavigationController{
    @discardableResult @objc
    func popToClass(vcClass:AnyClass, animated: Bool) -> [UIViewController]? {
        var willPushCtrl:UIViewController? = nil
        for viewCtrl in self.viewControllers {
            if viewCtrl.isKind(of: vcClass) {
                willPushCtrl = viewCtrl
                break
            }
        }
        if  willPushCtrl == nil {
            self.popViewController(animated: animated)
            return nil
        }
        return self.popToViewController(willPushCtrl!, animated: animated)
    }
    
    @objc
    func pushViewController(_ viewController: UIViewController, clearLast count: Int, animated: Bool) {
        var count = count
        while self.viewControllers.count > 1 && count > 0 {
            count -= 1
            self.viewControllers.removeLast()
        }
        self.pushViewController(viewController, animated: animated)
    }
    
}
