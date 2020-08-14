//
//  IM_MsgLabel.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/23.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    IM_MsgMenuItemTypeCopy,
    IM_MsgMenuItemTypeDelete
} IM_MsgMenuItemType;

typedef void(^IM_MsgSelectItemBlock)(IM_MsgMenuItemType type);
typedef void(^Tap_MsgBlock)(void);
typedef void(^LongPress_MsgBlock)(void);

/// 此处使用UILabel最为父视图 是为了UIMenuController的弹出，UIView不能弹出UIMenuController
@interface IM_MsgLabel : UILabel

@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGes;
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGes;

/// 配置要展示的item
/// @param items item数组，数组中必须为@(IM_MsgMenuItemType)类型
-(void)configMenuItems:(NSArray *)items;

/// 配置点击回调
/// @param selectItemBlock 选中某个item回调
-(void)configSelectItemBlock:(IM_MsgSelectItemBlock)selectItemBlock;

/// 配置点击和长按回调
/// @param tap_MsgBlock 点击回调
/// @param longPress_MsgBlock 长按回调
-(void)configTap_MsgBlock:(Tap_MsgBlock)tap_MsgBlock longPress_MsgBlock:(LongPress_MsgBlock)longPress_MsgBlock;

@end

NS_ASSUME_NONNULL_END
