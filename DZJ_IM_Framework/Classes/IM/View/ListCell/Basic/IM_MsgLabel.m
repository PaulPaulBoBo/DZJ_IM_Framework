//
//  IM_MsgLabel.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/23.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_MsgLabel.h"

@interface IM_MsgLabel()

@property (nonatomic, strong) NSMutableArray *showItems;
@property (nonatomic, strong) IM_MsgSelectItemBlock selectItemBlock;
@property (nonatomic, strong) Tap_MsgBlock tapBlock;
@property (nonatomic, strong) LongPress_MsgBlock longPressBlock;
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGes;

@end

@implementation IM_MsgLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabel:)];
        [self addGestureRecognizer:self.tapGes];
        self.longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLabel:)];
        [self addGestureRecognizer:self.longPressGes];
    }
    return self;
}

#pragma mark - public

// 配置要展示的item
-(void)configMenuItems:(NSArray *)items {
    if(items != nil && items.count > 0) {
        self.showItems = [NSMutableArray arrayWithArray:items];
    }
}

// 配置点击回调
-(void)configSelectItemBlock:(IM_MsgSelectItemBlock)selectItemBlock {
    self.selectItemBlock = selectItemBlock;
}

/// 配置点击和长按回调
/// @param tap_MsgBlock 点击回调
/// @param longPress_MsgBlock 长按回调
-(void)configTap_MsgBlock:(Tap_MsgBlock)tap_MsgBlock longPress_MsgBlock:(LongPress_MsgBlock)longPress_MsgBlock {
    self.tapBlock = tap_MsgBlock;
    self.longPressBlock = longPress_MsgBlock;
}

// 点击label
-(void)tapLabel:(UIGestureRecognizer *)ges {
    if(self.tapBlock) {
        self.tapBlock();
    }
}

// 长按label
- (void)longPressLabel:(UIGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateBegan && self.showItems.count > 0) {
        if(self.longPressBlock) {
            self.longPressBlock();
        }
        // 让label成为第一响应者
        [self becomeFirstResponder];

        // 获得菜单
        UIMenuController *menu = [UIMenuController sharedMenuController];

        // 设置菜单内容
        menu.menuItems = @[
            [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyContent:)],
            [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(deleteItem:)]
        ];

        // 菜单最终显示的位置
        [menu setTargetRect:self.bounds inView:self];

        // 显示菜单
        [menu setMenuVisible:YES animated:YES];
    }
}

#pragma mark - private

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyContent:)) {
        return [self needShowItem:IM_MsgMenuItemTypeCopy];
    } else if (action == @selector(deleteItem:)) {
        return [self needShowItem:IM_MsgMenuItemTypeDelete];
    }
    
    return NO;
}

- (void)copyContent:(UIMenuController *)menu {
    if(self.selectItemBlock) {
        self.selectItemBlock(IM_MsgMenuItemTypeCopy);
    }
}

- (void)deleteItem:(UIMenuController *)menu {
    if(self.selectItemBlock) {
        self.selectItemBlock(IM_MsgMenuItemTypeDelete);
    }
}

// 是否展示item
-(BOOL)needShowItem:(IM_MsgMenuItemType)type {
    BOOL needShowItem = NO;
    for (int i = 0; i < self.showItems.count; i++) {
        IM_MsgMenuItemType tmpType = (IM_MsgMenuItemType)[self.showItems[i] integerValue];
        if(tmpType == type) {
            needShowItem = YES;
        }
    }
    return needShowItem;
}

#pragma mark - lazy

-(NSMutableArray *)showItems {
    if(_showItems == nil) {
        _showItems = [[NSMutableArray alloc] init];
    }
    return _showItems;
}

@end
