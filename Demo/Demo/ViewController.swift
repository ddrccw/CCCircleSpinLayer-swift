//
//  ViewController.swift
//  Demo
//
//  Created by ccw on 14-8-11.
//  Copyright (c) 2014年 ccw. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    var sp: CCCircleSpinLayer!
    var lastValue: Float = 0.0
    @IBOutlet weak var silder: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sp = CCCircleSpinLayer(size: CGSize(width: 80, height: 80), color: UIColor.whiteColor(), animated: false)
        self.view.layer.addSublayer(self.sp)
        self.sp.position = self.view.center
        self.view.backgroundColor = UIColor(CGColor: self.sp.backgroundColor)
        self.silder.value = 0
        self.silder.addTarget(self, action: "change:", forControlEvents: .ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func change(aSlider: UISlider) {
        self.sp.startAnimating()
//        if self.lastValue < aSlider.value {
//            self.sp.showInProgress(aSlider.value)
//        }
//        else {
//            self.sp.showInProgress(-aSlider.value)
//        }
//        self.lastValue = aSlider.value
    }
}

