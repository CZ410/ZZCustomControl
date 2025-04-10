//
//  ViewController.swift
//  ZZCustomControl
//
//  Created by czz_8023 on 02/07/2023.
//  Copyright (c) 2023 czz_8023. All rights reserved.
//

import UIKit
import ZZCustomControl

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ZZFatherViewCtrl.backgroundColor = .white
        ZZFatherViewCtrl.navigationBarBgColor = nil
        ZZFatherViewCtrl.navigationBarBgImage = nil
        ZZFatherViewCtrl.navigationBarBgEffect = UIBlurEffect(style: .dark)
        ZZFatherViewCtrl.titleColor = .orange
        ZZFatherViewCtrl.shadowImage = .zz_image(color: .clear)
        
        let line = ZZScrollView.Item(line: .red)
        
        let tabControl = ZZTabControl().zz_backgroundColor(.orange)
        tabControl.titles = ["九分裤拉倒", "九分裤拉倒", "九分拉倒", "九裤拉倒", "分裤拉倒", "分裤", "倒", "裤拉倒", "九分裤拉倒拉倒拉倒"]
        //        tabControl.titles = ["九分裤拉倒", "九分裤拉倒", ]
        self.view.addSubview(tabControl)
        tabControl.zz_frame(CGRect(x: 10, y: 200, width: 300, height: 50))
        
        tabControl.titleFont = .systemFont(ofSize: 14, weight: .medium)
        tabControl.inset = .zz_all(5)
        //        tabControl.seletedIndex = 2
        //        tabControl.setSelectedIndex(2, animate: true)
        tabControl.scrollIndicatorAlignment = .bottom
        tabControl.scrollIndicatorFixedHeight = 4
        tabControl.scrollIndicator.zz_cornerRadius(2)
        tabControl.selectedScale = 1.5
        tabControl.isBackScrollIndicator = true
        tabControl.scrollIndicatorMoreSize = .zz_only(width: 10)
        tabControl.contentAlignment = .right
        //        tabControl.animateTime = 1
        tabControl.scrollIndicatorOffset = .zz_only(y: 5)
        //        tabControl.itemMoreSize = .zz_all(20)
        //        tabControl.fixedSize = CGSize(width: 100, height: 5)
        //        tabControl.itemOffset = .zz_all(10)
        
        
        
        
        let label = UILabel(text: "jfdlajfldsafds")
            .zz_font(.systemFont(ofSize: 20, weight: .bold))
            .zz_textColor(.black)
        
        label.zz_addTap { sender in
            UIView.transition(with: label,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                guard let `self` = self else { return }
                label.zz_textColor(label.textColor == .red ? .black : .red)
                label.transform = label.transform == .identity ? CGAffineTransform(scaleX: 1.5, y: 1.5) : .identity
                
                tabControl.zz_width += 10
            })
        }
        
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            label.zz_textColor(.red)
        }
        
        let drawView = ZZDrawerView()
            .superView(view)
            .topView(UIView().zz_backgroundColor(.red))
            .topViewHeight(300)
        
        
        var text = "test Title"
        let button = ZZUIButton()
            .set(image: .zz_named("logo 1"), state: .normal)
            .set(title: "test Title", state: .normal)
            .set(titleColor: .red, state: .normal)
//            .set(backgroundColor: .red, state: .normal)
//            .set(contentViewBgColor: .orange, state: .normal)
            .imageSize(.zz_all(80))
            .contentInset(.zz_all(-20))
            .zz_shadow(color: .blue, radius: 20, bgColor: .white)
            .imageView({ $0.zz_cornerRadius(20) })
            .zz_addBlock(for: .touchUpInside) { sender in
                text.append("0")
                (sender as? ZZUIButton)?.set(title: text, state: .normal)
                drawView.show()
            }
        
        button.addConstraints([
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        //        view.zz_addSubView(button, constraints: [
        //            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
        //            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ////            button.heightAnchor.constraint(equalToConstant: 200),
        ////            button.widthAnchor.constraint(equalToConstant: 200)
        //        ])
        
        let stack1 = UIStackView.zz_v([button, UILabel(text: "go to push").zz_addTap(block: { [weak self] sender in
            guard let `self` = self else { return }
            let vc = ZZUINavigationCtrl(rootViewController: TestPushViewCtrl())
            vc.modalPresentationStyle = .fullScreen
                                        
            self.present(vc, animated: true)
        })], spacing: 20)
        view.zz_addSubView(stack1, constraints: [
            stack1.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 200),
            stack1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

