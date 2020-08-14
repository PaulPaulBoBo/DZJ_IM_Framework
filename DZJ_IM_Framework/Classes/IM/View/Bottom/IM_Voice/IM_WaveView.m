//
//  IM_WaveView.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_WaveView.h"
#import "IM_WaveLineView.h"
#import "IM_Timer.h"
#import "IM_WaveSingleView.h"

@interface IM_WaveView()

@property (nonatomic, strong) UIView *linesBgView; // 顶部音条承载视图
@property (nonatomic, strong) UIView *voiceBgView; // 底部语音波浪动画承载视图
@property (nonatomic, strong) IM_WaveSingleView *waveFront; // 前波浪
@property (nonatomic, strong) IM_WaveSingleView *waveBehand; // 后波浪

@property (nonatomic, assign) NSInteger lineCount; // 音条个数
@property (nonatomic, assign) WaveType waveType; // 波动类型
@property (nonatomic, assign) CGFloat waveDuration; // 波动动画时长
@property (nonatomic, assign) WaveLineType waveLineType; // 音条类型

@property (nonatomic, strong) IM_Timer *timer;

@end

static NSInteger DefaultLineCount = 13; // 默认音条个数
static NSInteger DefaultWaveType = WaveTypeUpAndDown; // 默认波动类型
static NSInteger DefaultWaveDuration = 1; // 默认波动动画时长
static NSInteger DefaultWaveLineType = WaveLineTypeRound; // 默认音条类型
static CGFloat LineDefaultWidth = 4; // 音条宽度

static CGFloat DefaultAmplitude = 5; // 默认振幅
static CGFloat DefaultFirstPhase = M_PI; // 默认初相
static CGFloat DefaultOffset = 0; // 默认偏距
static CGFloat DefaultSpeed = 2; // 默认移动速度

@implementation IM_WaveView

#pragma mark - public

// 配置音条参数
-(void)configLineCount:(NSInteger)lineCount
              waveType:(WaveType)waveType
          waveDuration:(CGFloat)waveDuration
          waveLineType:(WaveLineType)waveLineType {
    if(lineCount >= 0 && lineCount <= 20) {
        self.lineCount = lineCount;
    }
    if(waveType == WaveTypeUp ||
       waveType == WaveTypeUpAndDown ||
       waveType == WaveTypeDown) {
        self.waveType = waveType;
    }
    if(waveDuration >= 0.1 && waveDuration <= 5) {
        self.waveDuration = waveDuration;
    }
    if(waveLineType == WaveLineTypeRect ||
       waveLineType == WaveLineTypeRound) {
        self.waveLineType = waveLineType;
    }
}

// 以动画形式展示初始化的音条
-(void)showInitWaveWithAnimationType:(WaveAnimationType)waveAnimationType {
    [self loadCustomView];
    NSArray *arr = @[@0.1, @0.2, @0.45, @0.28];
    for (int i = 0; i < self.linesBgView.subviews.count; i++) {
        if([[self.linesBgView.subviews objectAtIndex:i] isKindOfClass:[IM_WaveLineView class]]) {
            IM_WaveLineView *lineView = [self.linesBgView.subviews objectAtIndex:i];
            NSNumber *num = arr[(i%4)];
            [lineView updateLineValue:num.floatValue*1.5];
        }
    }
}


static NSInteger lineIndex = 0;
// 开始音条颜色变化动画
-(void)startShowColorChangeAnimation {
    @weakify(self)
    CGFloat cycleTime = 1;
    CGFloat singleRefreshTime = cycleTime/(self.linesBgView.subviews.count > 0?self.linesBgView.subviews.count:DefaultLineCount);
    [self.timer startTimerWithTimerType:(IM_TimerTypeGCD) timeInterval:singleRefreshTime startTimerBlock:^(CGFloat seconds) {
        @strongify(self)
        @autoreleasepool {
            if(lineIndex >= self.linesBgView.subviews.count) {
                lineIndex = 0;
            }
            for (NSInteger i = 0; i < self.linesBgView.subviews.count; i++) {
                @autoreleasepool {
                    if([[self.linesBgView.subviews objectAtIndex:i] isKindOfClass:[IM_WaveLineView class]]) {
                        IM_WaveLineView *lineView = [self.linesBgView.subviews objectAtIndex:i];
                        if(i <= lineIndex) {
                            [lineView updateLineColor:[UIColor colorWithHexString:@"#08AEAB"]];
                        } else {
                            [lineView updateLineColor:[UIColor whiteColor]];
                        }
                    }
                }
            }
            lineIndex++;
        }
    }];
}

// 结束音条颜色变化动画
-(void)stopShowColorChangeAnimation {
    lineIndex = 0;
    if(_timer) {
        [self.timer stopTimerWithTimerType:(IM_TimerTypeGCD) stopTimerBlock:^{
            self.timer = nil;
        }];
    }
}

// 将最新的音量刷新到界面
-(void)updateVoice:(CGFloat)voice {
    DLog(@"voice:%lf", voice);
    if(voice > 1) {
        voice = 1;
    }
    CGFloat per = 1 - (voice/3.0 + 0.2);
    self.waveBehand.offset = self.voiceBgView.height*per;
    self.waveFront.offset = self.voiceBgView.height*per;
}

#pragma mark - private

// 加载数据
-(void)loadDefaultData {
    self.lineCount = DefaultLineCount;
    self.waveType = DefaultWaveType;
    self.waveDuration = DefaultWaveDuration;
    self.waveLineType = DefaultWaveLineType;
}

// 创建视图
-(void)loadCustomView {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 4;
    
    // 白色话筒视图
    [self addSubview:self.voiceBehindImageView];
    [self.voiceBehindImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 音条动画视图
    [self addSubview:self.linesBgView];
    [self.linesBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(58);
        make.right.equalTo(self).offset(-58);
        make.top.equalTo(self).offset(22);
        make.height.equalTo(@30);
    }];
    
    // 话筒动画视图
    [self addSubview:self.voiceBgView];
    [self.voiceBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.linesBgView.mas_bottom);
    }];
    
    // 标题
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.voiceBgView.mas_bottom);
    }];
    
    // 提示语
    [self addSubview:self.cancelLabel];
    [self.cancelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
        make.bottom.equalTo(self).offset(-21);
    }];
    
    // 透明话筒视图
    [self addSubview:self.voiceFrontImageView];
    [self.voiceFrontImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self bringSubviewToFront:self.titleLabel];
    [self bringSubviewToFront:self.cancelLabel];
    [self bringSubviewToFront:self.linesBgView];
    
    [self.superview layoutIfNeeded];
    
    [self loadVoiceWave];
    [self loadVoiceLines:self.lineCount toView:self.linesBgView];
    
    [self bringSubviewToFront:self.linesBgView];
}

// 加载音条
-(void)loadVoiceLines:(NSInteger)lines toView:(UIView *)toView {
    [toView removeAllSubviews];
    UIView *lastView = nil;
    CGFloat space = (toView.width - lines*LineDefaultWidth)/(lines+1);
    for (int i = 0; i < lines; i++) {
        UIView *lineView = [self createSingleLine];
        lastView = [self addLinesToView:lineView lastView:lastView toView:toView space:space];
    }
    if(lastView != nil) {
        [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(toView).offset(-(space));
        }];
    }
}

// 将音条添加到承载视图上
-(UIView *)addLinesToView:(UIView *)lineView lastView:(UIView *)lastView toView:(UIView *)toView space:(CGFloat)space {
    [toView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(lastView == nil) {
            make.left.equalTo(toView).offset(space);
        } else {
            make.left.equalTo(lastView.mas_right).offset(space);
        }
        make.top.equalTo(toView);
        make.bottom.equalTo(toView);
        make.width.equalTo(@(LineDefaultWidth));
    }];
    return lineView;
}

// 创建一个音条
-(IM_WaveLineView *)createSingleLine {
    IM_WaveLineView *line = [[IM_WaveLineView alloc] initWithFrame:CGRectMake(0, 0, LineDefaultWidth, self.linesBgView.height)];
    line.clipsToBounds = YES;
    line.layer.cornerRadius = 1;
    return line;
}

// 创建波浪视图
-(void)loadVoiceWave {
    [self.voiceBgView addSubview:self.waveBehand];
    [self.waveBehand mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.voiceBgView);
        make.top.equalTo(self.voiceBgView);
    }];
    
    [self.voiceBgView addSubview:self.waveFront];
    [self.waveFront mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.voiceBgView);
        make.top.equalTo(self.voiceBgView);
    }];
}

#pragma mark - lazy

-(UIView *)linesBgView {
    if(_linesBgView == nil) {
        _linesBgView = [[UIView alloc] init];
        _linesBgView.backgroundColor = [UIColor clearColor];
    }
    return _linesBgView;
}

-(UIView *)voiceBgView {
    if(_voiceBgView == nil) {
        _voiceBgView = [[UIView alloc] init];
        _voiceBgView.clipsToBounds = YES;
        _voiceBgView.backgroundColor = [UIColor clearColor];
    }
    return _voiceBgView;
}

-(IM_Timer *)timer {
    if(_timer == nil) {
        _timer = [[IM_Timer alloc] init];
    }
    return _timer;
}

-(IM_WaveSingleView *)waveFront {
    if(_waveFront == nil) {
        _waveFront = [[IM_WaveSingleView alloc] initWithFrame:CGRectMake(0, 0, self.voiceBgView.width, self.voiceBgView.height)];
        _waveFront.backgroundColor = [UIColor clearColor];
        _waveFront.amplitude = DefaultAmplitude;
        _waveFront.angularVelocity = (M_PI*2)/self.voiceBgView.width;
        _waveFront.firstPhase = DefaultFirstPhase;
        _waveFront.offset = DefaultOffset;
        _waveFront.speed = DefaultSpeed;
        _waveFront.waveColor = [[UIColor colorWithHexString:@"#08AEAB"] colorWithAlphaComponent:0.4];
    }
    return _waveFront;
}

-(IM_WaveSingleView *)waveBehand {
    if(_waveBehand == nil) {
        _waveBehand = [[IM_WaveSingleView alloc] initWithFrame:CGRectMake(0, 0, self.voiceBgView.width, self.voiceBgView.height)];
        _waveBehand.backgroundColor = [UIColor clearColor];
        _waveBehand.amplitude = DefaultAmplitude;
        _waveBehand.angularVelocity = (M_PI*2)/self.voiceBgView.width;
        _waveBehand.firstPhase = DefaultFirstPhase + M_PI/2.0;
        _waveBehand.offset = DefaultOffset;
        _waveBehand.speed = DefaultSpeed+1;
        _waveBehand.waveColor = [[UIColor colorWithHexString:@"#08AEAB"] colorWithAlphaComponent:0.5];
    }
    return _waveBehand;
}

-(UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:(UIFontWeightBold)];
    }
    return _titleLabel;
}

-(UILabel *)cancelLabel {
    if(_cancelLabel == nil) {
        _cancelLabel = [[UILabel alloc] init];
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
        _cancelLabel.textColor = [UIColor whiteColor];
        _cancelLabel.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightBold)];
        _cancelLabel.text = @"上划取消或松开发送";
    }
    return _cancelLabel;
}


-(UIImageView *)voiceBehindImageView {
    if(_voiceBehindImageView == nil) {
        _voiceBehindImageView = [[UIImageView alloc] init];
        _voiceBehindImageView.image = [UIImage imageNamed:@"im_show_white_voice"];
    }
    return _voiceBehindImageView;
}

-(UIImageView *)voiceFrontImageView {
    if(_voiceFrontImageView == nil) {
        _voiceFrontImageView = [[UIImageView alloc] init];
        _voiceFrontImageView.image = [UIImage imageNamed:@"im_show_alpha_voice"];
    }
    return _voiceFrontImageView;
}

@end
