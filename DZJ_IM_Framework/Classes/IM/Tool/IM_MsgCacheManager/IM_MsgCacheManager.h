//
//  IM_MsgCacheManager.h
//  DoctorCloud
//
//  Created by dzj on 2020/7/1.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IM_MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_MsgCacheManager : NSObject

/// 单例
+(instancetype)shareInstance;

#pragma mark - read

/// 获取是否有某个群的未发送的消息缓存
/// @param targetId 聊天的主id 不是groupId
-(BOOL)hasUnsendMsgCache:(NSString *)targetId;

/// 获取某个群的未发送消息缓存
/// @param targetId 聊天的主id 不是groupId
-(IM_MessageModel *)loadUnsendMsgCacheWithId:(NSString *)targetId;

/// 获取所有缓存过的未发送的消息
-(NSArray<IM_MessageModel *> *)loadAllUnsendMsgCache;

/// 获取新建群通知消息（需要在返回到列表时清掉该缓存） @{@"dzjUserId":@"", @"groupId":@""}
-(NSDictionary *)loadCreateGroupMsg;

/// 获取被邀请加入群通知消息（需要在返回到列表时清掉该缓存） @{@"dzjUserId":@"", @"groupId":@""}
-(NSDictionary *)loadJoinGroupMsg;

#pragma mark - write

/// 新建未发送消息缓存
/// @param targetId 会话id
/// @param content 缓存消息内容
-(void)createUnSendMsgCache:(NSString *)targetId content:(NSString *)content;

/// 新建消息缓存
/// @param model 未发送消息模型 model的 state 必须为 IM_MessageStateUnsend ，否则无法新建缓存
-(void)createMsgCache:(IM_MessageModel *)model;

#pragma mark - update

/// 更新未发送消息
/// @param targetId 会话id
/// @param content 缓存消息更新内容
-(void)updateUnSendMsgCache:(NSString *)targetId content:(NSString *)content;

/// 更新消息缓存
/// @param model 未发送消息模型 model的 state 必须为 IM_MessageStateUnsend ，否则无法更新缓存，content如果为空字符串，将自动清除这一条缓存
-(void)updateMsgCache:(IM_MessageModel *)model;

#pragma mark - delete

/// 删除某条
/// @param targetId 会话id
-(void)deleteMsgCache:(NSString *)targetId;

/// 删除所有未发送消息缓存
-(void)deleteUnsendAllMsgCache;

/// 删除新建群通知消息
-(void)removeCreateGroupMsg;

/// 删除被邀请进去通知消息
-(void)removeJoinGroupMsg;

@end

NS_ASSUME_NONNULL_END
