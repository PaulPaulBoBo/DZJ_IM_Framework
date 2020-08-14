//
//  IM_BottomInputView.m
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_BottomInputView.h"
#import "objc/runtime.h"

@interface IM_BottomInputView()<UITextViewDelegate>

@property (nonatomic, strong) ClickVoiceBtnAction clickVoiceBtnAction;
@property (nonatomic, strong) ClickSureBtnAction clickSureBtnAction;
@property (nonatomic, strong) ClickAddBtnAction clickAddBtnAction;
@property (nonatomic, strong) ClickMoreBtnAction clickMoreBtnAction;
@property (nonatomic, strong) ClickSendAction clickSendAction;

@property (nonatomic, strong) TextViewDidBeginEdit textViewDidBeginEdit;
@property (nonatomic, strong) TextViewDidEditing textViewDidEditing;
@property (nonatomic, strong) TextViewDidEndEdit textViewDidEndEdit;

@property (nonatomic, strong) StartVoice startVoice;
@property (nonatomic, strong) CancelVoice cancelVoice;
@property (nonatomic, strong) FinishVoice finishVoice;

@end

static BOOL CanSendByReturnKey = NO;
static CGFloat SendBtnWidth = 80;
static CGFloat BtnHeight = 44;
static CGFloat InputViewMinHeight = 34;
static CGFloat InputViewMaxHeight = 68;
static NSString *IsShowVoiceKey = @"IsShowVoiceBtn";
static CGFloat LefRightSpace = 1;
static CGFloat TopBottomSpace = 10;

@implementation IM_BottomInputView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self loadCustomView];
    }
    return self;
}

#pragma mark - public

/// 配置点击回调
-(void)configClickVoiceAction:(ClickVoiceBtnAction)clickVoiceBtnAction
           clickSureBtnAction:(ClickSureBtnAction)clickSureBtnAction
            clickAddBtnAction:(ClickAddBtnAction)clickAddBtnAction
           clickMoreBtnAction:(ClickMoreBtnAction)clickMoreBtnAction
              clickSendAction:(ClickSendAction)clickSendAction {
    self.clickVoiceBtnAction = clickVoiceBtnAction;
    self.clickSureBtnAction = clickSureBtnAction;
    self.clickAddBtnAction = clickAddBtnAction;
    self.clickMoreBtnAction = clickMoreBtnAction;
    self.clickSendAction = clickSendAction;
}

// 配置输入框变化回调
-(void)configTextViewDidBeginEdit:(TextViewDidBeginEdit)textViewDidBeginEdit
               textViewDidEditing:(TextViewDidEditing)textViewDidEditing
               textViewDidEndEdit:(TextViewDidEndEdit)textViewDidEndEdit {
    self.textViewDidBeginEdit = textViewDidBeginEdit;
    self.textViewDidEditing = textViewDidEditing;
    self.textViewDidEndEdit = textViewDidEndEdit;
}

/// 配置语音状态回调
-(void)configStartVoice:(StartVoice)startVoice
            cancelVoice:(CancelVoice)cancelVoice
            finishVoice:(FinishVoice)finishVoice {
    self.startVoice = startVoice;
    self.cancelVoice = cancelVoice;
    self.finishVoice = finishVoice;
}

// 是否使用键盘内发送键发送消息
-(void)canSendByReturnKey:(BOOL)canSendByReturnKey {
    CanSendByReturnKey = canSendByReturnKey;
    if(self.sureBtn.superview != nil) {
        [self updateCanSendByReturnKey:canSendByReturnKey];
    }
}

// 更新语音视图显隐
-(void)updateVoiceInputView:(BOOL)isShow {
    if(self.clickVoiceBtnAction) {
        self.clickVoiceBtnAction();
    }
    [self.textView resignFirstResponder];
    if(!isShow) {
        [self.voiceBtn setImage:[UIImage imageNamed:@"im_voicing"] forState:(UIControlStateNormal)];
    } else {
        [self.voiceBtn setImage:[UIImage imageNamed:@"im_voice"] forState:(UIControlStateNormal)];
    }
    [self.voiceView setHidden:isShow];
    [[NSUserDefaults standardUserDefaults] setBool:isShow forKey:IsShowVoiceKey];
}

// 配置是否展示更多按钮
-(void)configisShowMore:(BOOL)isShowMore {
    if(self.moreBtn.superview != nil) {
        [self.moreBtn removeFromSuperview];
    }
    if(!isShowMore) {
        if(self.addBtn.superview == nil) {
            [self addSubview:self.addBtn];
        }
        [self.addBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-LefRightSpace);
        }];
    } else {
        if(self.moreBtn.superview == nil) {
            [self addSubview:self.moreBtn];
        }
        [self.moreBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-LefRightSpace);
            make.top.equalTo(self).offset(TopBottomSpace);
            make.height.equalTo(@(BtnHeight));
            make.width.equalTo(@(BtnHeight));
        }];
        
        if(self.addBtn.superview == nil) {
            [self addSubview:self.addBtn];
        }
        [self.addBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.moreBtn.mas_left).offset(-LefRightSpace);
            make.top.equalTo(self).offset(TopBottomSpace);
            make.height.equalTo(@(BtnHeight));
            make.width.equalTo(@(BtnHeight));
        }];
    }
    [self.superview layoutIfNeeded];
}

#pragma mark - private
-(void)loadCustomView {
    // 语音按钮
    [self addSubview:self.voiceBtn];
    [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(LefRightSpace);
        make.top.equalTo(self).offset(TopBottomSpace);
        make.height.equalTo(@(BtnHeight));
        make.width.equalTo(@(BtnHeight));
    }];
    
    // 更多按钮
    [self addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(LefRightSpace);
        make.top.equalTo(self).offset(TopBottomSpace);
        make.height.equalTo(@(BtnHeight));
        make.width.equalTo(@(BtnHeight));
    }];
    
    // 加号按钮
    [self addSubview:self.addBtn];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.moreBtn.mas_left).offset(-LefRightSpace);
        make.top.equalTo(self).offset(TopBottomSpace);
        make.height.equalTo(@(BtnHeight));
        make.width.equalTo(@(BtnHeight));
    }];
    
    // 输入背景视图
    [self addSubview:self.inputBgView];
    [self.inputBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.voiceBtn.mas_right).offset(LefRightSpace);
        make.right.equalTo(self.addBtn.mas_left).offset(-LefRightSpace);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.bottom.lessThanOrEqualTo(self).offset(-TopBottomSpace);
    }];
    
    // 发送按钮
    [self.inputBgView addSubview:self.sureBtn];
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.inputBgView).offset(-LefRightSpace);
        make.top.equalTo(self.inputBgView).offset(TopBottomSpace);
        make.height.equalTo(@(BtnHeight));
        make.width.equalTo(@(SendBtnWidth));
    }];
    
    // 输入边框视图
    [self.inputBgView addSubview:self.textBorderView];
    [self.textBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.voiceBtn.mas_right).offset(LefRightSpace);
        make.right.equalTo(self.sureBtn.mas_left).offset(-LefRightSpace);
        make.top.equalTo(self.inputBgView).offset(TopBottomSpace);
        make.bottom.equalTo(self.inputBgView).offset(-TopBottomSpace);
    }];
    
    // 输入视图
    [self.textBorderView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.with.insets(UIEdgeInsetsMake(5, 5, 5, 5));
        make.height.equalTo(@(InputViewMinHeight));
    }];
    
    // 语音操作视图
    [self.textBorderView addSubview:self.voiceView];
    [self.voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.textBorderView);
        make.top.bottom.equalTo(self.textBorderView);
    }];
    
    [self updateCanSendByReturnKey:CanSendByReturnKey];
    [self updateVoiceInputView:[[NSUserDefaults standardUserDefaults] boolForKey:IsShowVoiceKey]];
}

-(void)updateCanSendByReturnKey:(BOOL)canSendByReturnKey {
    if(canSendByReturnKey) {
        [self.inputBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.addBtn.mas_left);
        }];
        [self.sureBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.inputBgView);
            make.top.equalTo(self.inputBgView);
            make.height.equalTo(@0);
            make.width.equalTo(@0);
        }];
        self.textView.returnKeyType = UIReturnKeySend;
    } else {
        [self.inputBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.addBtn.mas_left).offset(-LefRightSpace);
        }];
        [self.sureBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.inputBgView).offset(-LefRightSpace);
            make.top.equalTo(self.inputBgView).offset(TopBottomSpace);
            make.height.equalTo(@(BtnHeight));
            make.width.equalTo(@(SendBtnWidth));
        }];
        self.textView.returnKeyType = UIReturnKeyDefault;
    }
    [self layoutIfNeeded];
}

// 语音按钮点击事件
-(void)voiceBtnAction:(UIButton *)sender {
    [self updateVoiceInputView:!self.voiceView.hidden];
}

// 发送按钮点击事件
-(void)sureBtnAction:(UIButton *)sender {
    [self sendMsg];
}

// 加号按钮点击事件
-(void)addBtnAction:(UIButton *)sender {
    if(self.clickAddBtnAction) {
        self.clickAddBtnAction();
    }
}

// 更多按钮点击事件
-(void)moreBtnAction:(UIButton *)sender {
    if(self.clickMoreBtnAction) {
        self.clickMoreBtnAction();
    }
}

// 发送消息回调
-(void)sendMsg {
    if(CanSendByReturnKey) {
        if(self.clickSureBtnAction) {
            self.clickSureBtnAction(self.textView.text);
        }
    } else {
        if(self.clickSureBtnAction) {
            self.clickSureBtnAction(self.textView.text);
        }
    }
    self.textView.text = @"";
    self.sureBtn.enabled = NO;
    [self updateTextView];
}

// 更新输入框高度
-(void)updateTextView {
    if(self.textView.superview != nil) {
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            CGRect frame = self.textView.frame;
            CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
            CGSize size = [self.textView sizeThatFits:constraintSize];
            if(size.height > CGFLOAT_MIN && size.height <= InputViewMaxHeight) {
                make.height.equalTo(@(size.height));
            } else {
                make.height.equalTo(@(InputViewMaxHeight));
            }
        }];
    }
}

// 刷新按钮状态
-(void)refreshCanSendState {
    if(self.textView.text.length > 0) {
        self.sureBtn.enabled = YES;
    } else {
        self.sureBtn.enabled = NO;
    }
}

#pragma mark - delegate

// 开始编辑代理方法
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self updateCanSendByReturnKey:CanSendByReturnKey];
    if(self.textViewDidBeginEdit) {
        self.textViewDidBeginEdit(textView);
    }
}

// 结束编辑代理方法
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self updateCanSendByReturnKey:CanSendByReturnKey];
    [self refreshCanSendState];
    if(self.textViewDidEndEdit) {
        self.textViewDidEndEdit(textView);
    }
}

// 正在编辑代理方法
- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = textView.markedTextRange;
    // 避免走两次回调
    if (selectedRange == nil || selectedRange.empty) {
        [self updateCanSendByReturnKey:CanSendByReturnKey];
        [self refreshCanSendState];
        [self updateTextView];
        if(self.textViewDidEditing) {
            self.textViewDidEditing(textView);
        }
    } else {
        return;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(textView.returnKeyType == UIReturnKeySend) {
        if ([text isEqualToString:@"\n"]) {
            [self sendMsg];
            return NO;//这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
        }
    }
    
    return YES;
}

#pragma mark - lazy

-(UIView *)inputBgView {
    if(_inputBgView == nil) {
        _inputBgView = [[UIView alloc] init];
        _inputBgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _inputBgView;
}

-(UIView *)textBorderView {
    if(_textBorderView == nil) {
        _textBorderView = [[UIView alloc] init];
        _textBorderView.backgroundColor = [UIColor whiteColor];
        _textBorderView.clipsToBounds = YES;
        _textBorderView.layer.cornerRadius = 5;
        _textBorderView.layer.borderColor = [UIColor whiteColor].CGColor;
        _textBorderView.layer.borderWidth = 1;
    }
    return _textBorderView;
}

-(IM_TextView *)textView {
    if(_textView == nil) {
        _textView = [[IM_TextView alloc] init];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.returnKeyType = UIReturnKeySend;
    }
    return _textView;
}

-(UIButton *)addBtn {
    if(_addBtn == nil) {
        _addBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_addBtn setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_addBtn setImage:[UIImage imageNamed:@"im_add"] forState:(UIControlStateNormal)];
        [_addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _addBtn;
}

-(UIButton *)moreBtn {
    if(_moreBtn == nil) {
        _moreBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_moreBtn setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_moreBtn setImage:[UIImage imageNamed:@"im_more"] forState:(UIControlStateNormal)];
        [_moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _moreBtn;
}

-(UIButton *)sureBtn {
    if(_sureBtn == nil) {
        _sureBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_sureBtn setTitle:@"发送" forState:(UIControlStateNormal)];
        [_sureBtn setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.5] forState:(UIControlStateNormal)];
        [_sureBtn setTitleColor:[UIColor lightTextColor] forState:(UIControlStateDisabled)];
        [_sureBtn setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_sureBtn setEnabled:NO];
    }
    return _sureBtn;
}

-(UIButton *)voiceBtn {
    if(_voiceBtn == nil) {
        _voiceBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_voiceBtn setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_voiceBtn setImage:[UIImage imageNamed:@"IM_voice"] forState:(UIControlStateNormal)];
        [_voiceBtn addTarget:self action:@selector(voiceBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _voiceBtn;
}

-(IM_VoiceView *)voiceView {
    if(_voiceView == nil) {
        _voiceView = [[IM_VoiceView alloc] init];
        _voiceView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        [_voiceView configStartVoice:^{
            NSLog(@"开始录音");
            if(self.startVoice) {
                self.startVoice();
            }
        } cancelVoice:^{
            NSLog(@"取消录音");
            if(self.cancelVoice) {
                self.cancelVoice();
            }
        } finishVoice:^(id  _Nonnull voiceData, CGFloat duration) {
            NSLog(@"结束录音");
            if(self.finishVoice) {
                self.finishVoice(voiceData, duration);
            }
        }];
    }
    return _voiceView;
}

@end
