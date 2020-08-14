//
//  IM_VoiceView.m
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_VoiceView.h"
#import "IM_VoiceShowMenuView.h" // 语音弹出菜单
#import "IM_AudioMakeManager.h" // 录音管理器

@interface IM_VoiceView()

@property (nonatomic, strong) StartVoice startVoice;
@property (nonatomic, strong) CancelVoice cancelVoice;
@property (nonatomic, strong) FinishVoice finishVoice;

@property (nonatomic, strong) IM_VoiceShowMenuView *voiceShowMenuView;
@property (nonatomic, strong) IM_AudioMakeManager *audioMakeManager;

@end

static BOOL CanSend = YES;

@implementation IM_VoiceView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        [self loadCustomView];
    }
    return self;
}

#pragma mark - public
// 配置语音状态回调
-(void)configStartVoice:(StartVoice)startVoice
            cancelVoice:(CancelVoice)cancelVoice
            finishVoice:(FinishVoice)finishVoice {
    self.startVoice = startVoice;
    self.cancelVoice = cancelVoice;
    self.finishVoice = finishVoice;
}

#pragma mark - private

-(void)loadCustomView {
    [self addSubview:self.pressBtn];
    [self.pressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.bottom.equalTo(self);
    }];
}

// 按下事件
-(void)touchDownAction:(UIButton *)sender {
    if(self.startVoice) {
        if([self.audioMakeManager canRecord]) {
            [self startMakeAudio];
            [self showVoiceShowMenuView];
            self.startVoice();
        }
    }
}

// 按钮内松开事件
-(void)touchUpInsideAction:(UIButton *)sender {
    if([self.audioMakeManager canRecord]) {
        [self hideVoiceShowMenuView];
        if(self.audioMakeManager.isRecording) {
            [self stopMakeAudio];
        } else {
            NSData *voiceData = [self.audioMakeManager readLocalRecording];
            if(voiceData) {
                if(self.finishVoice) {
                    self.finishVoice(voiceData, IM_MAX_RECORDER_TIME);
                }
            }
        }
    }
}

// 按钮外松开事件
-(void)touchUpOutsideAction:(UIButton *)sender {
    [self hideVoiceShowMenuView];
    if(self.cancelVoice) {
        [self stopMakeAudio];
        self.cancelVoice();
    }
}

// 展示语音菜单视图
-(void)showVoiceShowMenuView {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.voiceShowMenuView showVoiceMenuView];
    });
}

// 隐藏语音菜单视图
-(void)hideVoiceShowMenuView {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.voiceShowMenuView hideVoiceMenuView];
    });
}

// 手指移出按钮事件
-(void)touchDrugOutSideAction:(UIButton *)sender event:(UIEvent *)event {
    UITouch *touch = [event.allTouches anyObject];
    CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    [self.voiceShowMenuView updatePanPosition:point];
    if(point.y >= [UIScreen mainScreen].bounds.size.height - 100) {
        CanSend = YES;
    } else {
        CanSend = NO;
    }
}

// 手指移入按钮事件
-(void)touchDrugInSideAction:(UIButton *)sender event:(UIEvent *)event {
    UITouch *touch = [event.allTouches anyObject];
    CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    [self.voiceShowMenuView updatePanPosition:point];
    if(point.y >= [UIScreen mainScreen].bounds.size.height - 100) {
        CanSend = YES;
    } else {
        CanSend = NO;
    }
}

// 开始录音
-(BOOL)startMakeAudio {
    return [self.audioMakeManager startRecording];
}

// 结束录音
-(void)stopMakeAudio {
    [self.audioMakeManager stopRecording];
}

#pragma mark - lazy

-(UIButton *)pressBtn {
    if(_pressBtn == nil) {
        _pressBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_pressBtn setTitle:@"按住说话" forState:(UIControlStateNormal)];
        [_pressBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_pressBtn setBackgroundColor:[UIColor whiteColor]];
        [_pressBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        [_pressBtn addTarget:self action:@selector(touchDownAction:) forControlEvents:(UIControlEventTouchDown)];
        [_pressBtn addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_pressBtn addTarget:self action:@selector(touchUpOutsideAction:) forControlEvents:(UIControlEventTouchUpOutside)];
        [_pressBtn addTarget:self action:@selector(touchDrugOutSideAction:event:) forControlEvents:(UIControlEventTouchDragOutside)];
        [_pressBtn addTarget:self action:@selector(touchDrugInSideAction:event:) forControlEvents:(UIControlEventTouchDragInside)];
    }
    return _pressBtn;
}

-(IM_VoiceShowMenuView *)voiceShowMenuView {
    if(_voiceShowMenuView == nil) {
        _voiceShowMenuView = [[IM_VoiceShowMenuView alloc] init];
        [_voiceShowMenuView configCanSendRect:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, [UIScreen mainScreen].bounds.size.width, 100)];
    }
    return _voiceShowMenuView;
}

-(IM_AudioMakeManager *)audioMakeManager {
    if(_audioMakeManager == nil) {
        _audioMakeManager = [[IM_AudioMakeManager alloc] init];
        [_audioMakeManager configAudioRecorderFinishRecordingBlock:^(NSData *data, CGFloat audioTimeLength) {
            // 录音完成回调
            if(CanSend) {
                if(self.finishVoice) {
                    self.finishVoice(data, audioTimeLength);
                }
            }
        } audioStartRecordingBlock:^(BOOL isRecording) {
            // 开始录音回调
        } audioRecordingFailBlock:^(NSString *reason) {
            // 录音失败回调
            [DZJToast toast:clearNilStr(reason)];
        } audioSpeakPowerBlock:^(float power) {
            // 录音过程中的音量回调
            [self.voiceShowMenuView updateVoice:power];
        } audioSpeakTimeBlock:^(CGFloat seconds) {
            [self.voiceShowMenuView updateVoiceTime:seconds];
        }];
    }
    return _audioMakeManager;
}

@end
