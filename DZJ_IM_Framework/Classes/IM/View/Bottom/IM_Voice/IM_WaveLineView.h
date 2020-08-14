//
//  IM_WaveLineView.h
//  DoctorCloud
//
//  Created by dzj on 2020/7/1.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IM_WaveLineView : UIView

/// 更新音条值
/// @param value 音条值
-(void)updateLineValue:(CGFloat)value;

/// 修改音条颜色
/// @param color 颜色
-(void)updateLineColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
