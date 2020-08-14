//
//  IM_AudioPlayManager.m
//  L_Chat
//
//  Created by LiuBo on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_AudioPlayManager.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConvert.h"
#import "IM_Timer.h"

@interface IM_AudioPlayManager()<AVAudioPlayerDelegate>
{
    BOOL isPlaying;
}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, copy) StartPlayingBlock startPlayingBlock; // 开始播放回调
@property (nonatomic, copy) PlayCompleteBlock playCompleteBlock; // 播放完成回调
@property (nonatomic, strong) PlayingProcessBlock playingProcessBlock; // 播放进度回调

@property (nonatomic, strong) IM_Timer *processTimer; // 播放进度计时器

@end

static NSString *WAVFileName = @"WAVtemporaryRadio.wav";
static NSString *AMRFileName = @"AMRtemporaryRadio.amr";

@implementation IM_AudioPlayManager

static IM_AudioPlayManager *mannager = nil;
+(instancetype)shareInstance {
    if(mannager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mannager = [[IM_AudioPlayManager alloc] init];
        });
    }
    return mannager;
}

#pragma mark - life

- (instancetype)init {
    if (self) {
        [self addNotification];
        [self createTmpFilePath];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark - public

// 播放data格式录音
- (void)startPlayWithData:(NSData *)data {
    // 如果已有正在播放的录音 停止
    if (isPlaying) {
        [self stopPlaying];
    }
    
    // 确保tmp文件及目录存在
    [self createTmpFilePath];
    
    //打开红外传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    // 默认使用扬声器播放
    [self changePlayerToSpeaker];
    
    // 检查输出设备
    [self checkPlayDevice];
    
    // 格式转换 amr->wav
    NSData *wavData = [self transFormAMRToWAV:data];
    
    // 开始播放
    [self startToPlay:wavData];
}

// 配置播放状态回调
-(void)configStartPlayingBlock:(StartPlayingBlock)startPlayingBlock
             playCompleteBlock:(PlayCompleteBlock)playCompleteBlock
           playingProcessBlock:(PlayingProcessBlock)playingProcessBlock {
    self.startPlayingBlock = startPlayingBlock;
    self.playCompleteBlock = playCompleteBlock;
    self.playingProcessBlock = playingProcessBlock;
}

/// 当前是否正在播放语音
-(BOOL)isPlayingAudio {
    return isPlaying;
}

#pragma mark - delegate

// 录音播放结束代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [self stopPlaying];
    }
}

// 录音播放失败代理方法
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
    NSLog(@"error：%@", [error localizedDescription]);
    [self stopPlaying];
}

// 录音播放被打断代理方法
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    isPlaying = NO;
    [player stop];
}

#pragma mark - notification method

// 播放过程中出现切换设备的操作通知处理
-(void)routeChange:(NSNotification *)noti {
    [self rePlayVoice];
}

// 电话、闹钟等事件中断通知
-(void)interruption:(NSNotification *)noti {
    [self stopPlaying];
}

// 根据红外检测选择播放设备 耳机 外放 听筒
- (void)proximityStateDidChange {
    [self checkPlayDevice];
}

#pragma mark - private

// 添加事件监听
-(void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:(AVAudioSessionRouteChangeNotification) object:nil]; // 切换播放设备
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:(AVAudioSessionInterruptionNotification) object:nil]; // 电话或其他突发事件打断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateDidChange) name:UIDeviceProximityStateDidChangeNotification object:nil]; // 音量变化
}

// 启动播放器播放音频
-(void)startToPlay:(NSData *)data {
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
    self.audioPlayer.meteringEnabled = YES;
    self.audioPlayer.delegate = self;
    //获取系统的声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat currentVol = audioSession.outputVolume;
    //设置播放器声音
    self.audioPlayer.volume = currentVol;
    self.audioPlayer.rate = 1.0;
    [self.audioPlayer prepareToPlay];
    
    if(isPlaying) {
        [self stopPlaying];
    }
    
    isPlaying = YES;
    [self.audioPlayer play];
    if (self.startPlayingBlock) {
        @weakify(self)
        [self.processTimer startTimerWithTimerType:(IM_TimerTypeGCD) timeInterval:0.1 startTimerBlock:^(CGFloat seconds) {
            @strongify(self)
            if(self.playingProcessBlock) {
                DLog(@"%f", self.audioPlayer.currentTime/self.audioPlayer.duration);
                self.playingProcessBlock(self.audioPlayer.currentTime/self.audioPlayer.duration);
            }
        }];
        self.startPlayingBlock(NO);
    }
}

// 格式转化 arm->wav
-(NSData *)transFormAMRToWAV:(NSData *)amrData {
    NSString *wavRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:WAVFileName]; // wav缓存文件目录
    NSString *amrRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:AMRFileName]; // amr缓存文件目录
    if ([[NSFileManager defaultManager] fileExistsAtPath:amrRecordFilePath]) {
        [amrData writeToFile:amrRecordFilePath atomically:YES];
    } else {
        if (self.playCompleteBlock) {
            self.playCompleteBlock(YES);
        }
    }
    [VoiceConvert ConvertAmrToWav:amrRecordFilePath wavSavePath:wavRecordFilePath];
    NSData *wavData = [NSData dataWithContentsOfFile:wavRecordFilePath];
    return wavData;
}

// 停止播放录音
- (void)stopPlaying {
    //关闭红外传感器
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    });
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    isPlaying = NO;
    if (self.playCompleteBlock) {
        if(_processTimer) {
            [self.processTimer stopTimerWithTimerType:(IM_TimerTypeGCD) stopTimerBlock:^{
                self.processTimer = nil;
            }];
        }
        self.playCompleteBlock(NO);
    }
}

// 重新从头播放当前正在播放的录音
-(void)rePlayVoice {
    if(isPlaying) {
        [self.audioPlayer stop];
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.audioPlayer play];
        });
    }
}

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

// 检查输出设备 是否连接耳机，是否使用听筒
-(void)checkPlayDevice {
    if ([UIDevice currentDevice].proximityState) {
        // 听筒播放
        [self changePlayerToEarpiece];
    } else {
        // 外放或耳机播放
        [self changePlayerToSpeaker];
    }
}

// 切到听筒模式
-(void)changePlayerToEarpiece {
    DLog(@"听筒播放");
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

// 切到扬声器模式
-(void)changePlayerToSpeaker {
    DLog(@"外放或耳机播放");
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(IM_Timer *)processTimer {
    if(_processTimer == nil) {
        _processTimer = [[IM_Timer alloc] init];
    }
    return _processTimer;
}
@end
