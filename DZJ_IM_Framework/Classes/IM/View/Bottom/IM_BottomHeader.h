//
//  IM_BottomHeader.h
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#ifndef IM_BottomHeader_h
#define IM_BottomHeader_h

#import "IM_TextView.h" // 定制输入视图

typedef void(^ClickVoiceBtnAction)(void); // 点击语音按钮回调
typedef void(^ClickSureBtnAction)(NSString *text); // 点击发送按钮回调
typedef void(^ClickAddBtnAction)(void); // 点击加号按钮回调
typedef void(^ClickMoreBtnAction)(void); // 点击更多按钮回调
typedef void(^ClickItemBtnAction)(NSInteger selectIndex); // 点击选择视图中某个按钮回调
typedef void(^ClickSendAction)(NSString *text); // 点击键盘中的发送按钮回调
typedef void(^TextViewDidBeginEdit)(UITextView *textView); // 开始编辑回调
typedef void(^TextViewDidEditing)(UITextView *textView); // 正在编辑回调
typedef void(^TextViewDidEndEdit)(UITextView *textView); // 结束编辑回调
typedef void(^DidSelectItemInCollectionView)(NSInteger index); // 点击特殊类型消息

#endif /* IM_BottomHeader_h */
