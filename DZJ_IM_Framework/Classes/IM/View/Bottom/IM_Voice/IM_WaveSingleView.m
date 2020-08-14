//
//  IM_WaveSingleView.m
//  DoctorCloud
//
//  Created by dzj on 2020/7/9.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_WaveSingleView.h"

@interface IM_WaveSingleView()

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation IM_WaveSingleView

#pragma mark - life

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.amplitude = self.bounds.size.height * 0.1;
        self.angularVelocity = M_PI * 2 / self.bounds.size.width;
        self.offset = self.bounds.size.height * 0.5;
        self.firstPhase = 0;
        self.speed = 5;
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplay)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

#pragma mark - drawRect

- (void)drawRect:(CGRect)rect {
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    //初始化运动路径
    CGMutablePathRef path = CGPathCreateMutable();
    //设置起始位置
    CGPathMoveToPoint(path, nil, 0, self.bounds.size.height);
    //正弦曲线公式为：y=Asin(ωx+φ)+k;
    for (CGFloat x = 0.0f; x <= self.bounds.size.width; x++) {
        CGFloat y = self.amplitude * sinf(self.angularVelocity * x + self.firstPhase) + self.offset;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    CGPathAddLineToPoint(path, nil, self.bounds.size.width, self.bounds.size.height);
    CGPathCloseSubpath(path);
    //绘制曲线
    CGContextSetFillColorWithColor(cxt, self.waveColor.CGColor);
    CGContextSetLineWidth(cxt, 0.5);
    CGContextAddPath(cxt, path);
    CGContextFillPath(cxt);
    CGPathRelease(path);
}

#pragma mark - private

- (void)handleDisplay {
    if (!self.isHidden) {
        self.firstPhase -= self.speed * self.angularVelocity;
        [self setNeedsDisplay];
    }
}

@end
