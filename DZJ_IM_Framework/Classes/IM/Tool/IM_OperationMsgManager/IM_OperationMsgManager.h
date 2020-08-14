//
//  IM_OperationMsgManager.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/22.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IM_BasicCellTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_OperationMsgManager : NSObject

/// 配置视图控制器
/// @param viewController 聊天页面控制器
-(void)configViewController:(UIViewController *)viewController;

/// 点击消息
/// @param cell cell
-(void)tapMsgCell:(IM_BasicCellTableViewCell *)cell;

/// 长按消息
/// @param cell cell
-(void)longPressMsgCell:(IM_BasicCellTableViewCell *)cell;

/// 点击头像
/// @param cell cell
-(void)tapMsgAvatarCell:(IM_BasicCellTableViewCell *)cell;

/// 停止播放录音
/// @param cell cell
-(void)stopPlayAudio:(IM_BasicCellTableViewCell *)cell;

/// 获取正在播放语音的cell 有-直接返回cell 没有-返回nil
-(IM_BasicCellTableViewCell *)playingVoiceCell;

@end

NS_ASSUME_NONNULL_END
