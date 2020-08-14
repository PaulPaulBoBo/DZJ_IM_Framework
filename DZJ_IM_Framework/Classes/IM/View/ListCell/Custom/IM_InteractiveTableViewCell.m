//
//  IM_InteractiveTableViewCell.m
//  DoctorCloud
//
//  Created by dzj on 2020/7/17.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_InteractiveTableViewCell.h"

@interface IM_InteractiveTableViewCell()

@property (nonatomic, strong) UIView *roundBgView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation IM_InteractiveTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self loadCustomView];
    }
    return self;
}

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    if(data) {
        NSString *msg = @"";
        NSString *iconName = @"";
        if([data.contentType isEqualToString:@"INTERACTION_APPLAUD"]) {
            msg = @"鼓掌喝彩";
            iconName = @"im_applaud_icon";
        } else if([data.contentType isEqualToString:@"INTERACTION_FLOWERS"]) {
            msg = @"送上一束鲜花";
            iconName = @"im_flower_icon";
        } else {
            msg = @"鼓掌喝彩";
            iconName = @"im_applaud_icon";
        }
        self.contentLabel.text = [NSString stringWithFormat:@"%@%@", data.nickName, msg];
        self.iconImageView.image = [UIImage imageNamed:iconName];
    }
}

#pragma mark - private

-(void)loadCustomView {
    [self addSubview:self.roundBgView];
    [self.roundBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self).offset(12);
        make.right.lessThanOrEqualTo(self).offset(-12);
        make.top.equalTo(self).offset(4.5);
        make.bottom.equalTo(self).offset(-4.5);
    }];
    
    [self.roundBgView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.roundBgView).offset(-12);
        make.top.equalTo(self.roundBgView).offset(2);
        make.bottom.equalTo(self.roundBgView).offset(-2);
        make.height.width.equalTo(@(17));
    }];
    
    [self.roundBgView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.roundBgView).offset(12);
        make.right.equalTo(self.iconImageView.mas_left).offset(-6);
        make.top.equalTo(self).offset(2);
        make.bottom.equalTo(self).offset(-2);
    }];
}

#pragma mark - lazy

-(UIView *)roundBgView {
    if(_roundBgView == nil) {
        _roundBgView = [[UIView alloc] init];
        _roundBgView.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
        _roundBgView.clipsToBounds = YES;
        _roundBgView.layer.cornerRadius = 10.5;
    }
    return _roundBgView;
}

-(UILabel *)contentLabel {
    if(_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.numberOfLines = 1;
        _contentLabel.userInteractionEnabled = YES;
    }
    return _contentLabel;
}

-(UIImageView *)iconImageView {
    if(_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"im_flower_icon"];
        _iconImageView.userInteractionEnabled = YES;
    }
    return _iconImageView;
}

@end
