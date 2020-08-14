//
//  IM_ShowPlayVideoView.h
//  DoctorCloud
//
//  Created by dzj on 2020/7/28.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidClickCloseBtnBlock)(void);

@interface IM_ShowPlayVideoView : NSObject

/// 弹出视频播放视图
/// @param videoUrl 视频链接
/// @param didClickReadBtnBlock 点击关闭回调
-(void)showVideoWithVideoUrl:(NSString *)videoUrl didClickReadBtnBlock:(DidClickCloseBtnBlock)didClickCloseBtnBlock;

@end

NS_ASSUME_NONNULL_END
