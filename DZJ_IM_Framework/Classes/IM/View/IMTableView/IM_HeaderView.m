//
//  IM_HeaderView.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/16.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_HeaderView.h"

@interface IM_HeaderView()

@property (nonatomic, strong) UIImageView *stateImageView; // 加载图片
@property (nonatomic, strong) UILabel *stateLabel; // 加载文字
@property (nonatomic, assign) BOOL isAnimationing; // 当前是否正在动画
@property (nonatomic, assign) IM_HeaderViewType type; // 当前的类型

@end

static CGFloat StateImageSide = 34;
static NSString *WaitStr = @"下拉可获取更多消息";
static NSString *RefreshingStr = @"正在获取...";
static NSString *EndRefreshStr = @"获取完成";
static NSString *NoMoreStr = @"没有更多了";

@implementation IM_HeaderView

#pragma mark - public

// 刷新头视图状态
-(void)refreshState:(IM_HeaderViewType)type {
    self.type = type;
    switch (type) {
        case IM_HeaderViewTypeWaiting: {
            [self transToWait];
        } break;
        case IM_HeaderViewTypeRefreshing: {
            [self transToRefreshing];
        } break;
        case IM_HeaderViewTypeEndRefresh: {
            [self transToEndRefresh];
        } break;
        case IM_HeaderViewTypeNoMore: {
            [self transToNoMore];
        } break;
        default: {
            [self transToWait];
        } break;
    }
}

// 旋转状态图片角度
-(void)rotatePersent:(CGFloat)percent {
    self.stateImageView.transform = CGAffineTransformMakeRotation(percent*M_PI*2);
}

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadCustomView];
    }
    return self;
}

#pragma mark - private

-(void)loadCustomView {
    [self addSubview:self.stateImageView];
    [self.stateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self);
        make.bottom.lessThanOrEqualTo(self);
        make.height.equalTo(@(StateImageSide));
        make.width.equalTo(@(StateImageSide));
        make.left.equalTo(self).offset(100);
    }];
    
    [self addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.left.equalTo(self.stateImageView.mas_right);
        make.centerX.equalTo(self.mas_centerX);
    }];
}

-(void)transToWait {
    [self stopLoadingAnimate];
    self.stateLabel.text = WaitStr;
}

-(void)transToRefreshing {
    [self startLoadingAnimate];
    self.stateLabel.text = RefreshingStr;
}

-(void)transToEndRefresh {
    [self stopLoadingAnimate];
    self.stateLabel.text = EndRefreshStr;
}

-(void)transToNoMore {
    [self stopLoadingAnimate];
    self.stateLabel.text = NoMoreStr;
}

-(void)startLoadingAnimate {
    self.isAnimationing = YES;
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.stateImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stopLoadingAnimate {
    self.isAnimationing = NO;
    [self.stateImageView.layer removeAllAnimations];
}

#pragma mark - lazy

-(UIImageView *)stateImageView {
    if(_stateImageView == nil) {
        _stateImageView = [[UIImageView alloc] init];
        _stateImageView.image = [UIImage imageNamed:@"im_loading"];
    }
    return _stateImageView;
}

-(UILabel *)stateLabel {
    if(_stateLabel == nil) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.text = WaitStr;
        _stateLabel.textColor = [UIColor grayColor];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.font = [UIFont systemFontOfSize:13];
        _stateLabel.numberOfLines = 0;
    }
    return _stateLabel;
}

@end
