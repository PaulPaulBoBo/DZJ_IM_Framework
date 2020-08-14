//
//  IM_AudioHeader.h
//  L_Chat
//
//  Created by LiuBo on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#ifndef IM_AudioHeader_h
#define IM_AudioHeader_h

typedef void(^PlayCompleteBlock)(BOOL hasError);
typedef void(^StartPlayingBlock)(BOOL isPlaying);
typedef void(^PlayingProcessBlock)(CGFloat playingProcess);
typedef void(^AudioRecorderFinishRecordingBlock)(NSData *data, CGFloat audioTimeLength);
typedef void(^AudioStartRecordingBlock)(BOOL isRecording);
typedef void(^AudioRecordingFailBlock)(NSString *reason);
typedef void(^AudioSpeakPowerBlock)(float power);
typedef void(^AudioSpeakTimeBlock)(CGFloat seconds);

#endif /* IM_AudioHeader_h */
