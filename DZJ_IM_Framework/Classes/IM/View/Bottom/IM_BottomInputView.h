//
//  IM_BottomInputView.h
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IM_BottomHeader.h" // 公共头文件
#import "IM_VoiceView.h" // 语音操作视图

NS_ASSUME_NONNULL_BEGIN

@interface IM_BottomInputView : UIView

@property (nonatomic, strong) UIView *inputBgView; // 输入背景视图
@property (nonatomic, strong) UIView *textBorderView; // 输入框边框视图
@property (nonatomic, strong) IM_TextView *textView; // 输入框
@property (nonatomic, strong) UIButton *voiceBtn; // 语音按钮
@property (nonatomic, strong) IM_VoiceView *voiceView; // 语音操作视图
@property (nonatomic, strong) UIButton *sureBtn; // 发送按钮
@property (nonatomic, strong) UIButton *addBtn; // +号按钮，展开或隐藏其他类型消息选择视图
@property (nonatomic, strong) UIButton *moreBtn; // ...号按钮，展开或隐藏其他类型消息选择视图

/// 配置点击代理
/// @param clickVoiceAction 点击语音按钮回调
/// @param clickSureBtnAction 点击发送按钮回调
/// @param clickAddBtnAction 点击加号按钮回调
/// @param clickMoreBtnAction 点击更多按钮回调
/// @param clickSendAction 点击键盘中的发送按钮回调
-(void)configClickVoiceAction:(ClickVoiceBtnAction)clickVoiceAction
           clickSureBtnAction:(ClickSureBtnAction)clickSureBtnAction
            clickAddBtnAction:(ClickAddBtnAction)clickAddBtnAction
           clickMoreBtnAction:(ClickMoreBtnAction)clickMoreBtnAction
              clickSendAction:(ClickSendAction)clickSendAction;

/// 配置输入框变化代理
/// @param textViewDidBeginEdit 开始编辑回调
/// @param textViewDidEditing 正在编辑回调
/// @param textViewDidEndEdit 结束编辑回调
-(void)configTextViewDidBeginEdit:(TextViewDidBeginEdit)textViewDidBeginEdit
               textViewDidEditing:(TextViewDidEditing)textViewDidEditing
               textViewDidEndEdit:(TextViewDidEndEdit)textViewDidEndEdit;

/// 配置语音状态回调
/// @param startVoice 开始说话
/// @param cancelVoice 取消语音录制
/// @param finishVoice 完成语音录制
-(void)configStartVoice:(StartVoice)startVoice
            cancelVoice:(CancelVoice)cancelVoice
            finishVoice:(FinishVoice)finishVoice;

/// 配置是否展示更多按钮
/// @param isShowMore 是否展示 YES-展示 NO-不展示
-(void)configisShowMore:(BOOL)isShowMore;

/// 是否使用键盘内发送键发送消息
/// @param canSendByReturnKey 是否使用键盘内发送键发送消息
-(void)canSendByReturnKey:(BOOL)canSendByReturnKey;

/// 更新语音视图显隐
/// @param isShow 是否展示 YES-展示 NO-隐藏
-(void)updateVoiceInputView:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
