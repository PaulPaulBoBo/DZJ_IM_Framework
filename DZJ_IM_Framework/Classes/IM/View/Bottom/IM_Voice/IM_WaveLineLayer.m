//
//  IM_WaveLineLayer.m
//  DoctorCloud
//
//  Created by dzj on 2020/7/1.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_WaveLineLayer.h"

@implementation IM_WaveLineLayer

#pragma mark - public

// 创建音条layer
-(void)loadCustomLayer:(CGFloat)height width:(CGFloat)width color:(UIColor *)color isUp:(BOOL)isUp {
    UIBezierPath * bezierPath = [[UIBezierPath alloc]init];
    if(isUp) {
        [bezierPath moveToPoint:CGPointMake(width/2.0, height/2.0)];
        [bezierPath addLineToPoint:CGPointMake(width/2.0, 0)];
    } else {
        [bezierPath moveToPoint:CGPointMake(width/2.0, height/2.0)];
        [bezierPath addLineToPoint:CGPointMake(width/2.0, height)];
    }
    self.path = bezierPath.CGPath;
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeEnd = 0;
    self.strokeColor = color.CGColor;
    self.lineWidth = width; // 线宽
    self.lineCap = @"round";
}

// 更新音条高度
-(void)updateLayerHeight:(CGFloat)height {
    self.strokeEnd = height;
}

/// 修改音条颜色
/// @param color 颜色
-(void)updateLineColor:(UIColor *)color {
    self.strokeColor = color.CGColor;
}

@end
