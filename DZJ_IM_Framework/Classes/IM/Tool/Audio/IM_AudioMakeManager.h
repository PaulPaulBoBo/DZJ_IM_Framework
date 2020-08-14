//
//  IM_AudioMakeManager.h
//  L_Chat
//
//  Created by LiuBo on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IM_AudioHeader.h"
#import "IM_Timer.h"

NS_ASSUME_NONNULL_BEGIN


@interface IM_AudioMakeManager : NSObject


@property (nonatomic, assign, readonly) BOOL isRecording;

/// 开始录音 返回值 YES-表示可以录音 NO-表示没有录音权限
- (BOOL)startRecording;

/// 结束录音
-(void)stopRecording;

/// 读取最新录音
-(id)readLocalRecording;

/// 配置录音回调
/// @param audioRecorderFinishRecordingBlock 播放完成回调
/// @param audioStartRecordingBlock 开始播放回调
/// @param audioRecordingFailBlock 播放失败回调
/// @param audioSpeakPowerBlock 音频值测量回调
/// @param audioSpeakTimeBlock 音频录制时长回调
-(void)configAudioRecorderFinishRecordingBlock:(AudioRecorderFinishRecordingBlock)audioRecorderFinishRecordingBlock
                      audioStartRecordingBlock:(AudioStartRecordingBlock)audioStartRecordingBlock
                       audioRecordingFailBlock:(AudioRecordingFailBlock)audioRecordingFailBlock
                          audioSpeakPowerBlock:(AudioSpeakPowerBlock)audioSpeakPowerBlock
                           audioSpeakTimeBlock:(AudioSpeakTimeBlock)audioSpeakTimeBlock;
// 是否拥有录音权限
- (BOOL)canRecord;

@end

NS_ASSUME_NONNULL_END
