//
//  IM_BottomSelectItemView.m
//  L_Chat
//
//  Created by dzj on 2020/6/5.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_BottomSelectItemView.h"

@interface IM_BottomSelectItemView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) DidClickItem didClickItem;

@end

static CGFloat Bottom_OutSideSpace = 10; // 白色背景到承载视图外边距
static CGFloat Bottom_InnerSpace = 8; // 白色背景到图标内边距

@implementation IM_BottomSelectItemView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadCustomView];
        [self addTapGes];
    }
    return self;
}

#pragma mark - private

-(void)loadCustomView {
    [self addSubview:self.title];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.greaterThanOrEqualTo(@20);
    }];
    
    [self addSubview:self.roundBgView];
    [self.roundBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.lessThanOrEqualTo(self);
        make.left.greaterThanOrEqualTo(self).offset(Bottom_OutSideSpace);
        make.right.lessThanOrEqualTo(self).offset(-(Bottom_OutSideSpace));
        make.top.greaterThanOrEqualTo(self).offset(Bottom_OutSideSpace);
        make.bottom.lessThanOrEqualTo(self.title.mas_top).offset(-(Bottom_OutSideSpace));
        make.height.equalTo(self.roundBgView.mas_width);
    }];
    [self.roundBgView addSubview:self.icon];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.roundBgView);
        make.centerY.lessThanOrEqualTo(self.roundBgView);
        make.left.greaterThanOrEqualTo(self.roundBgView).offset(Bottom_InnerSpace);
        make.right.lessThanOrEqualTo(self.roundBgView).offset(-(Bottom_InnerSpace));
        make.top.greaterThanOrEqualTo(self.roundBgView).offset(Bottom_InnerSpace);
        make.bottom.lessThanOrEqualTo(self.roundBgView.mas_bottom).offset(-(Bottom_InnerSpace));
        make.height.equalTo(self.icon.mas_width);
    }];
}

-(void)addTapGes {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf:)];
    [self addGestureRecognizer:tap];
}

-(void)tapSelf:(UITapGestureRecognizer *)tap {
    if(self.didClickItem) {
        self.didClickItem(self);
    }
}

#pragma mark - public

/// 配置展示数据
/// @param iconUrlStr 图标链接
/// @param title 标题
-(void)loadItemWithIcon:(NSString *)iconUrlStr title:(NSString *)title {
    if(iconUrlStr.length > 0) {
        if([iconUrlStr rangeOfString:@"http"].length > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.icon.hidden = NO;
                    self.icon.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrlStr]]];
                });
            });
        } else if([UIImage imageNamed:iconUrlStr]) {
            self.icon.hidden = NO;
            self.icon.image = [UIImage imageNamed:iconUrlStr];
        } else {
            self.icon.hidden = YES;
        }
    } else {
        self.icon.hidden = YES;
    }
    
    if(title.length > 0) {
        self.title.text = title;
    } else {
        self.title.text = @"";
    }
}

// 配置点击事件回调
-(void)configDidClickItem:(DidClickItem)didClickItem {
    self.didClickItem = didClickItem;
}

#pragma mark - lazy

-(UIView *)roundBgView {
    if(_roundBgView == nil) {
        _roundBgView = [[UIView alloc] init];
        _roundBgView.backgroundColor = [UIColor whiteColor];
        _roundBgView.clipsToBounds = YES;
        _roundBgView.layer.cornerRadius = 4;
        _roundBgView.userInteractionEnabled = YES;
    }
    return _roundBgView;
}

-(UIImageView *)icon {
    if(_icon == nil) {
        _icon = [[UIImageView alloc] init];
        _icon.userInteractionEnabled = YES;
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _icon.backgroundColor = [UIColor clearColor];
    }
    return _icon;
}

-(UILabel *)title {
    if(_title == nil) {
        _title = [[UILabel alloc] init];
        _title.userInteractionEnabled = YES;
        _title.font = [UIFont systemFontOfSize:14];
        _title.textColor = [UIColor grayColor];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.numberOfLines = 2;
    }
    return _title;
}

@end
