//
//  IM_Timer.h
//  DaZhuanJia
//
//  Created by dzj on 2020/1/8.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^StartTimerBlock)(CGFloat seconds);
typedef void(^StopTimerBlock)(void);

typedef enum : NSUInteger {
    IM_TimerTypeDefault, //默认的NSTimer创建计时器
    IM_TimerTypeCAD,     //CADisplayLink创建计时器
    IM_TimerTypeGCD,     //GCD创建计时器
} IM_TimerType;

NS_ASSUME_NONNULL_BEGIN

#define IM_MIN_RECORDER_TIME 1
#define IM_MAX_RECORDER_TIME 60

@interface IM_Timer : NSObject

-(void)startTimerWithTimerType:(IM_TimerType)timerType startTimerBlock:(StartTimerBlock)startTimerBlock;
-(void)startTimerWithTimerType:(IM_TimerType)timerType timeInterval:(CGFloat)timeInterval startTimerBlock:(StartTimerBlock)startTimerBlock;

-(void)stopTimerWithTimerType:(IM_TimerType)timerType stopTimerBlock:(StopTimerBlock)stopTimerBlock;

@end

NS_ASSUME_NONNULL_END
