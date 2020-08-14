//
//  IM_BottomView.h
//  L_Chat
//
//  Created by dzj on 2020/6/3.
//  Copyright © 2020 paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IM_BottomHeader.h" // 公共头文件
#import "IM_BottomInputView.h" // 输入视图
#import "IM_BottomSelectView.h" // 选择视图

NS_ASSUME_NONNULL_BEGIN

@interface IM_BottomView : UIView

@property (nonatomic, strong) IM_BottomInputView *inputView;
@property (nonatomic, strong) IM_BottomSelectView *selectView;

/// 配置点击代理
/// @param clickSureBtnAction 点击发送按钮回调
/// @param clickSendAction 点击键盘中的发送按钮回调
/// @param clickAddBtnAction 点击加号按钮回调
/// @param clickMoreBtnAction 点击更多按钮回调
/// @param clickMoreBtnAction 点击语音和文字切换按钮回调
-(void)configClickSureBtnAction:(ClickSureBtnAction)clickSureBtnAction
                clickSendAction:(ClickSendAction)clickSendAction
             clickItemBtnAction:(ClickItemBtnAction)clickItemBtnAction
              clickAddBtnAction:(ClickAddBtnAction)clickAddBtnAction
             clickMoreBtnAction:(ClickMoreBtnAction)clickMoreBtnAction
            clickVoiceBtnAction:(ClickVoiceBtnAction)clickVoiceBtnAction;

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

/// 加载其他类型消息入口
/// @param items 其他类型消息数组
-(void)loadSelectItems:(NSArray *)items;

/// 隐藏或展示其他消息类型视图
/// @param isShow 是否展示 YES-展示， NO-隐藏
-(void)refreshSelectView:(BOOL)isShow;

/// 展示或隐藏录音视图
/// @param isShow 是否展示 YES-展示， NO-隐藏
-(void)refreshVoiceView:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
