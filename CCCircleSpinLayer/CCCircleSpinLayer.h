//
//  CCCircleSpinLayer.h
//  Edu901
//
//  Created by user on 14-1-20.
//  Copyright (c) 2014年 admin. All rights reserved.
//

@import UIKit;
@import Foundation;
@import QuartzCore;

@interface CCCircleSpinLayer : CALayer

- (instancetype)initWithSize:(CGSize)size
                       color:(UIColor*)color
                    animated:(BOOL)animated;
- (instancetype)initWithSize:(CGSize)size
                circleRaidus:(CGFloat)circleRaidus
                       color:(UIColor *)color
                    animated:(BOOL)animated;
- (void)showInProgress:(CGFloat)progress; //positive-show, negative-hide

- (void)startAnimating;
- (void)stopAnimating;
@end

