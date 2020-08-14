//
//  IM_MSLTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_MSLTableViewCell.h"

@interface IM_MSLTableViewCell()

@property (nonatomic, strong) UIImageView *leftIconImageView; // 左侧图标
@property (nonatomic, strong) UILabel *mslNameLabel; // 固定的“宣讲日志”标题
@property (nonatomic, strong) UIView *sepLineView; // 分割线
@property (nonatomic, strong) UILabel *mslTitleLabel; // 标题
@property (nonatomic, strong) UILabel *mslTimeLabel; // 时间标签
@property (nonatomic, strong) UIStackView *mslImagesContainerView; // 图片承载视图

@end

static NSInteger MSLColume = 3; // 每行几张图片
static NSString *MSLNameStr = @"宣讲日志";

@implementation IM_MSLTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    if(data.mslModel) {
        self.mslTitleLabel.text = clearNilStr(data.mslModel.preachTheme);
        self.mslTimeLabel.text = [NSDate stringYearMonthDayWithDate:data.mslModel.preachTime];
        [self loadMSLImages:data.mslModel.preachAttachment];
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
    
    [self.container addSubview:self.mslNameLabel];
    [self.mslNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftIconImageView.mas_right).offset(self.containerInnerBoardSpace);
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.container);
        make.height.equalTo(@40);
    }];
    
    [self.container addSubview:self.sepLineView];
    [self.sepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.mslNameLabel.mas_bottom);
        make.height.equalTo(@1);
        make.width.greaterThanOrEqualTo(@125);
    }];
    
    [self.container addSubview:self.mslTitleLabel];
    [self.mslTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.sepLineView.mas_bottom).offset(self.containerInnerBoardSpace);
    }];
    
    [self.container addSubview:self.mslTimeLabel];
    [self.mslTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.mslTitleLabel.mas_bottom).offset(self.containerInnerBoardSpace/2.0);
    }];
    
    [self.container addSubview:self.mslImagesContainerView];
    [self.mslImagesContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.mslTimeLabel.mas_bottom).offset(self.containerInnerBoardSpace);
        make.bottom.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.height.greaterThanOrEqualTo(@0);
        make.height.lessThanOrEqualTo(@80);
    }];
}

/// 加载MSL图片数组
-(void)loadMSLImages:(NSArray *)images {
    [self.mslImagesContainerView removeAllSubviews];
    if(images.count > 0) {
        NSInteger maxCount = images.count > MSLColume ? MSLColume : images.count;
        for (int i = 0; i < maxCount; i++) {
            UIImageView *imageView = [self createSingleImage:clearNilStr(images[i])];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@60);
            }];
            if(images.count > maxCount && i == maxCount-1) {
                [self addMoreImageNumLabel:images.count-maxCount lastView:imageView];
            }
            if(imageView) {
                [self.mslImagesContainerView addArrangedSubview:imageView];
            }
        }
    } else {
        if(self.mslImagesContainerView.superview == nil) {
            [self.container addSubview:self.mslImagesContainerView];
        }
        [self.mslImagesContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mslTimeLabel.mas_bottom);
            make.bottom.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        }];
    }
}

// 添加更多图片数字蒙层
-(void)addMoreImageNumLabel:(NSInteger)num lastView:(UIView *)lastview {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    label.text = [NSString stringWithFormat:@"+%ld", num];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    
    [lastview addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(lastview);
    }];
}

// 创建单个图片视图
-(UIImageView *)createSingleImage:(NSString *)imageUrlStr {
    if(imageUrlStr == nil || clearNilStr(imageUrlStr).length == 0) {
        return nil;
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView loadImageWithURL:imageUrlStr];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 8;
    return imageView;
}

#pragma mark - lazy

-(UIImageView *)leftIconImageView {
    if(_leftIconImageView == nil) {
        _leftIconImageView = [[UIImageView alloc] init];
        _leftIconImageView.image = [UIImage imageNamed:@"im_msl_icon"];
        _leftIconImageView.userInteractionEnabled = YES;
    }
    return _leftIconImageView;
}

-(UILabel *)mslNameLabel {
    if(_mslNameLabel == nil) {
        _mslNameLabel = [[UILabel alloc] init];
        _mslNameLabel.font = [UIFont systemFontOfSize:15];
        _mslNameLabel.textColor = [UIColor blackColor];
        _mslNameLabel.textAlignment = NSTextAlignmentLeft;
        _mslNameLabel.numberOfLines = 0;
        _mslNameLabel.text = MSLNameStr;
        _mslNameLabel.userInteractionEnabled = YES;
    }
    return _mslNameLabel;
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

-(UILabel *)mslTitleLabel {
    if(_mslTitleLabel == nil) {
        _mslTitleLabel = [[UILabel alloc] init];
        _mslTitleLabel.font = [UIFont systemFontOfSize:15];
        _mslTitleLabel.textColor = [UIColor blackColor];
        _mslTitleLabel.textAlignment = NSTextAlignmentLeft;
        _mslTitleLabel.numberOfLines = 0;
        _mslTitleLabel.userInteractionEnabled = YES;
    }
    return _mslTitleLabel;
}

-(UILabel *)mslTimeLabel {
    if(_mslTimeLabel == nil) {
        _mslTimeLabel = [[UILabel alloc] init];
        _mslTimeLabel.font = [UIFont systemFontOfSize:13];
        _mslTimeLabel.textColor = [UIColor grayColor];
        _mslTimeLabel.textAlignment = NSTextAlignmentLeft;
        _mslTimeLabel.numberOfLines = 0;
        _mslTimeLabel.userInteractionEnabled = YES;
    }
    return _mslTimeLabel;
}

-(UIStackView *)mslImagesContainerView {
    if(_mslImagesContainerView == nil) {
        _mslImagesContainerView = [[UIStackView alloc] init];
        _mslImagesContainerView.clipsToBounds = YES;
        _mslImagesContainerView.axis = UILayoutConstraintAxisHorizontal;
        _mslImagesContainerView.distribution = UIStackViewDistributionFillProportionally;
        _mslImagesContainerView.spacing = 5;
        _mslImagesContainerView.layer.cornerRadius = 8;
        _mslImagesContainerView.userInteractionEnabled = YES;
    }
    return _mslImagesContainerView;
}

@end
