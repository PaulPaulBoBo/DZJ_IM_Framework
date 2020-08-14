//
//  IM_BasicCellTableViewCell.h
//  L_Chat
//
//  Created by dzj on 2020/6/8.
//  Copyright © 2020 paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IM_MessageModel.h" // 消息模型
#import "IM_MsgLabel.h" // 容器视图 此处使用UILabel最为父视图 是为了UIMenuController的弹出，UIView不能弹出UIMenuController
#import "IM_ProcessView.h" // 进度条View

@class IM_BasicCellTableViewCell;

typedef void(^IM_SelectMessageAvatar)(IM_BasicCellTableViewCell * _Nullable cell);
typedef void(^IM_SelectMessage)(IM_BasicCellTableViewCell * _Nullable cell);
typedef void(^IM_LongPressMessage)(IM_BasicCellTableViewCell * _Nullable cell);
typedef void(^IM_RetryMessage)(IM_BasicCellTableViewCell * _Nullable cell);
typedef void(^IM_DeleteMessage)(IM_BasicCellTableViewCell * _Nullable cell);

typedef NS_ENUM(NSUInteger, IM_Direction) {
    IM_DirectionReceive, //消息接收
    IM_DirectionSend, //消息发送
};

static CGFloat IM_Space = 10;
static CGFloat IM_AvatarSide = 40;

NS_ASSUME_NONNULL_BEGIN

@interface IM_BasicCellTableViewCell : UITableViewCell

/// 时间标签
@property (nonatomic, strong) UILabel *timeLabel;

/// 头像视图
@property (nonatomic, strong) UIImageView *avatarView;

/// 昵称标签
@property (nonatomic, strong) UILabel *nameLabel;

/// 容器视图
@property (nonatomic, strong) IM_MsgLabel *container;

/// 气泡箭头视图
@property (nonatomic, strong) UIImageView *arrowImageView;

/// 活动指示器
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

/// 重发视图
@property (nonatomic, strong) UIImageView *retryView;

/// 消息数据
@property (nonatomic, strong) IM_MessageModel *data;

@property (nonatomic, strong) IM_SelectMessageAvatar selectMessageAvatar; // 点击头像block
@property (nonatomic, strong) IM_SelectMessage selectMessage; // 点击消息block
@property (nonatomic, strong) IM_LongPressMessage longPressMessage; // 长按消息block
@property (nonatomic, strong) IM_RetryMessage retryMessage; // 重发消息block
@property (nonatomic, strong) IM_DeleteMessage deleteMessage; // 撤回消息block

@property (nonatomic, assign) CGFloat containerInnerBoardSpace; // 内容承载视图内边距，默认10，可在子类中自定义该值

/// 单元填充函数
/// @param data 填充数据源
- (void)fillWithData:(IM_MessageModel *)data;

/// 配置要展示的item
/// @param items item数组，数组中必须为@(IM_MsgMenuItemType)类型
-(void)configShowMenuItems:(NSArray *)items;

/// 展示进度条，默认不展示
/// @param processValue 进度百分比 左闭右开区间范围 [0, 1) 超出无效，会移除进度条
/// @param type 进度条样式
-(void)showProcessView:(CGFloat)processValue type:(IM_ProcessType)type;

@end

NS_ASSUME_NONNULL_END
