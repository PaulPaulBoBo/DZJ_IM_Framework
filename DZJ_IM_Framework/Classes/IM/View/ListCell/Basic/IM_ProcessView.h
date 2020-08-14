//
//  IM_ProcessView.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/28.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IM_ProcessLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_ProcessView : UIView

/// 创建进度条view
/// @param type 进度条类型
-(void)loadProcessViewType:(IM_ProcessType)type;

/// 更新进度条
/// @param processValue 进度 百分比 闭区间范围 [0, 1] 超出无效
-(void)updateProcessValue:(CGFloat)processValue;

// 移除进度条
-(void)removeProcessView;

@end

NS_ASSUME_NONNULL_END
