//
//  IM_BasicCellTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/8.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_BasicCellTableViewCell.h"

@interface IM_BasicCellTableViewCell()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) IM_ProcessView *processView; // 进度条视图

@end

@implementation IM_BasicCellTableViewCell

#pragma mark - life

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.containerInnerBoardSpace = IM_Space;
    }
    return self;
}

#pragma mark - public

- (void)fillWithData:(IM_MessageModel *)data {
    if(data) {
        self.data = data;
        // 加载视图
        IM_Direction direction = [data.fromUserId isEqual:clearNilStr([UserStorage sharedInstance].userInfo.userID)]?IM_DirectionSend:IM_DirectionReceive;
        [self loadTimeViewIsShowTime:data.isShowTime];
        [self loadAvatarViewDirection:direction];
        [self loadNickNameViewDirection:direction];
        [self loadContainerDirection:direction msgType:data.msgType];
        [self loadArrowImageViewDirection:direction msgType:data.msgType];
        [self loadIndicatorViewDirection:direction];
        [self loadRetryViewDirection:direction];
        
        // 加载数据
        if(data.updatedTime) {
            [self loadIsShowTime:data.isShowTime timeStr:[NSString stringWithFormat:@"%@", [NSDate transToDayWithDate:data.updatedTime]]];
        } else if(data.createdTime) {
            [self loadIsShowTime:data.isShowTime timeStr:[NSString stringWithFormat:@"%@", [NSDate transToDayWithDate:data.createdTime]]];
        } else {
            [self loadIsShowTime:NO timeStr:@""];
        }
        [self loadNickName:data.nickName tags:data.tags];
        [self loadAvatarImage:data.avatar isMale:[data.gender isEqualToString:@"MALE"]];
        [self loadState:data.state];
        [self loadMenuItemConfig:data.msgType direction:direction];
        
        // 发送完成的消息移除进度条，避免重用问题
        if(data.state == IM_MessageStateSended) {
            [self showProcessView:1 type:(IM_ProcessTypeCircle)];
        }
    }
}

// 配置要展示的item
-(void)configShowMenuItems:(NSArray *)items {
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:items];
    if(items.count > 0) {
        if([self hasDeleteItem:items]) {
            // 配置了撤销item
            if([self canShowDeleteItemMaxTime:60*30] && self.data.state == IM_MessageStateSended) {
                // 可以展示撤销
            } else {
                // 超时 不可以展示撤销
                mArr = [NSMutableArray arrayWithArray:[self removeDeleteItem:items]];
            }
        } else {
            // 没有配置撤销item
        }
    }
    [self.container configMenuItems:[mArr copy]];
}

// 展示进度条，默认不展示
-(void)showProcessView:(CGFloat)processValue type:(IM_ProcessType)type {
    if(processValue >= 0 && processValue < 1) {
        // 展示进度条
        if(self.processView.superview == nil) {
            [self.container addSubview:self.processView];
            [self.processView loadProcessViewType:type];
        }
        [self.processView updateProcessValue:processValue];
    } else {
        // 超出范围 移除进度条
        [self.processView removeProcessView];
        [self.processView removeFromSuperview];
        self.processView = nil;
    }
}

#pragma mark - private

/// 是否配置了删除item
/// @param items items数组
-(BOOL)hasDeleteItem:(NSArray *)items {
    BOOL hasDeleteItem = NO;
    for (int i = 0; i < items.count; i++) {
        IM_MsgMenuItemType type = (IM_MsgMenuItemType)[items[i] integerValue];
        if(type == IM_MsgMenuItemTypeDelete) {
            hasDeleteItem = YES;
            break;
        }
    }
    return hasDeleteItem;
}

/// 能否展示撤回item 限制最大时长
/// @param second 最大时长 超过就不展示撤回item
-(BOOL)canShowDeleteItemMaxTime:(CGFloat)second {
    BOOL canShowDeleteItem = NO;
    NSTimeInterval timeInerval = [[NSDate date] timeIntervalSinceDate:self.data.updatedTime];
    if(fabs(timeInerval) < second) {
        canShowDeleteItem = YES;
    }
    return canShowDeleteItem;
}

/// 移除撤回item
/// @param items items数组
-(NSMutableArray *)removeDeleteItem:(NSMutableArray *)items {
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:items];
    for (int i = 0; i < mArr.count; i++) {
        IM_MsgMenuItemType type = (IM_MsgMenuItemType)[items[i] integerValue];
        if(type == IM_MsgMenuItemTypeDelete) {
            [mArr removeObjectAtIndex:i];
            break;
        }
    }
    return [mArr copy];
}

// 创建时间
-(void)loadTimeViewIsShowTime:(BOOL)isShowTime {
    if(self.timeLabel.superview == nil) {
        [self.contentView addSubview:self.timeLabel];
    }
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        if(isShowTime) {
            make.top.equalTo(self.contentView).offset(self.containerInnerBoardSpace);
            make.height.equalTo(@22);
        } else {
            make.top.equalTo(self.contentView).offset(self.containerInnerBoardSpace);
            make.height.equalTo(@0);
        }
    }];
}

// 创建头像
-(void)loadAvatarViewDirection:(IM_Direction)direction {
    if(self.avatarView.superview == nil) {
        [self.contentView addSubview:self.avatarView];
    }
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(direction == IM_DirectionReceive) {
            make.left.equalTo(self.contentView).offset(self.containerInnerBoardSpace);
        } else {
            make.right.equalTo(self.contentView).offset(-(self.containerInnerBoardSpace));
        }
        make.top.equalTo(self.timeLabel.mas_bottom);
        make.width.height.equalTo(@(IM_AvatarSide));
    }];
}

// 创建昵称
-(void)loadNickNameViewDirection:(IM_Direction)direction {
    if(self.nameLabel.superview == nil) {
        [self.contentView addSubview:self.nameLabel];
    }
    if(direction == IM_DirectionReceive) {
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.nameLabel.textAlignment = NSTextAlignmentRight;
    }
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(direction == IM_DirectionReceive) {
            make.left.equalTo(self.avatarView.mas_right).offset(self.containerInnerBoardSpace);
            make.right.lessThanOrEqualTo(self.contentView).offset(-(self.containerInnerBoardSpace));
        } else {
            make.right.equalTo(self.avatarView.mas_left).offset(-(self.containerInnerBoardSpace));
            make.left.greaterThanOrEqualTo(self.contentView).offset(self.containerInnerBoardSpace);
        }
        make.top.equalTo(self.avatarView.mas_top);
        make.height.equalTo(@(IM_AvatarSide));
    }];
}

// 创建内容承载
-(void)loadContainerDirection:(IM_Direction)direction msgType:(IM_MsgType)msgType {
    if(self.container.superview == nil) {
        [self.contentView addSubview:self.container];
    }
    if(direction == IM_DirectionReceive) {
        self.container.backgroundColor = [UIColor whiteColor];
    } else {
        if(msgType == IM_MsgTypeText) {
            self.container.backgroundColor = [UIColor colorWithHexString:@"0x2dc4c0"];
        } else {
            self.container.backgroundColor =[UIColor whiteColor];
        }
    }
    [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(direction == IM_DirectionReceive) {
            make.left.equalTo(self.avatarView.mas_right).offset(self.containerInnerBoardSpace);
            make.right.lessThanOrEqualTo(self.contentView).offset(-(self.containerInnerBoardSpace*2+IM_AvatarSide));
        } else {
            make.right.equalTo(self.avatarView.mas_left).offset(-(self.containerInnerBoardSpace));
            make.left.greaterThanOrEqualTo(self.contentView).offset(self.containerInnerBoardSpace*2+IM_AvatarSide);
        }
        make.top.equalTo(self.avatarView.mas_bottom);
        make.bottom.equalTo(self.contentView).offset(-(self.containerInnerBoardSpace));
    }];
}

// 创建气泡箭头视图
-(void)loadArrowImageViewDirection:(IM_Direction)direction msgType:(IM_MsgType)msgType {
    if(self.arrowImageView.superview == nil) {
        [self.contentView addSubview:self.arrowImageView];
    }
    self.arrowImageView.transform = CGAffineTransformMakeRotation(0);
    if(direction == IM_DirectionReceive) {
        self.arrowImageView.image = [UIImage imageNamed:@"im_bubble_left"];
    } else {
        if(msgType == IM_MsgTypeText) {
            self.arrowImageView.image = [UIImage imageNamed:@"im_bubble_right"];
        } else {
            self.arrowImageView.image = [UIImage imageNamed:@"im_bubble_left"];
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }
    [self.arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(direction == IM_DirectionReceive) {
            make.right.equalTo(self.container.mas_left);
        } else {
            make.left.equalTo(self.container.mas_right);
        }
        make.top.equalTo(self.container.mas_top).offset(self.containerInnerBoardSpace);
    }];
}

// 创建发送中状态视图
-(void)loadIndicatorViewDirection:(IM_Direction)direction {
    if(self.indicator.superview == nil) {
        [self.contentView addSubview:self.indicator];
    }
    [self.indicator mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(direction == IM_DirectionReceive) {
            make.left.equalTo(self.container.mas_right).offset(self.containerInnerBoardSpace);
        } else {
            make.right.equalTo(self.container.mas_left).offset(-self.containerInnerBoardSpace);
        }
        make.top.equalTo(self.container.mas_top);
    }];
}

// 创建重新发送视图
-(void)loadRetryViewDirection:(IM_Direction)direction {
    if(self.retryView.superview == nil) {
        [self.contentView addSubview:self.retryView];
    }
    [self.retryView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(direction == IM_DirectionReceive) {
            make.left.equalTo(self.container.mas_right).offset(self.containerInnerBoardSpace);
        } else {
            make.right.equalTo(self.container.mas_left).offset(-self.containerInnerBoardSpace);
        }
        make.top.equalTo(self.container.mas_top);
    }];
}

// 加载时间数据
-(void)loadIsShowTime:(BOOL)isShowTime timeStr:(NSString *)timeStr {
    if(isShowTime) {
        self.timeLabel.text = timeStr;
    } else {
        self.timeLabel.text = @"";
    }
}

// 加载昵称数据
-(void)loadNickName:(NSString *)nickName tags:(NSArray *)tags {
    NSString *tagsStr = @"";
    for (int i = 0; i < tags.count; i++) {
        if(i == 0) {
            tagsStr = tags[i];
        } else {
            tagsStr = [NSString stringWithFormat:@"%@ %@", tagsStr, tags[i]];
        }
    }
    if(tagsStr.length > 0) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", clearNilStr(nickName), clearNilStr(tagsStr)];
    } else {
        if(nickName != nil && nickName.length > 0) {
            self.nameLabel.text = clearNilStr(nickName);
        } else {
            self.nameLabel.text = @"";
        }
    }
}

// 加载头像数据
-(void)loadAvatarImage:(NSString *)imgUrl isMale:(BOOL)isMale {
    if(imgUrl.length > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.avatarView loadImageWithURL:imgUrl placeholder:[UIImage imageNamed:isMale?@"defaulticon":@"defaultAvatarWoman"] completed:^(UIImage *image, NSError *error) {
                
            }];
        });
    } else {
        self.avatarView.image = [UIImage imageNamed:isMale?@"defaulticon":@"defaultAvatarWoman"];
    }
}

// 加载长按弹出的Menu item
-(void)loadMenuItemConfig:(IM_MsgType)type direction:(IM_Direction)direction {
    NSMutableArray *items = [NSMutableArray arrayWithArray:@[@(IM_MsgMenuItemTypeCopy),@(IM_MsgMenuItemTypeDelete)]];
    switch (type) {
        case IM_MsgTypeText:
            // 文本 可复制 可撤销
            if(direction == IM_DirectionSend) {
                // 自己发的文本类型 可复制 可撤销
                items = @[@(IM_MsgMenuItemTypeCopy),@(IM_MsgMenuItemTypeDelete)];
            } else {
                // 别人发的文本类型 可复制 不可撤销
                items = @[@(IM_MsgMenuItemTypeCopy)];
            }
            break;
        default: {
            // 非文本 不可复制 可撤销
            if(direction == IM_DirectionSend) {
                // 自己发的非文本类型 不可复制 可撤销
                items = @[@(IM_MsgMenuItemTypeDelete)];
            } else {
                // 别人发的非文本类型 不可复制 不可撤销
                items = @[];
            }
        } break;
    }
    [self configShowMenuItems:items];
}

// 加载消息状态数据
-(void)loadState:(IM_MessageState)state {
    self.indicator.hidden = NO;
    self.retryView.hidden = NO;
    if(state == IM_MessageStateSended) {
        self.retryView.hidden = YES;
        [self.indicator stopAnimating];
    } else if(state == IM_MessageStateSending) {
        self.retryView.hidden = YES;
        [self.indicator startAnimating];
    } else if(state == IM_MessageStateSendFail) {
        // 发送失败
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
    } else if(state == IM_MessageStateDeteting) {
        // 删除中
        self.indicator.hidden = NO;
        [self.indicator stopAnimating];
    } else if(state == IM_MessageStateDeleted) {
        // 已删除
        [self.indicator stopAnimating];
    }
}

-(void)onSelectMessageAvatar:(UIGestureRecognizer *)recognizer {
    if(self.selectMessageAvatar) {
        self.selectMessageAvatar(self);
    }
}

-(void)onSelectMessage:(UIGestureRecognizer *)recognizer {
    if(self.selectMessage) {
        self.selectMessage(self);
    }
}

-(void)onLongPress:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if(self.longPressMessage) {
            self.longPressMessage(self);
        }
    }
}

- (void)onRetryMessage:(UIGestureRecognizer *)recognizer {
    if(self.retryMessage) {
        self.retryMessage(self);
    }
}

#pragma mark - lazy

-(UILabel *)timeLabel {
    if(_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

-(UIImageView *)avatarView {
    if(_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = IM_AvatarSide/2.0;
        _avatarView.backgroundColor = [UIColor grayColor];
        UITapGestureRecognizer *tapAvatarView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessageAvatar:)];
        [_avatarView addGestureRecognizer:tapAvatarView];
        [_avatarView setUserInteractionEnabled:YES];
    }
    return _avatarView;
}

-(UILabel *)nameLabel {
    if(_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
    }
    return _nameLabel;
}

-(IM_MsgLabel *)container {
    if(_container == nil) {
        _container = [[IM_MsgLabel alloc] init];
        _container.backgroundColor = [UIColor whiteColor];
        _container.clipsToBounds = YES;
        _container.layer.cornerRadius = self.containerInnerBoardSpace;
        @weakify(self)
        [_container configSelectItemBlock:^(IM_MsgMenuItemType type) {
            @strongify(self)
            switch (type) {
                case IM_MsgMenuItemTypeCopy: {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = clearNilStr(self.data.content);
                    [DZJToast toast:@"复制成功!"];
                } break;
                case IM_MsgMenuItemTypeDelete: {
                    if(self.deleteMessage) {
                        self.deleteMessage(self);
                    }
                } break;
                default:
                    break;
            }
        }];
        [_container configTap_MsgBlock:^{
            if(self.selectMessage) {
                self.selectMessage(self);
            }
        } longPress_MsgBlock:^{
            if(self.longPressMessage) {
                self.longPressMessage(self);
            }
        }];
        
        _container.userInteractionEnabled = YES;
    }
    return _container;
}

-(UIImageView *)arrowImageView {
    if(_arrowImageView == nil) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"im_bubble_left"];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _arrowImageView;
}

-(UIActivityIndicatorView *)indicator {
    if(_indicator == nil) {
        _indicator = [[UIActivityIndicatorView alloc] init];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    return _indicator;
}

-(UIImageView *)retryView {
    if(_retryView == nil) {
        _retryView = [[UIImageView alloc] init];
        _retryView.userInteractionEnabled = YES;
        [_retryView setImage:[UIImage imageNamed:@"im_msg_error"]];
        _retryView.hidden = YES;
        UITapGestureRecognizer *resendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetryMessage:)];
        [_retryView addGestureRecognizer:resendTap];
    }
    return _retryView;
}

-(IM_ProcessView *)processView {
    if(_processView == nil) {
        _processView = [[IM_ProcessView alloc] initWithFrame:CGRectMake(0, 0, self.container.width, self.container.height)];
    }
    return _processView;
}

@end
