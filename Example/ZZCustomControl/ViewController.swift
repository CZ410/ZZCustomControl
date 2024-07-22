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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

