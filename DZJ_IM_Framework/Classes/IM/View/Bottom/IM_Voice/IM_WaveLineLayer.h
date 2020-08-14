//
//  IM_WaveLineLayer.h
//  DoctorCloud
//
//  Created by dzj on 2020/7/1.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface IM_WaveLineLayer : CAShapeLayer

/// 创建音条layer
/// @param height 高度
/// @param width 宽度
/// @param color 颜色
/// @param isUp 是否朝上
-(void)loadCustomLayer:(CGFloat)height width:(CGFloat)width color:(UIColor *)color isUp:(BOOL)isUp;

/// 更新音条高度
/// @param height 高度
-(void)updateLayerHeight:(CGFloat)height;

/// 修改音条颜色
/// @param color 颜色
-(void)updateLineColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
