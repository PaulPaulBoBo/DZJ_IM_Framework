//
//  IM_VoiceShowMenuView.m
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_VoiceShowMenuView.h"
#import "IM_WaveView.h"
#import "IM_Timer.h"

@interface IM_VoiceShowMenuView()

@property (nonatomic, assign) CGRect cancelRect;
@property (nonatomic, strong) UIView *sendRectView;
@property (nonatomic, strong) IM_WaveView *waveView;
@property (nonatomic, strong) CAShapeLayer *roundLayer;
@property (nonatomic, strong) UIImageView *roundImageView;


@end

static CGFloat MenuHeight = 210;
static CGFloat MenuWidth = 210;
static NSInteger WaringSecond = 10;

@implementation IM_VoiceShowMenuView

#pragma mark - public

// 展示正在录音菜单视图
-(void)showVoiceMenuView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window);
    }];
    [self loadCustomView];
    [UIView animateWithDuration:0.01 animations:^{
        self.alpha = 1;
    }];
    @weakify(self)
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        [self hideVoiceMenuView];
    }]];
}

// 隐藏正在录音菜单视图
-(void)hideVoiceMenuView {
    [UIView animateWithDuration:0.01 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.waveView stopShowColorChangeAnimation];
        [self.waveView.titleLabel removeFromSuperview];
        [self.waveView.cancelLabel removeFromSuperview];
        [self.waveView removeFromSuperview];
        [self removeFromSuperview];
        _waveView = nil;
    }];
}

// 更新手指在屏幕中拖动的坐标
-(void)updatePanPosition:(CGPoint)point {
    if(point.y >= 0 &&
       point.y <= self.cancelRect.origin.y + self.cancelRect.size.height) {
        self.roundLayer.fillColor = [[UIColor colorWithHexString:@"0x666666"] colorWithAlphaComponent:0.66].CGColor;
    } else {
        self.roundLayer.fillColor = [[UIColor colorWithHexString:@"0xffffff"] colorWithAlphaComponent:0.66].CGColor;
    }
}

/// 配置滑动过程中处于发送状态的区域
/// @param rect 发送状态的区域
-(void)configCanSendRect:(CGRect)rect {
    self.cancelRect = CGRectMake(0, 0, rect.size.width, [UIScreen mainScreen].bounds.size.height - rect.size.height - HOME_INDICATOR_HEIGHT);
    if(self.sendRectView.superview == nil) {
        [self addSubview:self.sendRectView];
    }
    [self.sendRectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-HOME_INDICATOR_HEIGHT);
        make.height.equalTo(@(rect.size.height+10));
    }];
    
    [self layoutIfNeeded];
    
    if(self.roundLayer.superlayer == nil) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2.0, ScreenWidth+40) radius:ScreenWidth+40 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        self.sendRectView.layer.frame = CGRectMake(-20, 0, ScreenWidth+40, ScreenWidth+40);
        self.roundLayer.path = path.CGPath;
        self.roundLayer.strokeEnd = 0;
        self.roundLayer.fillColor = [[UIColor colorWithHexString:@"0xffffff"] colorWithAlphaComponent:0.66].CGColor;
        self.roundLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.66].CGColor;
        self.roundLayer.lineWidth = self.sendRectView.height;
        [self.sendRectView.layer addSublayer:self.roundLayer];
    }
    
    if(self.roundImageView.superview == nil) {
        [self.sendRectView addSubview:self.roundImageView];
        [self.roundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_sendRectView.mas_centerX);
            make.bottom.equalTo(_sendRectView.mas_bottom).offset(-5);
            make.width.height.equalTo(@48);
        }];
        [self.sendRectView bringSubviewToFront:self.roundImageView];
    }
}

// 刷新声音波动画
-(void)updateVoice:(CGFloat)voice {
    [self.waveView updateVoice:voice];
}

// 刷新录音时长
-(void)updateVoiceTime:(CGFloat)seconds {
    if(ceilf(seconds) > (IM_MAX_RECORDER_TIME-WaringSecond) && ceilf(seconds) < IM_MAX_RECORDER_TIME) {
        self.waveView.titleLabel.text = [NSString stringWithFormat:@"%.0lfs 后停止录制", WaringSecond-(seconds-(IM_MAX_RECORDER_TIME-WaringSecond))];
    } else if(ceilf(seconds) >= IM_MAX_RECORDER_TIME) {
        self.waveView.titleLabel.text = @"已达到60s，无法继续录制";
    } else {
        self.waveView.titleLabel.text = [NSString stringWithFormat:@"%.0lf s", seconds];
    }
}

#pragma mark - private

-(void)loadCustomView {
    
    self.alpha = 0;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
    
    if(self.waveView.titleLabel.superview != nil) {
        [self.waveView.titleLabel removeFromSuperview];
    }
    if(self.waveView.cancelLabel.superview != nil) {
        [self.waveView.cancelLabel removeFromSuperview];
    }
    
    // 动画视图
    [self addSubview:self.waveView];
    [self.waveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.width.equalTo(@(MenuWidth));
        make.height.equalTo(@(MenuHeight));
    }];
    
    [self.superview layoutIfNeeded];
    [self.waveView showInitWaveWithAnimationType:(WaveAnimationTypeAlpa)];
}

#pragma mark - lazy

-(UIView *)sendRectView {
    if(_sendRectView == nil) {
        _sendRectView = [[UIView alloc] init];
        _sendRectView.clipsToBounds = YES;
    }
    return _sendRectView;
}

-(IM_WaveView *)waveView {
    if(_waveView == nil) {
        _waveView = [[IM_WaveView alloc] init];
        [_waveView configLineCount:13 waveType:(WaveTypeUpAndDown) waveDuration:1.5 waveLineType:(WaveLineTypeRound)];
        [_waveView startShowColorChangeAnimation];
    }
    return _waveView;
}

-(CAShapeLayer *)roundLayer {
    if(_roundLayer == nil) {
        _roundLayer = [[CAShapeLayer alloc] init];
    }
    return _roundLayer;
}

-(UIImageView *)roundImageView {
    if(_roundImageView == nil) {
        _roundImageView = [[UIImageView alloc] init];
        _roundImageView.image = [UIImage imageNamed:@"im_voice_icon"];
    }
    return _roundImageView;
}


@end
