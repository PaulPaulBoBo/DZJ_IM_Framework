//
//  IM_BasicLinkCellTableViewCell.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/18.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_BasicLinkCellTableViewCell.h"

@implementation IM_BasicLinkCellTableViewCell

#pragma mark - public

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    // 由子类填充数据
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

-(void)loadCustomView {
    [self.container addSubview:self.linkTitleLabel];
    [self.linkTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.top.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.bottom.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
    }];
    
    [self.container addSubview:self.linkSubTitleLabel];
    [self.linkSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.top.equalTo(self.linkTitleLabel.mas_bottom).offset(self.containerInnerBoardSpace);
        make.bottom.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
    }];

    [self.container addSubview:self.linkImage];
    [self.linkImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.linkTitleLabel.mas_right).offset(self.containerInnerBoardSpace);
        make.left.equalTo(self.linkSubTitleLabel.mas_right).offset(self.containerInnerBoardSpace);
        make.top.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.bottom.lessThanOrEqualTo(self.container).offset(-self.containerInnerBoardSpace);
        make.height.equalTo(@60);
        make.width.equalTo(@60);
    }];
    
}

#pragma mark - lazy

-(UIImageView *)linkImage {
    if(_linkImage == nil) {
        _linkImage = [[UIImageView alloc] init];
        _linkImage.clipsToBounds = YES;
        _linkImage.layer.cornerRadius = 8;
        _linkImage.contentMode = UIViewContentModeScaleAspectFill;
        _linkImage.userInteractionEnabled = YES;
    }
    return _linkImage;
}

-(UILabel *)linkTitleLabel {
    if(_linkTitleLabel == nil) {
        _linkTitleLabel = [[UILabel alloc] init];
        _linkTitleLabel.font = [UIFont systemFontOfSize:15];
        _linkTitleLabel.textColor = [UIColor blackColor];
        _linkTitleLabel.textAlignment = NSTextAlignmentLeft;
        _linkTitleLabel.numberOfLines = 3;
        _linkTitleLabel.userInteractionEnabled = YES;
    }
    return _linkTitleLabel;
}

-(UILabel *)linkSubTitleLabel {
    if(_linkSubTitleLabel == nil) {
        _linkSubTitleLabel = [[UILabel alloc] init];
        _linkSubTitleLabel.font = [UIFont systemFontOfSize:13];
        _linkSubTitleLabel.textColor = [UIColor grayColor];
        _linkSubTitleLabel.textAlignment = NSTextAlignmentLeft;
        _linkSubTitleLabel.numberOfLines = 3;
        _linkSubTitleLabel.userInteractionEnabled = YES;
    }
    return _linkSubTitleLabel;
}
@end
