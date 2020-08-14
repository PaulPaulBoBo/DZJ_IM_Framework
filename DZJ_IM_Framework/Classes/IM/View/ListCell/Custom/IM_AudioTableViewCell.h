//
//  IM_AudioTableViewCell.h
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_BasicCellTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_AudioTableViewCell : IM_BasicCellTableViewCell

/// 单元填充函数
/// @param data 填充数据源
- (void)fillWithData:(IM_MessageModel *)data;

/// 启动语音播放动画
-(void)startVoiceAnimation;

/// 停止语音播放动画
-(void)stopVoiceAnimation;

@end

NS_ASSUME_NONNULL_END
