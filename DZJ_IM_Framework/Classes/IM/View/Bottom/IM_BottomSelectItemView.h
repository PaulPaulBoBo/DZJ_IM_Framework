//
//  IM_BottomSelectItemView.h
//  L_Chat
//
//  Created by dzj on 2020/6/5.
//  Copyright © 2020 paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IM_BottomSelectItemView;

typedef void(^DidClickItem)(IM_BottomSelectItemView * _Nullable item);

NS_ASSUME_NONNULL_BEGIN

@interface IM_BottomSelectItemView : UIView

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *roundBgView;

/// 配置展示数据
/// @param iconUrlStr 图标链接
/// @param title 标题
-(void)loadItemWithIcon:(NSString *)iconUrlStr title:(NSString *)title;

/// 配置点击事件回调
/// @param didClickItem 点击事件回调
-(void)configDidClickItem:(DidClickItem)didClickItem;

@end

NS_ASSUME_NONNULL_END
