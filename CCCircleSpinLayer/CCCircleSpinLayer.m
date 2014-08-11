//
//  CCCircleSpinLayer.m
//  Edu901
//
//  Created by user on 14-1-20.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "CCCircleSpinLayer.h"

#ifndef DEGREES_TO_RADIANS
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#endif
#ifndef RADIANS_TO_DEGREES
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / M_PI * 180.0)
#endif

static CGPoint cirlePositionOnCircleWithRadiusAndOffset(CGFloat angleInDegrees, CGFloat radius, CGFloat offset) {
    float radians = DEGREES_TO_RADIANS(angleInDegrees - 90);
    return CGPointMake(radius * cosf(radians) + offset,
                       radius * sinf(radians) + offset);
}

static const NSUInteger kNumberOfCircle = 8;
static NSString * const kCircleShownKey = @"kCircleShownKey";
static const CGFloat kCircleShowHideDuration = .5;

@interface CCCircleSpinLayer()
{
    NSInteger offsetIndex_;
    BOOL isAnimating_;
}
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSArray *circles;
@end

@implementation CCCircleSpinLayer

- (instancetype)initWithSize:(CGSize)size color:(UIColor *)color animated:(BOOL)animated {
    return [self initWithSize:size circleRaidus:0 color:color animated:animated];
}

- (instancetype)initWithSize:(CGSize)size circleRaidus:(CGFloat)circleRaidus color:(UIColor *)color animated:(BOOL)animated {
    if (self = [self init]) {
        self.backgroundColor = [UIColor colorWithRed:0.1529 green:0.6824 blue:0.3765 alpha:1].CGColor;
        self.bounds = CGRectMake(0, 0, size.width, size.height);
        NSTimeInterval beginTime = CACurrentMediaTime();
        CGFloat outterRadius = MIN(size.width, size.height) / 2;
        
        NSAssert(circleRaidus <= outterRadius / 2, @"circleRaidus should be less than a quarter of size");
        CGFloat circleRaidus_ = 0;
        if (circleRaidus <= 0) {
            circleRaidus_ = outterRadius / 4;
        }
        else {
            circleRaidus_ = circleRaidus;
        }
        
        CGFloat innerRadius = outterRadius - circleRaidus_;
        CGFloat angleInDegrees = 360 / kNumberOfCircle;
        offsetIndex_ = NSIntegerMin;
        isAnimating_ = animated;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:kNumberOfCircle];
        for (NSInteger i = 0; i < kNumberOfCircle; ++i) {
            CALayer *circle = [CALayer layer];
            circle.bounds = CGRectMake(0, 0, circleRaidus_, circleRaidus_);
            circle.backgroundColor = color.CGColor;
            circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5;
            [circle setValue:@(NO) forKey:kCircleShownKey];
            circle.position = cirlePositionOnCircleWithRadiusAndOffset(angleInDegrees * i, innerRadius, outterRadius);
            circle.opacity = 0;
            if (animated) {
                CAAnimationGroup *anim = [self circleScaleAnimationAtIndex:i
                                                             fromBeginTime:beginTime];
                [circle addAnimation:anim forKey:@"scale-anim"];
            }
            [self addSublayer:circle];
            [arr addObject:circle];
        }
        
        _circles = [NSArray arrayWithArray:arr];
    }
    return self;
}

//- (CAKeyframeAnimation *)circlePositionAnimationAtIndex:(NSInteger)index
//                                          fromBeginTime:(NSTimeInterval)beginTime
//                                     withAngleInDegress:(CGFloat)angleInDegrees
//                                            finalRaidus:(CGFloat)finalRaidus
//                                                 offset:(CGFloat)offset
//{
//    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    anim.removedOnCompletion = NO;
//    anim.beginTime = beginTime - index * .7;
//    anim.duration = .8;
//    anim.repeatCount = 1;
////    anim.autoreverses = YES;
////    float multiple = 1.5;
////    anim.duration = kNumberOfCircle / 10. * multiple;
////    anim.beginTime = beginTime - anim.duration + index * (anim.duration / kNumberOfCircle);
//
//    anim.keyTimes = @[@0, @.4, @.7, @.9, @1];
//    anim.values = @[
//                    [NSValue valueWithCGPoint:cirlePositionOnCircleWithRadiusAndOffset(angleInDegrees * index, 0, offset)],
//                    [NSValue valueWithCGPoint:cirlePositionOnCircleWithRadiusAndOffset(angleInDegrees * index, .4*finalRaidus, offset)],
//                    [NSValue valueWithCGPoint:cirlePositionOnCircleWithRadiusAndOffset(angleInDegrees * index, .8*finalRaidus, offset)],
//                    [NSValue valueWithCGPoint:cirlePositionOnCircleWithRadiusAndOffset(angleInDegrees * index, 1.1*finalRaidus, offset)],
//                    [NSValue valueWithCGPoint:cirlePositionOnCircleWithRadiusAndOffset(angleInDegrees * index, finalRaidus, offset)]];
//    return anim;
//}

- (void)showInProgress:(CGFloat)progress {
    if (-1 <= progress && progress <= 1) {
        int offsetIndex = ceilf(progress * kNumberOfCircle);
        if (offsetIndex_ == offsetIndex) return;
        //        NSLog(@"%d, %f", offsetIndex, progress);
        CALayer *layer = nil;
        CAAnimationGroup *animGroup = nil;
        if (progress >= 0) {
            //show
            for (int i = 0; i < abs(offsetIndex); ++i) {
                layer = self.circles[i];
                if (![[layer valueForKey:kCircleShownKey] boolValue]) {
                    animGroup = [self circleShowAnimationGroup];
                    [layer addAnimation:animGroup forKey:@"show-anim"];
                    [layer setValue:@YES forKey:kCircleShownKey];
                }
            }
        }
        else {
            //hide
            for (int i = kNumberOfCircle - 1; i > abs(offsetIndex) - 1; --i) {
                layer = self.circles[i];
                if ([[layer valueForKey:kCircleShownKey] boolValue]) {
                    animGroup = [self circleHideAnimationGroup];
                    [layer addAnimation:animGroup forKey:@"hide-anim"];
                    [layer setValue:@NO forKey:kCircleShownKey];
                }
            }
            
        }
        
        offsetIndex_ = offsetIndex;
    }
    else {
        [self resetLayersAndAnimated:NO];
    }
}

- (void)startAnimating {
    if (!isAnimating_) {
        [self resetLayersAndAnimated:YES];
        [self resumeLayers];
        isAnimating_ = YES;
    }
}

- (void)stopAnimating {
    if (isAnimating_) {
        [self resetLayersAndAnimated:NO];
        isAnimating_ = NO;
	}
}


- (CAAnimationGroup *)circleHideAnimationGroup {
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnim.keyTimes = @[@0, @.1, @.3, @1];
    scaleAnim.values = @[
                         [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1, 1, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1, 1, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 0, 0, 1)]
                         ];
    
    CAKeyframeAnimation *opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.keyTimes = @[@0, @.1, @.3, @1];
    opacityAnim.values = @[@1, @1, @1, @0];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.duration = kCircleShowHideDuration;
	animGroup.animations = @[scaleAnim, opacityAnim];
	animGroup.fillMode = kCAFillModeForwards;
	animGroup.removedOnCompletion = NO;
    animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animGroup;
}


- (CAAnimationGroup *)circleShowAnimationGroup {
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnim.keyTimes = @[@0, @.7, @.9, @1];
    scaleAnim.values = @[
                         [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 0, 0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1, 1, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1, 1, 1)]
                         ];
    
    CAKeyframeAnimation *opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.keyTimes = @[@0, @.7, @.9, @1];
    opacityAnim.values = @[@0, @1, @1, @1];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.duration = kCircleShowHideDuration;
	animGroup.animations = @[scaleAnim, opacityAnim];
	animGroup.fillMode = kCAFillModeForwards;
	animGroup.removedOnCompletion = NO;
    animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animGroup;
}

- (CAAnimationGroup *)circleScaleAnimationAtIndex:(NSInteger)index fromBeginTime:(NSTimeInterval)beginTime {
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = @1;
    opacityAnim.toValue = @1;
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.beginTime = 0;
    
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnim.removedOnCompletion = NO;
    scaleAnim.fillMode = kCAFillModeForwards;
    scaleAnim.beginTime = 0;
    float multiple = 1;
    scaleAnim.duration = kNumberOfCircle / 7. * multiple;
    
    NSMutableArray *keyTimes = [NSMutableArray arrayWithCapacity:kNumberOfCircle + 1];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:kNumberOfCircle];
    NSMutableArray *timeFuntions = [NSMutableArray arrayWithCapacity:kNumberOfCircle];
    [keyTimes addObject:@0];
    double keyTime = 0;
    CATransform3D t = CATransform3DIdentity;
    float scale = 0;
    float mid = (kNumberOfCircle - 2) / 2;
    int midOffset = mid + 1;
    
    for (int i = 1; i < kNumberOfCircle + 1; ++i) {
        keyTime = MIN(scaleAnim.duration / multiple / kNumberOfCircle * i, 1);
        [keyTimes addObject:@(keyTime)];
        
        if (i == 1 || i == kNumberOfCircle) {
            scale = 0;
        }
        else if (i <= midOffset) {
            scale = MIN(1.0 / mid * (i - 1), 1);
        }
        else {
            scale = MIN(1.0 / mid * (kNumberOfCircle - i), 1);
        }
        t = CATransform3DScale(CATransform3DIdentity, scale, scale, 1);
        [values addObject:[NSValue valueWithCATransform3D:t]];
        
        [timeFuntions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    
    scaleAnim.keyTimes = keyTimes;
    scaleAnim.values = values;
    scaleAnim.timingFunctions = timeFuntions;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.duration = scaleAnim.duration;
    animGroup.beginTime = beginTime - 65536 * scaleAnim.duration + index * (scaleAnim.duration / kNumberOfCircle);
    animGroup.repeatCount = HUGE_VALF;
    animGroup.animations = @[opacityAnim, scaleAnim];
    animGroup.removedOnCompletion = NO;
	animGroup.fillMode = kCAFillModeForwards;
    animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    return animGroup;
}

- (void)resetLayersAndAnimated:(BOOL)animated {
    CFTimeInterval currentTime = CACurrentMediaTime();
    CFTimeInterval currentTimeInSuperLayer = [self convertTime:currentTime
                                                     fromLayer:nil];
    CAAnimationGroup *anim = nil;
    CALayer *circle = nil;
    for (int i = 0; i < [self.circles count]; ++i) {
        circle = self.circles[i];
        [circle removeAllAnimations];
        circle.opacity = 0;
        [circle setValue:@(NO) forKey:kCircleShownKey];
        if (animated) {
            CFTimeInterval currentTimeInCircle = [circle convertTime:currentTimeInSuperLayer fromLayer:self];
            anim = [self circleScaleAnimationAtIndex:i
                                       fromBeginTime:currentTimeInCircle];
            [circle addAnimation:anim forKey:@"scale-anim"];
        }
    }
    
    if (animated) {
        [self pauseLayersAtTime:currentTime];
    }
    else {
        self.speed = 1;
        self.timeOffset = 0;
        self.beginTime = 0;
    }
}

- (void)pauseLayersAtTime:(CFTimeInterval)time {
    CFTimeInterval pausedTime = [self convertTime:time fromLayer:nil];
    self.speed = 0.0;
    self.timeOffset = pausedTime;
}

- (void)resumeLayers {
    CFTimeInterval pausedTime = [self timeOffset];
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeSincePause;
}


@end

















