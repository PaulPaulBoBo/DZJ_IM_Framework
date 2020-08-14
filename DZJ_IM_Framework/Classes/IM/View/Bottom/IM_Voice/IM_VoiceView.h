//
//  IM_VoiceView.h
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^StartVoice)(void);
typedef void(^CancelVoice)(void);
typedef void(^FinishVoice)(id voiceData, CGFloat duration);

@interface IM_VoiceView : UIView

@property (nonatomic, strong) UIButton *pressBtn;

/// 配置语音状态回调
/// @param startVoice 开始说话
/// @param cancelVoice 取消语音录制
/// @param finishVoice 完成语音录制
-(void)configStartVoice:(StartVoice)startVoice
            cancelVoice:(CancelVoice)cancelVoice
            finishVoice:(FinishVoice)finishVoice;

@end

NS_ASSUME_NONNULL_END
