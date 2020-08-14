//
//  IM_NoticeTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_NoticeTableViewCell.h"

@interface IM_NoticeTableViewCell()

@property (nonatomic, strong) UIImageView *leftIconImageView; // 左侧图标
@property (nonatomic, strong) UILabel *noticeNameLabel; // 固定的“群公告”标题
@property (nonatomic, strong) UIView *sepLineView; // 分割线
@property (nonatomic, strong) UILabel *noticeTitleLabel; // 标题

@end

static NSString *NoticeNameStr = @"群公告";

@implementation IM_NoticeTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    if(data.noticeModel) {
        self.noticeTitleLabel.text = clearNilStr(data.noticeModel.notice);
    }
}

#pragma mark - life

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadCustomView];
    }
    return self;
}

#pragma mark - private

// 加载视图
-(void)loadCustomView {
    [self.container addSubview:self.leftIconImageView];
    [self.leftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.width.height.equalTo(@20);
    }];
    
    [self.container addSubview:self.noticeNameLabel];
    [self.noticeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftIconImageView.mas_right).offset(self.containerInnerBoardSpace);
        make.right.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.container);
        make.height.equalTo(@40);
    }];
    
    [self.container addSubview:self.sepLineView];
    [self.sepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.noticeNameLabel.mas_bottom);
        make.height.equalTo(@1);
    }];
    
    [self.container addSubview:self.noticeTitleLabel];
    [self.noticeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.sepLineView.mas_bottom).offset(self.containerInnerBoardSpace);
        make.bottom.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
    }];
    
}

#pragma mark - lazy

-(UIImageView *)leftIconImageView {
    if(_leftIconImageView == nil) {
        _leftIconImageView = [[UIImageView alloc] init];
        _leftIconImageView.image = [UIImage imageNamed:@"im_notice_icon"];
        _leftIconImageView.userInteractionEnabled = YES;
    }
    return _leftIconImageView;
}

-(UILabel *)noticeNameLabel {
    if(_noticeNameLabel == nil) {
        _noticeNameLabel = [[UILabel alloc] init];
        _noticeNameLabel.font = [UIFont systemFontOfSize:15];
        _noticeNameLabel.textColor = [UIColor blackColor];
        _noticeNameLabel.textAlignment = NSTextAlignmentLeft;
        _noticeNameLabel.numberOfLines = 0;
        _noticeNameLabel.text = NoticeNameStr;
        _noticeNameLabel.userInteractionEnabled = YES;
    }
    return _noticeNameLabel;
}

-(UIView *)sepLineView {
    if(_sepLineView == nil) {
        _sepLineView = [[UIView alloc] init];
        _sepLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _sepLineView.clipsToBounds = YES;
        _sepLineView.layer.cornerRadius = 0.5;
    }
    return _sepLineView;
}

-(UILabel *)noticeTitleLabel {
    if(_noticeTitleLabel == nil) {
        _noticeTitleLabel = [[UILabel alloc] init];
        _noticeTitleLabel.font = [UIFont systemFontOfSize:15];
        _noticeTitleLabel.textColor = [UIColor blackColor];
        _noticeTitleLabel.textAlignment = NSTextAlignmentLeft;
        _noticeTitleLabel.numberOfLines = 5;
        _noticeTitleLabel.userInteractionEnabled = YES;
    }
    return _noticeTitleLabel;
}

@end
