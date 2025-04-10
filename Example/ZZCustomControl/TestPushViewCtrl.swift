//
//  TestPushViewCtrl.swift
//  ZZCustomControl
//
//  Created by 陈钟 on 2025/4/10.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import ZZCustomControl
import WebKit
import ZZBase

class TestPushViewCtrl: ZZFatherViewCtrl {
    override func createView() {
        title = "TestPushViewCtrl"
        
        leftButton.set(title: "Back", state: .normal)
//        let backBtn = ZZUIButton(normal: "Back")
//            .zz_backgroundColor(.red)
//            .zz_addBlock(for: .touchUpInside) { sender in
//                self.dismiss(animated: true)
//            }
//        
//        view.zz_addSubView(backBtn, constraints: [
//            backBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            backBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//        ])
        
        view.zz_addSubView(contentView, constraints: [
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        webview.load(URLRequest(url: zz_url("https://www.baidu.com")!))
    }
    
    override func leftButtonAction(sender: ZZUIButton) {
        
        self.dismiss(animated: true)
    }
    
    lazy var contentView = ZZScrollView(items: [item1, item2, item3,  item5, item4, item6])
    
    lazy var item1 = ZZScrollView.Item(view: view1, inset: .zz_all(20), minHeight: 200)
    lazy var item2 = ZZScrollView.Item(view: view2, inset: .zz_all(20), minHeight: 200)
    lazy var item3 = ZZScrollView.Item(view: view3, inset: .zz_all(20), minHeight: 200)
    lazy var item4 = ZZScrollView.Item(view: view4, inset: .zz_all(20), minHeight: 200)
    
    lazy var item5 = ZZScrollView.Item(view: table, minHeight: 200)
    
    lazy var item6 = ZZScrollView.Item(view: webview, inset: .zz_all(20), minHeight: 200)
    
    
    lazy var view1 = UIView().zz_backgroundColor(.orange).zz_addTap { sender in
        ZZLogger.info("\(String(describing: self.navigationController))")
        self.zz_push(viewCtrl: TestPushViewCtrl())
    }
    lazy var view2 = UIView().zz_backgroundColor(.orange).zz_addTap { sender in
        self.navigationController?.pushViewController(TestPushViewCtrl(), clearLast: 2, animated: true)
    }
    lazy var view3 = UIView().zz_backgroundColor(.orange)
        .zz_addTap { sender in
            self.zz_pop()
        }
    lazy var view4 = UIView().zz_backgroundColor(.orange)
    lazy var table = UITableView.zz_make(delegate: self, dataSource: self, registerCells: [UITableViewCell.self])
    lazy var webview = WKWebView()
}

extension TestPushViewCtrl: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.zz_cell(cellClass: UITableViewCell.self, for: indexPath)
        cell.textLabel?.text = "\(indexPath)"
        return cell
    }

    
}
