//
//  IM_ProcessLayer.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/28.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IM_ProcessType) {
    IM_ProcessTypeLine, // 线型进度条
    IM_ProcessTypeCircle, // 圆形进度条
};

@interface IM_ProcessLayer : CAShapeLayer

/// 创建进度条layer
/// @param height 进度条高度
/// @param width 进度条宽度
/// @param type 进度条类型
-(void)loadCustomLayer:(CGFloat)height width:(CGFloat)width type:(IM_ProcessType)type;

/// 更新进度条
/// @param processValue 进度 百分比 闭区间范围 [0, 1] 超出无效
-(void)updateProcessValue:(CGFloat)processValue;

@end

NS_ASSUME_NONNULL_END
