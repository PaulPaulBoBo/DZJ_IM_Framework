//
//  IM_Timer.m
//  DaZhuanJia
//
//  Created by dzj on 2020/1/8.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_Timer.h"

@interface IM_Timer()

@property (nonatomic, assign) IM_TimerType timerType;
@property (nonatomic, assign) CGFloat timeInterval;

@property (nonatomic, strong) NSTimer *defaultTimer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) dispatch_source_t gcdTimer;

@property (nonatomic, strong) StartTimerBlock defaultTimerStartTimerBlock;
@property (nonatomic, strong) StartTimerBlock displayLinkStartTimerBlock;
@property (nonatomic, strong) StartTimerBlock gcdTimerStartTimerBlock;

@property (nonatomic, strong) StopTimerBlock defaultTimerStopTimerBlock;
@property (nonatomic, strong) StopTimerBlock displayLinkStopTimerBlock;
@property (nonatomic, strong) StopTimerBlock gcdTimerStopTimerBlock;

@end

//static CGFloat defaultTimeInterval = 1.0;

static NSUInteger defaultTimerSecond = 0;
static NSUInteger displayLinkSecond = 0;
static NSUInteger gcdTimerSecond = 0;

@implementation IM_Timer

-(void)startTimerWithTimerType:(IM_TimerType)timerType startTimerBlock:(StartTimerBlock)startTimerBlock {
    [self startTimerWithTimerType:timerType timeInterval:1.0 startTimerBlock:startTimerBlock];
}

-(void)startTimerWithTimerType:(IM_TimerType)timerType timeInterval:(CGFloat)timeInterval startTimerBlock:(StartTimerBlock)startTimerBlock {
    self.timerType = timerType;
    self.timeInterval = timeInterval;
    if(self.timerType == IM_TimerTypeDefault) {
        defaultTimerSecond = 0;
        self.defaultTimerStartTimerBlock = startTimerBlock;
        self.defaultTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(defaultTimerAction) userInfo:nil repeats:YES];
    } else if(self.timerType == IM_TimerTypeCAD) {
        displayLinkSecond = 0;
        self.displayLinkStartTimerBlock = startTimerBlock;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink)];
        // 每隔1帧调用一次
        self.displayLink.frameInterval = self.timeInterval*60;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else if(self.timerType == IM_TimerTypeGCD) {
        gcdTimerSecond = 0;
        self.gcdTimerStartTimerBlock = startTimerBlock;
        self.gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(self.gcdTimer, DISPATCH_TIME_NOW, self.timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.gcdTimer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                gcdTimerSecond += 1;
                self.gcdTimerStartTimerBlock(gcdTimerSecond);
            });
        });
        dispatch_resume(self.gcdTimer);
    }
}

-(void)stopTimerWithTimerType:(IM_TimerType)timerType stopTimerBlock:(StopTimerBlock)stopTimerBlock {
    self.timerType = timerType;
    if(self.timerType == IM_TimerTypeDefault) {
        defaultTimerSecond = 0.0;
        self.defaultTimerStopTimerBlock = stopTimerBlock;
        self.defaultTimerStopTimerBlock();
        [self.defaultTimer invalidate];
        self.defaultTimer = nil;
    } else if(self.timerType == IM_TimerTypeCAD) {
        displayLinkSecond = 0.0;
        self.defaultTimerStopTimerBlock = stopTimerBlock;
        self.defaultTimerStopTimerBlock();
        [self.displayLink invalidate];
        self.displayLink = nil;
    } else if(self.timerType == IM_TimerTypeGCD) {
        gcdTimerSecond = 0.0;
        self.defaultTimerStopTimerBlock = stopTimerBlock;
        self.defaultTimerStopTimerBlock();
        // 关闭定时器
        dispatch_source_cancel(self.gcdTimer);
    }
}

-(void)defaultTimerAction {
    defaultTimerSecond += 1;
    self.defaultTimerStartTimerBlock(defaultTimerSecond);
}

-(void)handleDisplayLink {
    displayLinkSecond += 1;
    self.displayLinkStartTimerBlock(displayLinkSecond);
}

@end
