//
//  IM_BottomView.m
//  L_Chat
//
//  Created by dzj on 2020/6/3.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_BottomView.h"

@interface IM_BottomView()

@property (nonatomic, strong) ClickSureBtnAction clickSureBtnAction;
@property (nonatomic, strong) ClickSendAction clickSendAction;
@property (nonatomic, strong) ClickItemBtnAction clickItemBtnAction;
@property (nonatomic, strong) ClickAddBtnAction clickAddBtnAction;
@property (nonatomic, strong) ClickMoreBtnAction clickMoreBtnAction;
@property (nonatomic, strong) ClickVoiceBtnAction clickVoiceBtnAction;

@property (nonatomic, strong) TextViewDidBeginEdit textViewDidBeginEdit;
@property (nonatomic, strong) TextViewDidEditing textViewDidEditing;
@property (nonatomic, strong) TextViewDidEndEdit textViewDidEndEdit;

@property (nonatomic, strong) StartVoice startVoice;
@property (nonatomic, strong) CancelVoice cancelVoice;
@property (nonatomic, strong) FinishVoice finishVoice;

@property (nonatomic, strong) UIView *inputBgView;
@property (nonatomic, strong) UIView *selectBgView;

@end

@implementation IM_BottomView

#pragma mark - public

/// 配置点击回调
-(void)configClickSureBtnAction:(ClickSureBtnAction)clickSureBtnAction
                clickSendAction:(ClickSendAction)clickSendAction
             clickItemBtnAction:(ClickItemBtnAction)clickItemBtnAction
              clickAddBtnAction:(ClickAddBtnAction)clickAddBtnAction
             clickMoreBtnAction:(ClickMoreBtnAction)clickMoreBtnAction
            clickVoiceBtnAction:(ClickVoiceBtnAction)clickVoiceBtnAction {
    self.clickSureBtnAction = clickSureBtnAction;
    self.clickSendAction = clickSendAction;
    self.clickItemBtnAction = clickItemBtnAction;
    self.clickAddBtnAction = clickAddBtnAction;
    self.clickMoreBtnAction = clickMoreBtnAction;
    self.clickVoiceBtnAction = clickVoiceBtnAction;
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

// 加载其他类型消息入口
-(void)loadSelectItems:(NSArray *)items {
    [self.selectView loadCustomeViewWithItems:items];
}

// 隐藏或展示其他消息类型视图
-(void)refreshSelectView:(BOOL)isShow {
    [self.selectView refreshSelectView:isShow];
}

// 展示或隐藏录音视图
-(void)refreshVoiceView:(BOOL)isShow {
    [self.inputView updateVoiceInputView:isShow];
}

// 配置是否展示更多按钮
-(void)configisShowMore:(BOOL)isShowMore {
    [self.inputView configisShowMore:isShowMore];
}

#pragma mark - life
- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        [self loadCustomView];
        [self loadViewBlock];
    }
    return self;
}

#pragma mark - private

-(void)loadCustomView {
    [self addSubview:self.inputBgView];
    [self.inputBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
    }];
    
    [self.inputBgView addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.inputBgView);
    }];
    
    [self addSubview:self.selectBgView];
    [self.selectBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.inputBgView.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    [self.selectBgView addSubview:self.selectView];
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.selectBgView);
    }];
}

-(void)loadViewBlock {
    [self.inputView configClickVoiceAction:^{
        // 语音点击回调
        if(self.clickVoiceBtnAction) {
            self.clickVoiceBtnAction();
        }
    } clickSureBtnAction:^(NSString *text) {
        if(self.clickSureBtnAction) {
            self.clickSureBtnAction(text);
        }
    } clickAddBtnAction:^{
        // 加号点击回调
        if(self.clickAddBtnAction) {
            self.clickAddBtnAction();
        }
    } clickMoreBtnAction:^{
        // 更多点击回调
        if(self.clickMoreBtnAction) {
            self.clickMoreBtnAction();
        }
    } clickSendAction:^(NSString *text) {
        if(self.clickSendAction) {
            self.clickSendAction(text);
        }
    }];
    
    [self.inputView configTextViewDidBeginEdit:^(UITextView *textView) {
        if(self.textViewDidBeginEdit) {
            self.textViewDidBeginEdit(textView);
        }
    } textViewDidEditing:^(UITextView *textView) {
        if(self.textViewDidEditing) {
            self.textViewDidEditing(textView);
        }
    } textViewDidEndEdit:^(UITextView *textView) {
        if(self.textViewDidEndEdit) {
            self.textViewDidEndEdit(textView);
        }
    }];
    
    [self.inputView configStartVoice:^{
        if(self.startVoice) {
            self.startVoice();
        }
    } cancelVoice:^{
        if(self.cancelVoice) {
            self.cancelVoice();
        }
    } finishVoice:^(id  _Nonnull voiceData, CGFloat duration) {
        if(self.finishVoice) {
            self.finishVoice(voiceData, duration);
        }
    }];
}

#pragma mark - lazy

-(UIView *)inputBgView {
    if(_inputBgView == nil) {
        _inputBgView = [[UIView alloc] init];
        _inputBgView.clipsToBounds = YES;
    }
    return _inputBgView;
}

-(IM_BottomInputView *)inputView {
    if(_inputView == nil) {
        _inputView = [[IM_BottomInputView alloc] init];
        [_inputView canSendByReturnKey:YES];
    }
    return _inputView;
}

-(UIView *)selectBgView {
    if(_selectBgView == nil) {
        _selectBgView = [[UIView alloc] init];
        _selectBgView.clipsToBounds = YES;
    }
    return _selectBgView;
}

-(IM_BottomSelectView *)selectView {
    if(_selectView == nil) {
        _selectView = [[IM_BottomSelectView alloc] init];
        [_selectView configDidSelectItemInCollectionView:^(NSInteger index) {
            if(self.clickItemBtnAction) {
                self.clickItemBtnAction(index);
            }
        }];
        
    }
    return _selectView;
}

@end
