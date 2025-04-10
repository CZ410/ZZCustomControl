//
//  FatherViewCtrl.swift
//  BuildingWeather
//
//  Created by 陈钟 on 2019/5/9.
//  Copyright © 2019 陈钟. All rights reserved.
//

import UIKit
import ZZBase

@objcMembers
open class ZZFatherViewCtrl: UIViewController {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ZZFatherViewCtrl.backgroundColor
        
        self.zz_navBarBgImg(Self.navigationBarBgImage)
            .zz_navBarBgColor(Self.navigationBarBgColor)
            .zz_navBarBgEffect(Self.navigationBarBgEffect)
            .zz_shadowImag(Self.shadowImage)
            .zz_titleColor(Self.titleColor)
            .zz_titleFont(Self.titleFont)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive(notificaton:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationBecomeActive(notificaton:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        createView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

    public static var navigationBarBgImage : UIImage? = .zz_image(color: .white)
    public static var navigationBarBgColor : UIColor?
    public static var navigationBarBgEffect: UIBlurEffect?
    public static var shadowImage: UIImage? = UIImage()
    public static var titleColor: UIColor? = UIColor.black
    public static var titleFont: UIFont = UIFont.systemFont(ofSize: 19, weight: .medium)
    public static var backgroundColor: UIColor = .white
   

    open lazy var rightButton: ZZUIButton = {
        let button = ZZUIButton()
        button.titleLabel.font = UIFont.systemFont(ofSize: 17)
        button.set(titleColor: UIColor.white, state: .normal)
        button.zz_size = CGSize(width: 44, height: 44)
        button.contentAlignment = .RightCenter
        button.contentOffset = CGPoint.init(x: -15, y: 0)
        button.addTarget(self, action: #selector(rightButtonAction(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)
        return button
    }()
    
    open lazy var leftButton: ZZUIButton = {
        let button = ZZUIButton()
        button.titleLabel({$0.zz_font(.systemFont(ofSize: 14))})
            .set(titleColor: .white, state: .normal)
            .contentAlignment(.LeftCenter)
            .zz_size(CGSize(44))
            .contentOffset(CGPoint(x: 15, y: 0))
            .zz_addTarget(self, action: #selector(self.leftButtonAction(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: button)
        return button
    }()
    
    
    //MARK: - method
    open func backButton() -> ZZUIButton? {
        return self.navigationItem.leftBarButtonItem?.customView as? ZZUIButton
    }

    @objc
    open func applicationWillResignActive(notificaton:Notification) -> Void {
//        ZZLog("home键 按下")
    }
    @objc
    open func applicationBecomeActive(notificaton:Notification) -> Void {
//        ZZLog("应用重新回到活跃状态")
    }
    
    open func createView() -> Void {
//        ZZLog("您将要绘制界面啦")
    }
    
    @objc
    open dynamic func rightButtonAction(sender:ZZUIButton) -> Void {
//        ZZLog("您点击了navigationbar 右边的按钮")
    }

    @objc
    open dynamic func leftButtonAction(sender:ZZUIButton) -> Void {
//        ZZLog("您点击了navigationbar 左边的按钮")
    }
}
