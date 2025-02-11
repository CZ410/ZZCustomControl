//
//  FatherAlertViewCtrl.swift
//  ZZToolKit
//
//  Created by 陈钟 on 2019/12/20.
//  Copyright © 2019 陈钟. All rights reserved.
//

import UIKit

extension UIViewController{
    @objc var isAlertBeingDismiss: Bool{
        set{
            zz_objc_set(key: "isAlertBeingDismiss", newValue)
        }
        get{
            return zz_objc_get(key: "isAlertBeingDismiss", Bool.self) ?? false
        }
    }

    @objc var isAlertBeingPresent: Bool{
        set{
            zz_objc_set(key: "isAlertBeingPresent", newValue)
        }
        get{
            return zz_objc_get(key: "isAlertBeingPresent", Bool.self) ?? false
        }
    }
}

@objcMembers
open class ZZFatherAlertViewCtrl: UIViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.createView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - datas
    open var animationTime: TimeInterval = 0.25

    open var isCancelWhenTouchBg: Bool = true

    //MARK: - methods

    open func presentStart(){ }
    open func presentIng(){ }
    open func presentEnd(){ }

    open func dismissStart(){ }
    open func dismissIng(){ }
    open func dismissEnd(){ }

    open func createView(){
        self.view.backgroundColor = UIColor.clear
        self.view.addSubview(self.effectBgView)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.effectBgView.frame = self.view.bounds
        self.view.sendSubviewToBack(self.effectBgView)
    }

    open func present(frome superViewCtrl: UIViewController){
        if self.presentingViewController != nil { return }
        if #available(iOS 8, *) {
            self.modalPresentationStyle = .overCurrentContext
        } else {
            self.modalPresentationStyle = .currentContext
        }
        self.isAlertBeingPresent = true
        superViewCtrl.present(self, animated: false, completion: {
            [weak self] in
            guard let `self` = self else { return }
            self.effectBgView.alpha = 0
            self.presentStart()
            UIView.animate(withDuration: self.animationTime, animations: { [weak self] in
                guard let `self` = self else { return }
                self.effectBgView.alpha = 0.8
                self.presentIng()
            }, completion: {[weak self] (finished) in
                guard let `self` = self else { return }
                self.presentEnd()
                self.isAlertBeingPresent = false
            })
        })
    }

    open func cancelAction(completion: (() -> Void)? = nil){
        self.isAlertBeingDismiss = true
        self.dismissStart()
        UIView.animate(withDuration: self.animationTime,
                       animations: { [weak self] in
                        guard let `self` = self else { return }
                        self.effectBgView.alpha = 0.0
                        self.dismissIng()
        }, completion: {[weak self] (finished) in
            guard let `self` = self else { return }
            self.dismissEnd()
            self.dismiss(animated: false, completion: completion)
            self.isAlertBeingDismiss = false
        })
    }

    //MARK: - views
    open lazy var effectBgView: UIVisualEffectView = {
        let style = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView.init(effect: style)
        view.frame = self.view.bounds
        view.alpha = 0.0
        return view
    }()

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isCancelWhenTouchBg ? self.cancelAction() : nil
    }
}
