//
//  IM_VoiceShowMenuView.h
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IM_VoiceShowMenuView : UIView

/// 展示正在录音菜单视图
-(void)showVoiceMenuView;

/// 隐藏正在录音菜单视图
-(void)hideVoiceMenuView;

/// 配置滑动过程中处于发送状态的区域
/// @param rect 发送状态的区域
-(void)configCanSendRect:(CGRect)rect;

/// 更新手指在屏幕中拖动的坐标
/// @param point 坐标
-(void)updatePanPosition:(CGPoint)point;

/// 刷新声音波动画
/// @param voice 音量
-(void)updateVoice:(CGFloat)voice;

/// 刷新录音时长
/// @param seconds 秒
-(void)updateVoiceTime:(CGFloat)seconds;

@end

NS_ASSUME_NONNULL_END
