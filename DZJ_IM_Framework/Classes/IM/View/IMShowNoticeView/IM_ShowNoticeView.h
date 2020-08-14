//
//  IM_ShowNoticeView.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/29.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidClickReadBtnBlock)(void);

@interface IM_ShowNoticeView : UIView

/// 弹出公告视图
/// @param title 公告标题
/// @param content 公告内容
/// @param didClickReadBtnBlock 点击“我知道了”回调
-(void)showNoticeWithTitle:(NSString *)title content:(NSString *)content didClickReadBtnBlock:(DidClickReadBtnBlock)didClickReadBtnBlock;

@end

NS_ASSUME_NONNULL_END
