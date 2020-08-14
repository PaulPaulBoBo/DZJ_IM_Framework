//
//  IM_RequestManager.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/12.
//  Copyright © 2020 大专家.com. All rights reserved.
//  消息请求类

#import <Foundation/Foundation.h>
#import "IM_MessageModel.h"
#import "IM_GroupInfoModel.h"

typedef void(^LoadMsgSuccess)(NSArray<IM_MessageModel *> *msgs);
typedef void(^LoadMsgFail)(void);

typedef void(^SendMsgSuccess)(NSArray<IM_MessageModel *> *msgs, IM_MessageModel *sendedModel);
typedef void(^SendMsgFail)(IM_MessageModel *failModel);
typedef void(^SendProgress)(CGFloat progressValue, id sendingObj, IM_MessageModel *sendingModel);
typedef void(^PreparedSendMsgSuccess)(NSArray<IM_MessageModel *> *msgs);

typedef void(^DeleteMsgSuccess)(IM_MessageModel *model);
typedef void(^DeleteMsgFail)(void);

typedef void(^LeaveSuccess)(void);
typedef void(^LeaveFail)(void);

typedef void(^LoadGroupInfoSuccess)(IM_GroupInfoModel *groupInfoModel);
typedef void(^LoadGroupInfoFail)(void);

typedef void(^LoadNoticeSuccess)(BOOL hasRead);
typedef void(^LoadNoticeFail)(void);

typedef void(^MarkNoticeSuccess)(void);
typedef void(^MarkNoticeFail)(void);

NS_ASSUME_NONNULL_BEGIN

@interface IM_RequestManager : NSObject

@property (nonatomic, strong) NSString *im_file_url;

/// IM请求单例
+(instancetype)shareInstance;

/// 获取某个时间点之前的历史消息
/// @param targetUserId 会话id
/// @param time 指定时间点
/// @param limit 条数限制
/// @param loadMsgSuccess 获取成功回调
/// @param loadMsgFail 回去失败回调
-(IM_RequestManager *)loadHistoryMessgeTargetUserId:(NSString*)targetUserId
                                         beforeTime:(NSDate *)time
                                              limit:(NSInteger)limit
                                     loadMsgSuccess:(LoadMsgSuccess)loadMsgSuccess
                                        loadMsgFail:(LoadMsgFail)loadMsgFail;
/// 获取某个时间点之后的所有新消息
/// @param targetUserId 会话id
/// @param time 指定时间点
/// @param limit 条数限制
/// @param loadMsgSuccess 获取成功回调
/// @param loadMsgFail 回去失败回调
-(IM_RequestManager *)loadAllNewMessgeTargetUserId:(NSString *)targetUserId
                                         afterTime:(NSDate *)time
                                             limit:(NSInteger)limit
                                    loadMsgSuccess:(LoadMsgSuccess)loadMsgSuccess
                                       loadMsgFail:(LoadMsgFail)loadMsgFail;

/// 发送消息
/// 返回数组中该消息为发送中状态，可直接使用该数组刷新列表，等待发送完成，在成功回调中会返回当前时间之前加载过的所有历史消息
/// @param model 消息模型
/// @param currentMsgs 当前已加载的历史消息
/// @param sendMsgSuccess 发送成功回调
/// @param sendMsgFail 发送失败回调
-(NSArray<IM_MessageModel *> *)sendMsg:(IM_MessageModel *)model
                           currentMsgs:(NSArray<IM_MessageModel *> *)currentMsgs
                        sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                           sendMsgFail:(SendMsgFail)sendMsgFail;

/// 撤回消息
/// 返回数组中该消息为删除中状态，可直接使用该数组刷新列表，等待发送完成，在成功回调中会返回当前时间之前加载过的所有历史消息
/// @param model 消息模型
/// @param currentMsgs 当前已加载的历史消息
/// @param deleteMsgSuccess 撤回成功回调
/// @param deleteMsgFail 撤回失败回调
-(NSArray<IM_MessageModel *> *)deleteMsg:(IM_MessageModel *)model
                             currentMsgs:(NSArray<IM_MessageModel *> *)currentMsgs
                        deleteMsgSuccess:(DeleteMsgSuccess)deleteMsgSuccess
                           deleteMsgFail:(DeleteMsgFail)deleteMsgFail;

/// 离开聊天页面，回到会话列表
/// @param targetUserId 会话id
/// @param leaveSuccess 成功回调
/// @param leaveFail 失败回调
-(IM_RequestManager *)leaveIMWithTargetUserId:(NSString *)targetUserId
                                 leaveSuccess:(LeaveSuccess)leaveSuccess
                                    leaveFail:(LeaveFail)leaveFail;

/// 获取群信息
/// @param groupId 群id
/// @param targetId 会话id
/// @param targetType 会话类型
/// @param loadGroupInfoSuccess 获取成功回调
/// @param loadGroupInfoFail 获取失败回调
-(IM_RequestManager *)loadGroupInfoGroupId:(NSString *)groupId
                                  targetId:(NSString *)targetId
                                targetType:(NSString *)targetType
                      loadGroupInfoSuccess:(LoadGroupInfoSuccess)loadGroupInfoSuccess
                         loadGroupInfoFail:(LoadGroupInfoFail)loadGroupInfoFail;

/// 获取群公告是否已读，只有工作交流群才有群公告
/// @param groupId 群id
/// @param loadNoticeSuccess 获取成功回调
/// @param loadNoticeFail 获取失败回调
-(IM_RequestManager *)loadNoticeWithGroupId:(NSString *)groupId
                       loadNoticeSuccess:(LoadNoticeSuccess)loadNoticeSuccess
                          loadNoticeFail:(LoadNoticeFail)loadNoticeFail;

/// 标记群公告是已读，只有工作交流群才有群公告
/// @param groupId 群id
/// @param markNoticeSuccess 标记公告已读成功回调
/// @param markNoticeFail 标记公告已读失败回调
-(IM_RequestManager *)markNoticeReadedGroupId:(NSString *)groupId
                            markNoticeSuccess:(MarkNoticeSuccess)markNoticeSuccess
                               markNoticeFail:(MarkNoticeFail)markNoticeFail;

/// 合并新旧数据
/// @param oldMsgs 旧数据
/// @param newMsgs 新数据
-(NSArray *)compareMsgsWithOldMsgs:(NSArray *)oldMsgs newMsgs:(NSArray *)newMsgs;

@end

NS_ASSUME_NONNULL_END
