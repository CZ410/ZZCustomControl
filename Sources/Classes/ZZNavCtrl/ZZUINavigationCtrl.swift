//
//  ZZUINavigationCtrl.swift
//  BuildingWeather
//
//  Created by 陈钟 on 2019/5/9.
//  Copyright © 2019 陈钟. All rights reserved.
//

import UIKit
import ZZBase

public class ZZUINavigationCtrl: UINavigationController {

    private var currentShowVc : UIViewController? = nil
    
    static public var backImage: UIImage? = nil
    
    @objc private func backAction(){
        self.popViewController(animated: true)
    }
    
    fileprivate var backButton: ZZUIButton {
        let button = ZZUIButton()
        button.set(image: ZZUINavigationCtrl.backImage, state: .normal)
            .contentAlignment(.LeftCenter)
            .imageAlignment(.LeftCenter)
            .contentOffset(CGPoint(x: 15, y: 0))
            .zz_size(CGSize(width: 50, height: 44))
            .zz_addTarget(self, action: #selector(backAction), for: .touchUpInside)
            .translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([button.widthAnchor.constraint(equalToConstant: 50), button.heightAnchor.constraint(equalToConstant: 44)])
        return button
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if (self.responds(to: #selector(getter: interactivePopGestureRecognizer))) {
            self.interactivePopGestureRecognizer?.delegate = self
            self.delegate = self
        }
        self.setNavigationBarHidden(true, animated: false)
    }
    
    public func setPushViewCtrBlock(pushNavCtrl:ZZUINavigationPushCtrl) -> Void {
        pushNavCtrl.pushViewCtrlBlock = {[weak self] viewCtrl,animat in
            self?.pushViewController(viewCtrl, animated: animat)
        }
        pushNavCtrl.popViewCtrlBlock = {[weak self] animat in
            return (self?.popViewController(animated: animat))
        }
        pushNavCtrl.popToRootViewCtrlBlock = {[weak self] animat in
            if #available(iOS 14, *) {
                if animat{
                    let popController = self?.viewControllers.last
                    popController?.hidesBottomBarWhenPushed = false
                }
            }
            return self?.popToRootViewController(animated: animat)
        }
        pushNavCtrl.popToViewCtrlBlock = {[weak self] viewCtrl,animat in
            var willPushCtrl = viewCtrl
            
            for value in self?.viewControllers ?? [] {
                let nvCtrl : ZZUINavigationPushCtrl = value.children.last as! ZZUINavigationPushCtrl
                let showViewCtrl = nvCtrl.viewControllers.last
                
                if (showViewCtrl == viewCtrl){
                    willPushCtrl = value
                    break
                }
            }
            return self?.popToViewController(willPushCtrl, animated: animat)
        }
        pushNavCtrl.popToVcClasssBlock = {[weak self] vcClass,animat in
            var willPushCtrl:UIViewController? = nil
            for value in self?.viewControllers ?? [] {
                let nvCtrl : ZZUINavigationPushCtrl = value.children.last as! ZZUINavigationPushCtrl
                guard let showViewCtrl = nvCtrl.viewControllers.last else{ break }
                if showViewCtrl.isKind(of: vcClass) {
                    willPushCtrl = value
                    break
                }
            }
            if willPushCtrl == nil { return nil }
            return self?.popToViewController(willPushCtrl!, animated: animat)
        }
        
        pushNavCtrl.pushClearLastViewCtrlBlock = { [weak self] vc, count, animation in
            self?.pushViewController(vc, clearLast: count, animated: animation)
        }
    }

}

extension ZZUINavigationCtrl : UINavigationControllerDelegate{
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let pushNavCtrl = ZZUINavigationPushCtrl()
        self.setPushViewCtrBlock(pushNavCtrl: pushNavCtrl)
        
        let subViewCtrl = ZZPushContentViewCtrl()
        subViewCtrl.view.addSubview(pushNavCtrl.view)
        subViewCtrl.addChild(pushNavCtrl)
        pushNavCtrl.viewControllers = [viewController]
        
        if self.viewControllers.count > 0 {
            subViewCtrl.hidesBottomBarWhenPushed = true
            viewController.navigationItem.hidesBackButton = false
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: self.backButton)
        }
        super.pushViewController(subViewCtrl, animated: animated)
    }

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count == 1 {
            self.currentShowVc = nil
        }else{
            self.currentShowVc = viewController
        }
    }
}

extension ZZUINavigationCtrl : UIGestureRecognizerDelegate{
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            return self.currentShowVc == self.topViewController
        }
        return true;
    }
}

//public extension UINavigationController{
//    override var preferredStatusBarStyle: UIStatusBarStyle{
//        return self.topViewController?.preferredStatusBarStyle ?? .default
//    }
//
//    override var childForStatusBarHidden: UIViewController?{
//        return self.topViewController
//    }
//}

public class ZZPushContentViewCtrl: UIViewController {
    // 状态栏
    public override var preferredStatusBarStyle: UIStatusBarStyle{
        return (self.children.last as? ZZUINavigationPushCtrl)?.viewControllers.last?.preferredStatusBarStyle ?? .default
    }

    public override var prefersStatusBarHidden: Bool{
        return (self.children.last as? ZZUINavigationPushCtrl)?.viewControllers.last?.prefersStatusBarHidden ?? false
    }

    //屏幕旋转
    public override var shouldAutorotate: Bool{
        return (self.children.last as? ZZUINavigationPushCtrl)?.viewControllers.last?.shouldAutorotate ?? false
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return (self.children.last as? ZZUINavigationPushCtrl)?.viewControllers.last?.supportedInterfaceOrientations ?? .portrait
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return (self.children.last as? ZZUINavigationPushCtrl)?.viewControllers.last?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}

public extension ZZFatherViewCtrl{
    var zz_navBackButton: ZZUIButton?{
        let leftItem = self.navigationItem.leftBarButtonItem
        return leftItem?.customView as? ZZUIButton
    }
}

