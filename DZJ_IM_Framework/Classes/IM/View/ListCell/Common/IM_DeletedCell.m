//
//  IM_DeletedCell.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/23.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_DeletedCell.h"

@interface IM_DeletedCell()

/// 时间标签
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation IM_DeletedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self loadCustomView];
    }
    return self;
}

#pragma mark - public

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    IM_Direction direction = [data.fromUserId isEqual:clearNilStr([UserStorage sharedInstance].userInfo.userID)]?IM_DirectionSend:IM_DirectionReceive;
    [self loadisDeleted:data.isDeleted direction:direction nickName:data.nickName];
}

// 消息是否已撤回
-(void)loadisDeleted:(BOOL)isDeleted direction:(IM_Direction)direction nickName:(NSString *)nickName {
    if(isDeleted) {
        
        NSString *deleteMsg = @"撤回了一条消息";
        if(direction == IM_DirectionSend) {
            self.contentLabel.text = [NSString stringWithFormat:@"您%@", deleteMsg];
        } else {
            self.contentLabel.text = [NSString stringWithFormat:@"\"%@\"%@", clearNilStr(nickName), deleteMsg];
        }
    }
}

#pragma mark - private
-(void)loadCustomView {
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.height.greaterThanOrEqualTo(@22);
    }];
}

#pragma mark - lazy

-(UILabel *)contentLabel {
    if(_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _contentLabel;
}

@end
