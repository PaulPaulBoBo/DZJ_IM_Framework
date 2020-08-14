//
//  IM_HealthRecordTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_HealthRecordTableViewCell.h"

@interface IM_HealthRecordTableViewCell()

@property (nonatomic, strong) UILabel *healthRecordNameLabel; // 标题
@property (nonatomic, strong) UIView *sepLineView; // 分割线
@property (nonatomic, strong) UILabel *healthRecordTitleLabel; // 标题 nickName+"的健康档案"
@property (nonatomic, strong) UIImageView *healthRecordArrowImageView; // 右侧箭头图标

@end

@implementation IM_HealthRecordTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    if(data.healthRecordModel) {
        self.healthRecordNameLabel.text = clearNilStr(data.healthRecordModel.content);
        if(data.nickName != nil && clearNilStr(data.nickName).length > 0) {
            self.healthRecordTitleLabel.text = [NSString stringWithFormat:@"%@的健康档案", data.nickName];
        } else {
            self.healthRecordTitleLabel.text = @"查看健康档案";
        }
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
    [self.container addSubview:self.healthRecordNameLabel];
    [self.healthRecordNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.height.greaterThanOrEqualTo(@40);
    }];
    
    [self.container addSubview:self.sepLineView];
    [self.sepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.healthRecordNameLabel.mas_bottom).offset(self.containerInnerBoardSpace);
        make.height.equalTo(@1);
    }];
    
    [self.container addSubview:self.healthRecordTitleLabel];
    [self.healthRecordTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.sepLineView.mas_bottom).offset(self.containerInnerBoardSpace);
        make.bottom.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
    }];
    
    [self.container addSubview:self.healthRecordArrowImageView];
    [self.healthRecordArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.healthRecordTitleLabel.mas_right).offset(-(self.containerInnerBoardSpace));
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.centerY.equalTo(self.healthRecordTitleLabel);
    }];
}

#pragma mark - lazy

-(UILabel *)healthRecordNameLabel {
    if(_healthRecordNameLabel == nil) {
        _healthRecordNameLabel = [[UILabel alloc] init];
        _healthRecordNameLabel.font = [UIFont systemFontOfSize:15];
        _healthRecordNameLabel.textColor = [UIColor blackColor];
        _healthRecordNameLabel.textAlignment = NSTextAlignmentLeft;
        _healthRecordNameLabel.numberOfLines = 0;
        _healthRecordNameLabel.userInteractionEnabled = YES;
    }
    return _healthRecordNameLabel;
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

-(UILabel *)healthRecordTitleLabel {
    if(_healthRecordTitleLabel == nil) {
        _healthRecordTitleLabel = [[UILabel alloc] init];
        _healthRecordTitleLabel.font = [UIFont systemFontOfSize:15];
        _healthRecordTitleLabel.textColor = [UIColor colorWithHexString:@"0x2dc4c0"];
        _healthRecordTitleLabel.textAlignment = NSTextAlignmentLeft;
        _healthRecordTitleLabel.numberOfLines = 0;
        _healthRecordTitleLabel.userInteractionEnabled = YES;
    }
    return _healthRecordTitleLabel;
}

-(UIImageView *)healthRecordArrowImageView {
    if(_healthRecordArrowImageView == nil) {
        _healthRecordArrowImageView = [[UIImageView alloc] init];
        _healthRecordArrowImageView.image = [UIImage imageNamed:@"arrow_green_right"];
        _healthRecordArrowImageView.userInteractionEnabled = YES;
    }
    return _healthRecordArrowImageView;
}

@end
