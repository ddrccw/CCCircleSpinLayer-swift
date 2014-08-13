//
//  CCCircleSpinLayer.swift
//  Demo
//
//  Created by ccw on 14-8-11.
//  Copyright (c) 2014年 ccw. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

func degreesToRadians(angle: Float) -> Float {
    return (angle / 180.0 * Float(M_PI))
}

private func cirlePositionOnCircle(angleInDegrees: Float, radius: Float, offset: Float) -> CGPoint
{
    let radians: Float = degreesToRadians(angleInDegrees - 90)
    return CGPointMake(CGFloat(radius * cos(radians) + offset),
                       CGFloat(radius * sin(radians) + offset))
}

let kNumberOfCircle: Int = 8
let kCircleShownKey = "kCircleShownKey"
let kCircleShowHideDuration = 0.5

class CCCircleSpinLayer: CALayer {
    var offsetIndex: Int = 0
    var isAnimating: Bool = false
    var color: UIColor!
    var circles: [CALayer]!
   
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    convenience init(size: CGSize, color: UIColor, animated: Bool) {
        self.init(size: size, circleRadius:0, color: color, animated: animated)
    }
    
    init(size: CGSize, circleRadius: Float, color: UIColor, animated: Bool)
    {
        super.init()
        self.backgroundColor = UIColor(red: 0.1529, green: 0.6824, blue: 0.3765, alpha: 1).CGColor
        self.bounds = CGRectMake(0, 0, size.width, size.height)
        let beginTime = CACurrentMediaTime()
        let outterRadius = Float(min(size.width, size.height) / 2.0)
        assert(circleRadius <= outterRadius / 2.0, "circleRaidus should be less than a quarter of size")
        var circleRadius_: Float = 0.0
        if circleRadius <= 0 {
            circleRadius_ = outterRadius / 4
        }
        else {
            circleRadius_ = circleRadius
        }
        
        let innerRadius: Float = outterRadius - circleRadius_
        let angleInDegrees: Float = 360.0 / Float(kNumberOfCircle)
        offsetIndex = Int.min
        isAnimating = animated
        var arr: [CALayer] = Array()
        for var i = 0; i < kNumberOfCircle; ++i {
            let circle = CALayer()
            circle.bounds = CGRectMake(0, 0, CGFloat(circleRadius_), CGFloat(circleRadius_))
            circle.backgroundColor = color.CGColor
            circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5
            circle.setValue(false, forKey: kCircleShownKey)
            circle.position = cirlePositionOnCircle(angleInDegrees * Float(i), innerRadius, outterRadius)
            circle.opacity = 0
            if animated {
                let anim = circleScaleAnimationAtIndex(i, beginTime: beginTime)
                circle.addAnimation(anim, forKey: "scale-anim")
            }
            self.addSublayer(circle)
            arr.append(circle)
        }
        
        self.circles = arr
    }
   
    func showInProgress(progress: Float) {
        if -1 <= progress && progress <= 1 {
            let offsetIndex = Int(ceilf(progress * Float(kNumberOfCircle)))
            if self.offsetIndex == offsetIndex { return }
            var layer: CALayer!
            var animGroup: CAAnimationGroup!
            var shown = false
            if progress >= 0 {
                //show
                for var i = 0; i < abs(offsetIndex); ++i {
                    layer = self.circles[i]
                    shown = layer.valueForKey(kCircleShownKey).boolValue
                    if !shown {
                        animGroup = self.circleShowAnimationGroup()
                        layer.addAnimation(animGroup, forKey: "show-anim")
                        layer.setValue(true, forKey: kCircleShownKey)
                    }
                }
            }
            else {
                //hide
                for var i = kNumberOfCircle - 1; i > abs(offsetIndex) - 1; --i {
                    layer = self.circles[i]
                    shown = layer.valueForKey(kCircleShownKey).boolValue
                    if shown {
                        animGroup = self.circleHideAnimationGroup()
                        layer.addAnimation(animGroup, forKey: "hide-anim")
                        layer.setValue(false, forKey: kCircleShownKey)
                    }
                }
            }
            
            self.offsetIndex = offsetIndex
        }
        else {
            self.resetLayersAndAnimated(false)
        }
    }
    
    func startAnimating() {
        if !self.isAnimating {
            self.resetLayersAndAnimated(true)
            self.resumeLayers()
            self.isAnimating = true
        }
    }
    
    func stopAnimating() {
        if self.isAnimating == true {
            self.resetLayersAndAnimated(false)
            self.isAnimating = false
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - private method
    private func circleHideAnimationGroup() -> CAAnimationGroup {
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform")
        scaleAnim.keyTimes = [0, 0.1, 0.3, 1]
        scaleAnim.values = [
            NSValue(CATransform3D: CATransform3DScale(CATransform3DIdentity, 1, 1, 1)),
            NSValue(CATransform3D: CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1)),
            NSValue(CATransform3D: CATransform3DScale(CATransform3DIdentity, 1, 1, 1)),
            NSValue(CATransform3D: CATransform3DScale(CATransform3DIdentity, 0, 0, 1))
        ]
        
        let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnim.keyTimes = [0, 0.1, 0.3, 1]
        opacityAnim.values = [1, 1, 1, 0]
        
        let animGroup = CAAnimationGroup()
        animGroup.duration = kCircleShowHideDuration
        animGroup.animations = [scaleAnim, opacityAnim]
        animGroup.fillMode = kCAFillModeForwards
        animGroup.removedOnCompletion = false
        animGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return animGroup
    }
    
    private func circleShowAnimationGroup() -> CAAnimationGroup {
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform")
        scaleAnim.keyTimes = [0, 0.7, 0.9, 1]
        scaleAnim.values = [
            NSValue(CATransform3D: CATransform3DScale(CATransform3DIdentity, 0, 0, 1)),
            NSValue(CATransform3D: CATransform3DScale(CATransform3DIdentity, 1, 1, 1)),
            NSValue(CATransform3D: CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1)),
            NSValue(CATransform3D: CATransform3DScale(CATransform3DIdentity, 1, 1, 1))
        ]
        
        let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnim.keyTimes = [0, 0.7, 0.9, 1]
        opacityAnim.values = [0, 1, 1, 1]

        let animGroup = CAAnimationGroup()
        animGroup.duration = kCircleShowHideDuration
        animGroup.animations = [scaleAnim, opacityAnim]
        animGroup.fillMode = kCAFillModeForwards
        animGroup.removedOnCompletion = false
        animGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return animGroup
    }
    
    private func circleScaleAnimationAtIndex(index: Int, beginTime: CFTimeInterval)
    -> CAAnimationGroup
    {
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = 1
        opacityAnim.removedOnCompletion = false
        opacityAnim.fillMode = kCAFillModeForwards
        opacityAnim.beginTime = 0
        
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform")
        scaleAnim.removedOnCompletion = false
        scaleAnim.fillMode = kCAFillModeForwards
        scaleAnim.beginTime = 0
        let multiple: Double = 1;
        scaleAnim.duration = CFTimeInterval(kNumberOfCircle) / 7.0 * multiple
        var keyTimes: [CFTimeInterval] = Array()
        var values: [NSValue] = Array()
        var timeFunctions: [CAMediaTimingFunction] = Array()
        keyTimes.append(0)
        var keyTime: CFTimeInterval = 0.0
        var t = CATransform3DIdentity
        var scale: Float = 0.0
        var mid: Int = (kNumberOfCircle - 2) / 2
        var midOffset = mid + 1
        
        for var i = 1; i < kNumberOfCircle + 1; ++i {
            keyTime = CFTimeInterval(scaleAnim.duration / multiple) / CFTimeInterval(kNumberOfCircle) * CFTimeInterval(i)
            keyTime = min(keyTime, 1)
            keyTimes.append(keyTime)
            if i == 1 || i == kNumberOfCircle {
                scale = 0
            }
            else if i <= midOffset {
                scale = Float(min(1.0 / mid * (i - 1), 1))
            }
            else {
                scale = Float(min(1.0 / mid * (kNumberOfCircle - i), 1))
            }
            t = CATransform3DScale(CATransform3DIdentity, CGFloat(scale), CGFloat(scale), 1)
            values.append(NSValue(CATransform3D: t))
            
            timeFunctions.append(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        
        scaleAnim.keyTimes = keyTimes
        scaleAnim.values = values
        scaleAnim.timingFunctions = timeFunctions
        
        let animGroup = CAAnimationGroup()
        animGroup.duration = scaleAnim.duration
        animGroup.beginTime = beginTime - Double(65536 * scaleAnim.duration)
        animGroup.beginTime += Double(index) * (scaleAnim.duration / Double(kNumberOfCircle))
        animGroup.repeatCount = HUGE
        animGroup.animations = [opacityAnim, scaleAnim]
        animGroup.removedOnCompletion = false
        animGroup.fillMode = kCAFillModeForwards
        animGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return animGroup
    }
    
    private func resetLayersAndAnimated(animated: Bool) {
        let currentTime = CACurrentMediaTime()
        let currentTimeInSuperLayer = self.convertTime(currentTime, fromLayer: nil)
        var anim: CAAnimationGroup!
        var circle: CALayer!
        for var i = 0; i < self.circles.count; ++i {
            circle = self.circles[i]
            circle.removeAllAnimations()
            circle.opacity = 0
            circle.setValue(false, forKey: kCircleShownKey)
            if animated {
                let currentTimeInCircle = circle.convertTime(currentTimeInSuperLayer, fromLayer: self)
                anim = self.circleScaleAnimationAtIndex(i, beginTime: currentTimeInCircle)
                circle.addAnimation(anim, forKey: "scale-anim")
            }
        }
        
        if animated {
            self.pauseLayersAtTime(currentTime)
        }
        else {
            self.speed = 1
            self.timeOffset = 0
            self.beginTime = 0
        }
    }
    
    private func pauseLayersAtTime(time: CFTimeInterval) {
        let pausedTime = self.convertTime(time, fromLayer: nil)
        self.speed = 0
        self.timeOffset = pausedTime
    }
    
    private func resumeLayers() {
        let pausedTime = self.timeOffset
        self.speed = 1
        self.timeOffset = 0
        self.beginTime = 0
        let timeSincePause = self.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        self.beginTime = timeSincePause
    }
}




























