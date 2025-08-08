//
//  EmptyViewTestViewCtrl.swift
//  ZZCustomControl
//
//  Created by 陈钟 on 2025/8/1.
//  Copyright © 2025 CocoaPods. All rights reserved.
//
import ZZBase
import ZZCustomControl

class EmptyViewTestViewCtrl: ZZFatherViewCtrl {
    override func viewDidLoad() {
        super.viewDidLoad()
        leftButton.set(title: "Back", state: .normal)
        view.zz_addTap { sender in
            emptyErr()
        }
        
        func emptyNone(){
            self.view.zz_emptyStyle(.none)
        }
        
        func emptyNothing(){
            self.view.zz_emptyStyle(.nothing)
                .zz_emptyButton(onTap:  {
                    emptyNone()
                })
        }
        
        func emptyMessage(){
            self.view.zz_emptyStyle(.message)
                .zz_emptyButton(onTap:  {
                    emptyNothing()
                })
        }
        
        func emptyLoading(){
            self.view
                .zz_emptyStyle(.loading)
                .zz_emptyButton(title: "Cancel LoadingCancel LoadingCancel LoadingCancel LoadingCancelLoadingCancel LoadingCancel LoadingCancel LoadingCancelLoadingCancel LoadingCancel LoadingCancel LoadingCancelLoadingCancel LoadingCancel LoadingCancel LoadingCancel Loading", styleBlock: { reloadButton in
                    reloadButton
                        .contentInset(.zz_all(-40))
                        .set(backgroundColor: .yellow, state: .normal)
                        .titleLabel({ $0.zz_numberOfLines(0) })
                        .set(titleColor: .red, state: .normal)
                        .zz_constrain { view in
                            [
                                view.widthAnchor.constraint(equalToConstant: 200),
                                view.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
                            ]
                        }
                    
                }, onTap: {
                    emptyMessage()
                })
        }

        func emptyErr(){
            view
                .zz_emptyStyle(
                    .error,
                    config: .error
                        .copy(
                            text: "c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少c错误乐乐浪费大家浪费多少",
                            textColor: .red
                        ),
                    block: { emptyView in
                        emptyView.titleLab.zz_numberOfLines(0)
                    }
                )
                .zz_emptyButton(title: "CCCC", onTap: {
                    emptyLoading()
                })
        }
        emptyErr()
    }

    override func leftButtonAction(sender: ZZUIButton) {
        dismiss(animated: true)
    }
}
