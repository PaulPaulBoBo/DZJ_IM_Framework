//
//  IM_WaveView.h
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    WaveTypeUp,
    WaveTypeUpAndDown,
    WaveTypeDown,
} WaveType; // 波动类型

typedef enum : NSUInteger {
    WaveLineTypeRect,
    WaveLineTypeRound,
} WaveLineType; // 波动音条类型

typedef enum : NSUInteger {
    WaveAnimationTypeExpand,
    WaveAnimationTypeAlpa,
} WaveAnimationType;

@interface IM_WaveView : UIView

@property (nonatomic, strong) UILabel *titleLabel; // 正在说话提示语标签
@property (nonatomic, strong) UILabel *cancelLabel; // 取消录音提示语标签
@property (nonatomic, strong) UIImageView *voiceBehindImageView; // 白色话筒视图
@property (nonatomic, strong) UIImageView *voiceFrontImageView; // 透明话筒视图


/// 配置音条参数
/// @param lineCount 音条个数
/// @param waveType 波动类型
/// @param waveDuration 波动动画时长
/// @param waveLineType 音条类型
-(void)configLineCount:(NSInteger)lineCount
              waveType:(WaveType)waveType
          waveDuration:(CGFloat)waveDuration
          waveLineType:(WaveLineType)waveLineType;

/// 以动画形式展示初始化的音条
/// @param waveAnimationType 动画类型
-(void)showInitWaveWithAnimationType:(WaveAnimationType)waveAnimationType;

/// 开始音条颜色变化动画
-(void)startShowColorChangeAnimation;

/// 结束音条颜色变化动画
-(void)stopShowColorChangeAnimation;

/// 将最新的音量刷新到界面
/// @param voice 音量 0-1
-(void)updateVoice:(CGFloat)voice;

@end

NS_ASSUME_NONNULL_END
