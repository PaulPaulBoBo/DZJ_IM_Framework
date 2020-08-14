//
//  IM_HeaderView.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/16.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    IM_HeaderViewTypeWaiting, // 等待刷新
    IM_HeaderViewTypeRefreshing, // 正在刷新
    IM_HeaderViewTypeEndRefresh, // 结束刷新
    IM_HeaderViewTypeNoMore, // 没有更多
} IM_HeaderViewType;

@interface IM_HeaderView : UIView

@property (nonatomic, assign, readonly) IM_HeaderViewType type;

/// 刷新头视图状态
/// @param type 状态枚举
-(void)refreshState:(IM_HeaderViewType)type;

/// 旋转状态图片角度
/// @param percent 旋转比例 100% 代表旋转360度
-(void)rotatePersent:(CGFloat)percent;

@end

NS_ASSUME_NONNULL_END
