//
//  IM_ProcessView.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/28.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_ProcessView.h"

@interface IM_ProcessView()

@property (nonatomic, strong) UIView *rotationView;
@property (nonatomic, strong) IM_ProcessLayer *processLayer;

@property (nonatomic, strong) UIColor *processBgColor;
@property (nonatomic, assign) IM_ProcessType type;

@property (nonatomic, strong) UILabel *percentLabel;

@end

static CGFloat ProcessLayerSide = 40;
static BOOL isShowPercent = NO;

@implementation IM_ProcessView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.rotationView];
    }
    return self;
}

#pragma mark - public

// 创建进度条view
-(void)loadProcessViewType:(IM_ProcessType)type {
    self.type = type;
    CGFloat height = [self getSizeWithType:self.type].height;
    CGFloat width = [self getSizeWithType:self.type].width;
    self.rotationView.frame = CGRectMake((self.width - width)/2.0, (self.height - height)/2.0, width, height);
    self.backgroundColor = self.processBgColor;
    if(self.processLayer.superlayer == nil) {
        self.processLayer.frame = CGRectMake(0, 0, width, height);
        [self.processLayer loadCustomLayer:height width:width type:type];
        [self.rotationView.layer addSublayer:self.processLayer];
    }
    
    if(type == IM_ProcessTypeCircle) {
        isShowPercent = YES;
        self.rotationView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    } else {
        isShowPercent = NO;
        self.rotationView.transform = CGAffineTransformMakeRotation(0);
    }
}

// 更新进度条
-(void)updateProcessValue:(CGFloat)processValue {
    CGFloat transValue = [[NSString stringWithFormat:@"%.3lf", processValue] floatValue];
    if(self.percentLabel.superview == nil) {
        [self addSubview:self.percentLabel];
        [self.percentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self bringSubviewToFront:self.percentLabel];
    }
    if(isShowPercent) {
        self.percentLabel.text = [NSString stringWithFormat:@"%.1lf%@", processValue*100, @"%"];
    } else {
        self.percentLabel.text = @"";
    }
    [self.processLayer updateProcessValue:transValue];
}

// 移除进度条
-(void)removeProcessView {
    if(self.processLayer.superlayer != nil) {
        [self.processLayer removeFromSuperlayer];
        self.processLayer = nil;
    }
}

#pragma mark - private

-(CGSize)getSizeWithType:(IM_ProcessType)type {
    CGFloat height = self.height;
    CGFloat width = self.width;
    if(type == IM_ProcessTypeCircle) {
        height = ProcessLayerSide;
        width = ProcessLayerSide;
    }
    return CGSizeMake(width, height);
}

#pragma mark - lazy

-(UIView *)rotationView {
    if(_rotationView == nil) {
        _rotationView = [[UIView alloc] init];
        _rotationView.backgroundColor = [UIColor clearColor];
    }
    return _rotationView;
}

-(IM_ProcessLayer *)processLayer {
    if(_processLayer == nil) {
        _processLayer = [[IM_ProcessLayer alloc] init];
    }
    return _processLayer;
}

-(UIColor *)processBgColor {
    if(_processBgColor == nil) {
        _processBgColor = [[UIColor blackColor] colorWithAlphaComponent:0.33];
    }
    return _processBgColor;
}

-(UILabel *)percentLabel {
    if(_percentLabel == nil) {
        _percentLabel = [[UILabel alloc] init];
        _percentLabel.font = [UIFont systemFontOfSize:13];
        _percentLabel.textColor = [UIColor whiteColor];
        _percentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _percentLabel;
}
@end
