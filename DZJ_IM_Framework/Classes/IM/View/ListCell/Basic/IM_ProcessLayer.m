//
//  IM_ProcessLayer.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/28.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_ProcessLayer.h"

@interface IM_ProcessLayer()

@property (nonatomic, assign) IM_ProcessType type;

@end

@implementation IM_ProcessLayer

#pragma mark - public

-(void)loadCustomLayer:(CGFloat)height width:(CGFloat)width type:(IM_ProcessType)type {
    self.type = type;
    self.backgroundColor = [UIColor clearColor].CGColor;
    switch (type) {
        case IM_ProcessTypeLine: {
            [self loadLineCustomLayer:height width:width];
        } break;
        case IM_ProcessTypeCircle: {
            [self loadCircleCustomLayer:height width:width];
        } break;
        default: {
            [self loadLineCustomLayer:height width:width];
        } break;
    }
}

/// 更新进度条
-(void)updateProcessValue:(CGFloat)processValue {
    if(processValue > self.strokeEnd) {
        switch (self.type) {
            case IM_ProcessTypeLine: {
                self.strokeEnd = processValue;
            } break;
            case IM_ProcessTypeCircle: {
                self.strokeEnd = processValue;
            } break;
            default: {
                self.strokeEnd = processValue;
            } break;
        }
    }
}

#pragma mark - private

// 线型
-(void)loadLineCustomLayer:(CGFloat)height width:(CGFloat)width {
    UIBezierPath * bezierPath = [[UIBezierPath alloc]init];
    [bezierPath moveToPoint:CGPointMake(0, height/2)];
    [bezierPath addLineToPoint:CGPointMake(width, height/2)];
    self.path = bezierPath.CGPath;
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeEnd = 0;
    self.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.66].CGColor;
    self.lineWidth = height; // 线宽
    self.lineCap = @"butt";
}

// 圆形进度条
-(void)loadCircleCustomLayer:(CGFloat)height width:(CGFloat)width {
    self.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.66].CGColor;
    self.fillColor = [UIColor clearColor].CGColor;
    CGFloat side = (height > width ? width : height)/2.0;
    self.lineWidth = side;
    self.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((width-side)/2.0, side/2.0, side, side)].CGPath;
    self.strokeEnd = 0;
}

@end
