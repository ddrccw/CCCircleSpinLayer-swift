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
    var anosp: CCCircleSpinLayer!
    var lastValue: Float = 0.0
    @IBOutlet weak var silder: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sp = CCCircleSpinLayer(size: CGSize(width: 80, height: 80), color: UIColor.whiteColor(), animated: false)
        self.anosp = CCCircleSpinLayer(size: CGSize(width: 80, height: 80), color: UIColor.whiteColor(), animated: false)
        self.view.layer.addSublayer(self.sp)
        self.view.layer.addSublayer(self.anosp)
        self.sp.position = self.view.center
        self.anosp.position = CGPointMake(self.view.frame.size.width / 2, 100)
        self.view.backgroundColor = UIColor(CGColor: self.sp.backgroundColor)
        self.silder.value = 0
        self.silder.addTarget(self, action: "change:", forControlEvents: .ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func change(aSlider: UISlider) {
        if self.lastValue < aSlider.value {
            self.sp.showInProgress(aSlider.value)
        }
        else {
            self.sp.showInProgress(-aSlider.value)
        }
        self.lastValue = aSlider.value
    }
    
    var hasStart = false
    @IBAction func start(sender: AnyObject) {
        if !hasStart {
            self.anosp.startAnimating()
        }
        else {
            self.anosp.stopAnimating()
        }
        hasStart = !hasStart
    }
}

