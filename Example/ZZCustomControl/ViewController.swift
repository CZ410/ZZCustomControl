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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

