//
//  IM_ShowNoticeView.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/29.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_ShowNoticeView.h"
#import "DZJLabel.h"

@interface IM_ShowNoticeView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *whiteBgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) DZJLabel *contentLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *readedBtn;

@property (nonatomic, strong) DidClickReadBtnBlock didClickReadBtnBlock;

@end

@implementation IM_ShowNoticeView

#pragma mark - Public

// 弹出公告视图
-(void)showNoticeWithTitle:(NSString *)title content:(NSString *)content didClickReadBtnBlock:(DidClickReadBtnBlock)didClickReadBtnBlock {
    if(clearNilStr(title).length > 0) {
        self.titleLabel.text = title;
    } else {
        self.titleLabel.text = @"";
    }
    
    if(clearNilStr(content).length > 0) {
        [self.contentLabel loadHtmlText:content withLineSpacing:5];
    } else {
        self.contentLabel.text = @"";
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
        self.window.alpha = 1;
    }];
    self.didClickReadBtnBlock = didClickReadBtnBlock;
}

// 移除公告视图
-(void)hiddenNotice {
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        self.window.alpha = 0;
    }];
}

#pragma mark - Private

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.16];
        
        [self.window addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.window);
        }];
        
        [self.window bringSubviewToFront:self];
        
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.whiteBgView];
    [self.whiteBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.window).mas_offset(40);
        make.right.equalTo(self.window).mas_offset(-40);
        make.centerY.equalTo(self.mas_centerY);
    }];
    [self addTapGestureToWhiteBgView];
    
    [self.whiteBgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.whiteBgView.mas_centerX);
        make.top.equalTo(self.whiteBgView).mas_offset(16);
        make.height.mas_equalTo(22.5);
    }];
    
    [self.whiteBgView addSubview:self.readedBtn];
    [self.readedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteBgView);
        make.height.mas_equalTo(48);
        make.bottom.equalTo(self.whiteBgView.mas_bottom);
    }];
    
    [self.whiteBgView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteBgView);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(self.readedBtn.mas_top);
    }];
    
    [self.whiteBgView addSubview:self.contentScrollView];
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.whiteBgView).mas_offset(20);
        make.right.equalTo(self.whiteBgView).mas_offset(-20);
        make.bottom.equalTo(self.lineView.mas_top).offset(-20);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(20);
        make.height.greaterThanOrEqualTo(@(48));
        make.height.lessThanOrEqualTo(@(264));
    }];
    
    [self.contentScrollView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView.mas_width);
        make.height.equalTo(self.contentScrollView.mas_height);
    }];
}

-(void)addTapGestureToWhiteBgView {
    UITapGestureRecognizer *tapWhiteBgView = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        
    }];
    [self.whiteBgView addGestureRecognizer:tapWhiteBgView];
}

-(void)readedBtnAction {
    if(self.didClickReadBtnBlock) {
        self.didClickReadBtnBlock();
    }
    [self hiddenNotice];
}

#pragma mark - lazy

-(UIWindow *)window {
    if(_window == nil) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_window makeKeyAndVisible];
        _window.backgroundColor = [UIColor clearColor];
    }
    return _window;
}

-(UIView *)whiteBgView {
    if(_whiteBgView == nil) {
        _whiteBgView = [[UIView alloc] init];
        _whiteBgView.backgroundColor = [UIColor whiteColor];
        [_whiteBgView round:4];
    }
    return _whiteBgView;
}

-(UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = [UIFont systemFontOfSize:17 weight:(UIFontWeightBold)];
    }
    return _titleLabel;
}

-(UIScrollView *)contentScrollView {
    if(_contentScrollView == nil) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _contentScrollView;
}

-(DZJLabel *)contentLabel {
    if(_contentLabel == nil) {
        _contentLabel = [[DZJLabel alloc] init];
        _contentLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

-(UIView *)lineView {
    if(_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#e7e7e7"];
    }
    return _lineView;
}

-(UIButton *)readedBtn {
    if(_readedBtn == nil) {
        _readedBtn = [[UIButton alloc] init];
        [_readedBtn setTitle:@"我知道了" forState:(UIControlStateNormal)];
        [_readedBtn.titleLabel setFont:[UIFont systemFontOfSize:16 weight:(UIFontWeightBold)]];
        [_readedBtn setTitleColor:[UIColor colorWithHexString:@"#109C9A"] forState:(UIControlStateNormal)];
        [_readedBtn addTarget:self action:@selector(readedBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _readedBtn;
}

@end
