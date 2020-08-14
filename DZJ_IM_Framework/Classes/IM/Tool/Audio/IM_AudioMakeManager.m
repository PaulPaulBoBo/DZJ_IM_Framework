//
//  IM_AudioMakeManager.m
//  L_Chat
//
//  Created by LiuBo on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_AudioMakeManager.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConvert.h"

static NSString *WAVFileName = @"WAVtemporaryRadio.wav";
static NSString *AMRFileName = @"AMRtemporaryRadio.amr";

@interface IM_AudioMakeManager()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, assign) CGFloat audioTimeLength;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) IM_Timer *speakTimer;

@property (nonatomic, strong) AudioRecorderFinishRecordingBlock audioRecorderFinishRecordingBlock;  //播放完成回调
@property (nonatomic, strong) AudioStartRecordingBlock audioStartRecordingBlock;                    //开始播放回调
@property (nonatomic, strong) AudioRecordingFailBlock audioRecordingFailBlock;                      //播放失败回调
@property (nonatomic, strong) AudioSpeakPowerBlock audioSpeakPowerBlock;                            //音频值测量回调
@property (nonatomic, strong) AudioSpeakTimeBlock audioSpeakTimeBlock;                              //音频录制时长回调

@end

@implementation IM_AudioMakeManager

- (instancetype)init {
    if (self = [super init]) {
        //创建缓存录音文件到Tmp
        [self createTmpFilePath];
    }
    return self;
}

#pragma mark - public

// 开始录音
- (BOOL)startRecording {
    if([self canRecord]) {
        if(!self.isRecording) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            [self.audioRecorder prepareToRecord];
            [self.audioRecorder record];
            
            if ([self.audioRecorder isRecording]) {
                self.isRecording = YES;
                if (self.audioStartRecordingBlock) {
                    self.audioStartRecordingBlock(YES);
                }
            } else {
                if (self.audioStartRecordingBlock) {
                    self.audioStartRecordingBlock(NO);
                }
            }
            [self createPickSpeakPowerTimer];
        }
        return YES;
    } else {
        return NO;
    }
}

// 结束录音
- (void)stopRecording {
    if (!self.isRecording) return;
    [self shutDownTimer];
    [self.audioRecorder stop];
    self.audioRecorder = nil;
}

// 读取最新录音
-(id)readLocalRecording {
    NSString *amrRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:AMRFileName];
    NSData *cacheAudioData = [NSData dataWithContentsOfFile:amrRecordFilePath];
    if(cacheAudioData) {
        return cacheAudioData;
    } else {
        return nil;
    }
}

/// 配置录音回调
-(void)configAudioRecorderFinishRecordingBlock:(AudioRecorderFinishRecordingBlock)audioRecorderFinishRecordingBlock
                      audioStartRecordingBlock:(AudioStartRecordingBlock)audioStartRecordingBlock
                       audioRecordingFailBlock:(AudioRecordingFailBlock)audioRecordingFailBlock
                          audioSpeakPowerBlock:(AudioSpeakPowerBlock)audioSpeakPowerBlock
                           audioSpeakTimeBlock:(AudioSpeakTimeBlock)audioSpeakTimeBlock {
    self.audioRecorderFinishRecordingBlock = audioRecorderFinishRecordingBlock;
    self.audioStartRecordingBlock = audioStartRecordingBlock;
    self.audioRecordingFailBlock = audioRecordingFailBlock;
    self.audioSpeakPowerBlock = audioSpeakPowerBlock;
    self.audioSpeakTimeBlock = audioSpeakTimeBlock;
}

#pragma mark - private

//创建缓存录音文件到Tmp
-(void)createTmpFilePath {
    NSString *wavRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:WAVFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:wavRecordFilePath]) {
        [[NSData data] writeToFile:wavRecordFilePath atomically:YES];
    }
    NSString *amrRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:AMRFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:amrRecordFilePath]) {
        [[NSData data] writeToFile:amrRecordFilePath atomically:YES];
    }
}

// 停止计时器
- (void)shutDownTimer {
    if(_speakTimer) {
        [self.speakTimer stopTimerWithTimerType:(IM_TimerTypeDefault) stopTimerBlock:^{
            self.speakTimer = nil;
        }];
    }
}

// 是否拥有录音权限
- (BOOL)canRecord {
    __block BOOL bCanRecord = NO;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法录音" message:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-麦克风”选项中，允许%@你的手机麦克风", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]] preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        //跳入当前App设置界面,
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                            [[UIApplication sharedApplication] openURL:url]; // iOS 9 的跳转
                        }
                    }];
                    [alertController addAction:doneAction];
                    [[DZJRouter sharedInstance].currentViewController presentViewController:alertController animated:YES completion:nil];
                    
                }
            }];
        }
    }
    
    return bCanRecord;
}

#pragma mark - AVAudioRecorder

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    //暂存录音文件路径
    NSString *wavRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:WAVFileName];
    NSString *amrRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:AMRFileName];
    [VoiceConvert ConvertWavToAmr:wavRecordFilePath amrSavePath:amrRecordFilePath];
    
    //返回amr音频文件Data,用于传输或存储
    NSData *cacheAudioData = [NSData dataWithContentsOfFile:amrRecordFilePath];
    
    //大于最小录音时长时,发送数据
    if(self.audioTimeLength < IM_MIN_RECORDER_TIME) {
        if (self.audioRecordingFailBlock) {
            self.audioRecordingFailBlock(@"录音时长小于 1s");
        }
    } else if (self.audioTimeLength < IM_MAX_RECORDER_TIME) {
        if (self.audioRecorderFinishRecordingBlock) {
            self.audioRecorderFinishRecordingBlock(cacheAudioData, self.audioTimeLength);
        }
    } else {
        // 录音会自动停止
    }
    
    self.isRecording = NO;
}

//音频值测量
- (void)createPickSpeakPowerTimer {
    __weak typeof(self) weakSelf = self;
    self.audioTimeLength = 0;
    [self.speakTimer startTimerWithTimerType:(IM_TimerTypeDefault) timeInterval:0.1 startTimerBlock:^(CGFloat seconds) {
        self.audioTimeLength += 0.1;
        //大于等于60秒停止
        if (self.audioTimeLength >= IM_MAX_RECORDER_TIME) {
            [self stopRecording];
        } else {
            [weakSelf.audioRecorder updateMeters];
            double lowPassResults = pow(10, (0.05 *[weakSelf.audioRecorder averagePowerForChannel:0]));
            if (weakSelf.audioSpeakPowerBlock) {
                weakSelf.audioSpeakPowerBlock(10*lowPassResults);
            }
            if(weakSelf.audioSpeakTimeBlock) {
                weakSelf.audioSpeakTimeBlock(seconds/10);
            }
        }
    }];
}


- (void)dealloc {
    if (self.isRecording) [self.audioRecorder stop];
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - lazy
- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        //暂存录音文件路径
        NSString *wavRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:WAVFileName];
        NSDictionary *recordSetting = @{ AVSampleRateKey         : @8000.0,                      // 采样率 8000/44100/96000
                                         AVFormatIDKey           : @(kAudioFormatLinearPCM),     // 音频格式 wav
                                         AVLinearPCMBitDepthKey  : @16,                          // 采样位数 默认 16
                                         AVNumberOfChannelsKey   : @1,                           // 通道的数目
                                         AVEncoderBitDepthHintKey: @16,                          // 线性音频的位深度8、16、24、32
                                         AVEncoderAudioQualityKey: @(AVAudioQualityHigh)         // 录音的质量
        };
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:wavRecordFilePath] settings:recordSetting error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
    }
    return _audioRecorder;
}

-(IM_Timer *)speakTimer {
    if(_speakTimer == nil) {
        _speakTimer = [[IM_Timer alloc] init];
    }
    return _speakTimer;
}

@end
