//
//  IM_WaveLineView.m
//  DoctorCloud
//
//  Created by dzj on 2020/7/1.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_WaveLineView.h"
#import "IM_WaveLineLayer.h"

@interface IM_WaveLineView()

@property (nonatomic, strong) IM_WaveLineLayer *lineLayerUp;
@property (nonatomic, strong) IM_WaveLineLayer *lineLayerDown;

@end

@implementation IM_WaveLineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self.lineLayerUp loadCustomLayer:frame.size.height width:frame.size.width color:[UIColor whiteColor] isUp:YES];
        [self.layer addSublayer:self.lineLayerUp];
        [self.lineLayerDown loadCustomLayer:frame.size.height width:frame.size.width color:[UIColor whiteColor] isUp:NO];
        [self.layer addSublayer:self.lineLayerDown];
    }
    return self;
}

#pragma mark - public

// 更新音条值
-(void)updateLineValue:(CGFloat)value {
    [self.lineLayerUp updateLayerHeight:value];
    [self.lineLayerDown updateLayerHeight:value];
}

/// 修改音条颜色
/// @param color 颜色
-(void)updateLineColor:(UIColor *)color {
    [self.lineLayerUp updateLineColor:color];
    [self.lineLayerDown updateLineColor:color];
}

#pragma mark - lzay

-(IM_WaveLineLayer *)lineLayerUp{
    if(_lineLayerUp == nil) {
        _lineLayerUp = [[IM_WaveLineLayer alloc] init];
        _lineLayerUp.frame = self.bounds;
    }
    return _lineLayerUp;
}

-(IM_WaveLineLayer *)lineLayerDown{
    if(_lineLayerDown == nil) {
        _lineLayerDown = [[IM_WaveLineLayer alloc] init];
        _lineLayerDown.frame = self.bounds;
    }
    return _lineLayerDown;
}

@end
