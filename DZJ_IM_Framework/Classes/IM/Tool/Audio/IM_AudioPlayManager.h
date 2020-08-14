//
//  IM_AudioPlayManager.h
//  L_Chat
//
//  Created by LiuBo on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IM_AudioHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface IM_AudioPlayManager : NSObject

+(instancetype)shareInstance;

/// 播放data格式录音
/// @param data 录音data
- (void)startPlayWithData:(NSData *)data;

/// 停止播放
- (void)stopPlaying;

/// 配置播放状态回调
/// @param startPlayingBlock 开始播放
/// @param playCompleteBlock 结束播放
/// @param playingProcessBlock 播放进度
-(void)configStartPlayingBlock:(StartPlayingBlock)startPlayingBlock
             playCompleteBlock:(PlayCompleteBlock)playCompleteBlock
           playingProcessBlock:(PlayingProcessBlock)playingProcessBlock;

/// 当前是否正在播放语音
-(BOOL)isPlayingAudio;

@end

NS_ASSUME_NONNULL_END
