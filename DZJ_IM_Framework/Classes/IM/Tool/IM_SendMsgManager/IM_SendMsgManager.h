//
//  IM_SendMsgManager.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/18.
//  Copyright © 2020 大专家.com. All rights reserved.
//  消息发送管理类

#import <Foundation/Foundation.h>
#import "IM_RequestManager.h" // 请求类

NS_ASSUME_NONNULL_BEGIN

@interface IM_FileInfoModel : JSONModel

@property (nonatomic, copy  ) NSString *key; // 文件或图片地址
@property (nonatomic, copy  ) NSString *name; // 文件或图片名字
@property (nonatomic, strong) NSNumber *fileSize; // 文件或图片大小
@property (nonatomic, copy  ) NSString *typeEnum; // 文件或图片类型

@end

@interface IM_SendMsgManager : NSObject

/// 配置视图控制器
/// @param viewController 聊天页面控制器
-(void)configViewController:(UIViewController *)viewController;

/// 发送消息
/// @param model 消息模型
/// @param currentMsgs 当前列表内的历史消息数组
/// @param sendMsgSuccess 发送成功回调
/// @param sendMsgFail 发送失败回调
/// @param sendProgress 发送进度回调
/// @param preparedSendMsgSuccess 准备好待发送的消息
-(NSArray *)sendMsgWithModel:(IM_MessageModel *)model
                 currentMsgs:(NSArray *)currentMsgs
              sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                 sendMsgFail:(SendMsgFail)sendMsgFail
                sendProgress:(SendProgress)sendProgress
      preparedSendMsgSuccess:(PreparedSendMsgSuccess)preparedSendMsgSuccess;

/// 发送多张图片
/// @param targetType 消息类型
/// @param targetId 群id
/// @param currentMsgs 当前列表内的历史消息数组
/// @param sendMsgSuccess 发送成功回调
/// @param sendMsgFail 发送失败回调
/// @param sendProgress 发送进度回调
-(NSArray *)sendImagesWithtargetType:(NSString *)targetType
                            targetId:(NSString *)targetId
                         currentMsgs:(NSArray *)currentMsgs
                      sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                         sendMsgFail:(SendMsgFail)sendMsgFail
                        sendProgress:(SendProgress)sendProgress
              preparedSendMsgSuccess:(PreparedSendMsgSuccess)preparedSendMsgSuccess;

/// 撤回消息
/// @param model 消息模型
/// @param currentMsgs 当前列表内的历史消息数组
/// @param deleteMsgSuccess 撤回成功回调
/// @param deleteMsgFail 撤回失败回调
-(NSArray *)deleteMsgWithModel:(IM_MessageModel *)model
                   currentMsgs:(NSArray *)currentMsgs
              deleteMsgSuccess:(DeleteMsgSuccess)deleteMsgSuccess
                 deleteMsgFail:(DeleteMsgFail)deleteMsgFail;
@end

NS_ASSUME_NONNULL_END
