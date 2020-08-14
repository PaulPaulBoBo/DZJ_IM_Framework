//
//  IM_WaveSingleView.h
//  DoctorCloud
//
//  Created by dzj on 2020/7/9.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IM_WaveSingleView : UIView

@property (nonatomic, assign) CGFloat amplitude;        // 振幅
@property (nonatomic, assign) CGFloat angularVelocity;  // 角速度
@property (nonatomic, assign) CGFloat firstPhase;       // 初相
@property (nonatomic, assign) CGFloat offset;           // 偏距
@property (nonatomic, assign) CGFloat speed;            // 移动速度
@property (nonatomic, strong) UIColor *waveColor;       // 背景色

@end

NS_ASSUME_NONNULL_END
