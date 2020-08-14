//
//  IM_RequestManager.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/12.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_RequestManager.h"

static NSString *LoadMsgUrl = @"im/message/pull"; // 获取聊天记录
static NSString *SendMsgUrl = @"im/message/send"; // 发送消息
static NSString *DeleteMsgUrl = @"im/message/%@/remove"; // 发送消息
static NSString *LeaveIMUrl = @"im/conversation/leave"; // 离开聊天页面
static NSString *GroupInfoUrl = @"bdc/msl_chat_group/message"; // 获取群信息
static NSString *IM_UserListUrl = @"im/user/list"; // 私聊成员列表
static NSString *WorkingGroupMembersUrl = @"bdc/msl_chat_group/sum/group_member"; // 获取群成员数 仅限工作交流群
static NSString *CommonGroupMembersUrl = @"im/conversation/members/count"; // 获取群成员数 非工作交流群
static NSString *LoadNoticeUrl = @"im/chat_group/judge_read_notice"; // 获取群成员数 非工作交流群
static NSString *UpdateReadNotice = @"im/chat_group/update_read_notice"; // 标记群公告已读

@interface IM_RequestManager()

@property (nonatomic, copy) NSString *currentTimeStr;

@end

@implementation IM_RequestManager

static IM_RequestManager *manager = nil;

/// IM请求单例
+(instancetype)shareInstance {
    if(manager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[IM_RequestManager alloc] init];
        });
    }
    return manager;
}

// 获取某个时间点之前的历史消息
-(IM_RequestManager *)loadHistoryMessgeTargetUserId:(NSString*)targetUserId
                                         beforeTime:(NSDate *)time
                                              limit:(NSInteger)limit
                                     loadMsgSuccess:(LoadMsgSuccess)loadMsgSuccess
                                        loadMsgFail:(LoadMsgFail)loadMsgFail {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"targetUserId":clearNilStr(targetUserId),
                                                                                 @"tOffset":clearNilStr([NSDate createSSSDate:time]),
                                                                                 @"direction":@"before",
                                                                                 @"limit":[NSString stringWithFormat:@"%ld", limit]
    }];
    [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfGet) loadUrlStr:LoadMsgUrl params:param success:^(NSDictionary *responseObject) {
        BOOL hasError = YES;
        if(responseObject) {
            NSArray *data = [responseObject objectForKey:@"data"];
            if([data isKindOfClass:[NSArray class]] && data != nil && data.count >= 0) {
                NSMutableArray *msgs = [NSMutableArray new];
                for (int i = 0; i < data.count; i++) {
                    NSDictionary *dic = [data objectAtIndex:i];
                    if([dic isKindOfClass:[NSDictionary class]] && dic != nil) {
                        NSError *error = nil;
                        IM_MessageModel *model = [[IM_MessageModel alloc] initWithDictionary:dic error:&error];
                        model.state = IM_MessageStateSended;
                        model.targetId = targetUserId;
                        if(error == nil && model != nil) {
                            if(msgs.count > 0) {
                                IM_MessageModel *preModel = msgs.lastObject;
                                if(preModel.updatedTime && model.updatedTime) {
                                    model.isShowTime = [model.updatedTime timeIntervalSinceNow] - [preModel.updatedTime timeIntervalSinceNow] > 2*60;
                                }
                            }
                            [msgs addObject:model];
                        }
                    }
                }
                if(loadMsgSuccess) {
                    hasError = NO;
                    loadMsgSuccess([msgs copy]);
                }
            }
        }
        
        if(hasError) {
            if(loadMsgFail) {
                loadMsgFail();
            }
        }
    } fail:^(NSError *error) {
        if(loadMsgFail) {
            loadMsgFail();
        }
    }];
    return manager;
}

// 获取某个时间点之后的所有新消息
-(IM_RequestManager *)loadAllNewMessgeTargetUserId:(NSString*)targetUserId
                                         afterTime:(NSDate *)time
                                             limit:(NSInteger)limit
                                    loadMsgSuccess:(LoadMsgSuccess)loadMsgSuccess
                                       loadMsgFail:(LoadMsgFail)loadMsgFail {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"targetUserId":clearNilStr(targetUserId),
                                                                                 @"tOffset":clearNilStr([NSDate createSSSDate:time]),
                                                                                 @"direction":@"after",
                                                                                 @"limit":[NSString stringWithFormat:@"%ld", limit]
    }];
    [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfGet) loadUrlStr:LoadMsgUrl params:param success:^(NSDictionary *responseObject) {
        BOOL hasError = YES;
        if(responseObject) {
            NSArray *data = [responseObject objectForKey:@"data"];
            if([data isKindOfClass:[NSArray class]] && data != nil && data.count >= 0) {
                NSMutableArray *msgs = [NSMutableArray new];
                for (int i = 0; i < data.count; i++) {
                    NSDictionary *dic = [data objectAtIndex:i];
                    if([dic isKindOfClass:[NSDictionary class]] && dic != nil) {
                        NSError *error = nil;
                        IM_MessageModel *model = [[IM_MessageModel alloc] initWithDictionary:dic error:&error];
                        model.state = IM_MessageStateSended;
                        model.targetId = targetUserId;
                        if(error == nil && model != nil) {
                            if(msgs.count > 0) {
                                IM_MessageModel *preModel = msgs.lastObject;
                                if(preModel.updatedTime && model.updatedTime) {
                                    model.isShowTime = [model.updatedTime timeIntervalSinceNow] - [preModel.updatedTime timeIntervalSinceNow] > 2*60;
                                }
                            }
                            [msgs addObject:model];
                        }
                    }
                }
                if(loadMsgSuccess) {
                    hasError = NO;
                    loadMsgSuccess([msgs copy]);
                }
            }
        }
        
        if(hasError) {
            if(loadMsgFail) {
                loadMsgFail();
            }
        }
    } fail:^(NSError *error) {
        if(loadMsgFail) {
            loadMsgFail();
        }
    }];
    return manager;
}

// 发送消息
-(NSArray<IM_MessageModel *> *)sendMsg:(IM_MessageModel *)model
                           currentMsgs:(NSArray<IM_MessageModel *> *)currentMsgs
                        sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                           sendMsgFail:(SendMsgFail)sendMsgFail {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"toUserId":clearNilStr(model.toUserId),
                                                                                 @"targetType":clearNilStr(model.targetType),
                                                                                 @"content":clearNilStr(model.content),
                                                                                 @"contentType":clearNilStr(model.contentType),
                                                                                 @"time":[NSString stringWithFormat:@"%@", [NSDate date]]
    }];
    __block NSMutableArray *tmpCurrentMsgs = [NSMutableArray arrayWithArray:currentMsgs];
    [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfPost) loadUrlStr:SendMsgUrl params:param success:^(NSDictionary *responseObject) {
        if(responseObject) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            if([data isKindOfClass:[NSDictionary class]] && data != nil && data.count >= 0) {
                NSError *error = nil;
                IM_MessageModel *tmpModel = [[IM_MessageModel alloc] initWithDictionary:data error:&error];
                tmpModel.state = IM_MessageStateSended;
                tmpModel.localStateId = model.localStateId;
                tmpModel.msgType = model.msgType;
                if(sendMsgSuccess) {
                    sendMsgSuccess([tmpCurrentMsgs copy], tmpModel);
                }
            }
        }
    } fail:^(NSError *error) {
        if(sendMsgFail) {
            model.state = IM_MessageStateSendFail;
            sendMsgFail(model);
        }
    }];
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:currentMsgs];
    [mArr addObject:model];
    return [mArr copy];
}

// 撤回消息
-(NSArray<IM_MessageModel *> *)deleteMsg:(IM_MessageModel *)model
                             currentMsgs:(NSArray<IM_MessageModel *> *)currentMsgs
                        deleteMsgSuccess:(DeleteMsgSuccess)deleteMsgSuccess
                           deleteMsgFail:(DeleteMsgFail)deleteMsgFail {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"id":clearNilStr(model.IM_id)}];
    [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfPost) loadUrlStr:[NSString stringWithFormat:DeleteMsgUrl, clearNilStr(model.IM_id)]
                                      params:param
                                     success:^(NSDictionary *responseObject) {
        BOOL hasError = YES;
        if(responseObject) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            if([data isKindOfClass:[NSDictionary class]] && data != nil && data.count >= 0) {
                NSError *error = nil;
                IM_MessageModel *tmpModel = [[IM_MessageModel alloc] initWithDictionary:data error:&error];
                tmpModel.localStateId = model.localStateId;
                if(error == nil) {
                    if(deleteMsgSuccess) {
                        hasError = NO;
                        deleteMsgSuccess(model);
                    }
                }
            }
        }
        
        if(hasError) {
            if(deleteMsgFail) {
                deleteMsgFail();
            }
        }
    } fail:^(NSError *error) {
        if(deleteMsgFail) {
            deleteMsgFail();
        }
    }];
    
    return [currentMsgs copy];
}

// 离开聊天页面，回到会话列表
-(IM_RequestManager *)leaveIMWithTargetUserId:(NSString *)targetUserId
                                 leaveSuccess:(LeaveSuccess)leaveSuccess
                                    leaveFail:(LeaveFail)leaveFail {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"dzjTargetId":clearNilStr(targetUserId)}];
    [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfPut)
                                  loadUrlStr:LeaveIMUrl
                                      params:param
                                     success:^(NSDictionary *responseObject) {
        if(leaveSuccess) {
            leaveSuccess();
        }
    } fail:^(NSError *error) {
        if(leaveFail) {
            leaveFail();
        }
    }];
    
    return manager;
}

// 获取群信息
-(IM_RequestManager *)loadGroupInfoGroupId:(NSString *)groupId
                                  targetId:(NSString *)targetId
                                targetType:(NSString *)targetType
                      loadGroupInfoSuccess:(LoadGroupInfoSuccess)loadGroupInfoSuccess
                         loadGroupInfoFail:(LoadGroupInfoFail)loadGroupInfoFail {
    dispatch_group_t group = dispatch_group_create();
    
    __block NSString *groupName = @"";
    __block NSString *groupNotice = @"";
    __block NSNumber *groupMember = @(0);
    // 工作交流群获取群成员数和其他群有区别， 工作交流群可以通过接口拿到群信息，通过GroupInfoUrl+groupId获取群成员数，但普通的不行，普通的只能从列表将标题传进来，通过CommonGroupMembersUrl+dzjUserId获取群成员数
    if([targetType isEqualToString:@"WORKING_GROUP"]) {
        
        dispatch_group_enter(group);
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"groupId":clearNilStr(groupId)}];
        [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfGet) loadUrlStr:GroupInfoUrl params:param success:^(NSDictionary *responseObject) {
            BOOL hasError = YES;
            if(responseObject) {
                hasError = NO;
                groupName = [[responseObject objectForKey:@"data"] objectForKey:@"name"];
                groupNotice = [[responseObject objectForKey:@"data"] objectForKey:@"notice"];
            }
            
            if(hasError) {
                if(loadGroupInfoFail) {
                    loadGroupInfoFail();
                }
            }
            dispatch_group_leave(group);
        } fail:^(NSError *error) {
            if(loadGroupInfoFail) {
                loadGroupInfoFail();
            }
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        NSMutableDictionary *paramMem = [NSMutableDictionary dictionaryWithDictionary:@{@"groupId":clearNilStr(groupId)}];
        [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfGet) loadUrlStr:WorkingGroupMembersUrl params:paramMem success:^(NSDictionary *responseObject) {
            BOOL hasError = YES;
            if(responseObject) {
                hasError = NO;
                groupMember = [NSNumber numberWithString:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"data"]]];
            }
            
            if(hasError) {
                if(loadGroupInfoFail) {
                    loadGroupInfoFail();
                }
            }
            dispatch_group_leave(group);
        } fail:^(NSError *error) {
            if(loadGroupInfoFail) {
                loadGroupInfoFail();
            }
            dispatch_group_leave(group);
        }];
    } else if([targetType isEqualToString:@"USER"]) {
        // 私聊
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"idList":clearNilStr(targetId)}];
        dispatch_group_enter(group);
        [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfGet) loadUrlStr:IM_UserListUrl params:param success:^(NSDictionary *responseObject) {
            BOOL hasError = YES;
            if(responseObject) {
                hasError = NO;
                NSArray *list = [responseObject objectForKey:@"data"];
                if(list && list.count > 0) {
                    NSDictionary *dic = list.firstObject;
                    if(dic && [dic objectForKey:@"name"]) {
                        groupName = clearNilStr([dic objectForKey:@"name"]);
                    }
                }
            }
            
            if(hasError) {
                if(loadGroupInfoFail) {
                    loadGroupInfoFail();
                }
            }
            dispatch_group_leave(group);
        } fail:^(NSError *error) {
            if(loadGroupInfoFail) {
                loadGroupInfoFail();
            }
            dispatch_group_leave(group);
        }];
    } else {
        dispatch_group_enter(group);
        NSMutableDictionary *paramMem = [NSMutableDictionary dictionaryWithDictionary:@{@"dzjUserId":clearNilStr(targetId)}];
        [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfGet) loadUrlStr:CommonGroupMembersUrl params:paramMem success:^(NSDictionary *responseObject) {
            BOOL hasError = YES;
            if(responseObject) {
                hasError = NO;
                groupMember = [NSNumber numberWithString:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"data"]]];
            }
            
            if(hasError) {
                if(loadGroupInfoFail) {
                    loadGroupInfoFail();
                }
            }
            dispatch_group_leave(group);
        } fail:^(NSError *error) {
            if(loadGroupInfoFail) {
                loadGroupInfoFail();
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        IM_GroupInfoModel *groupModel = [[IM_GroupInfoModel alloc] init];
        groupModel.groupId = groupId;
        groupModel.targetId = targetId;
        groupModel.targetType = targetType;
        groupModel.groupTitle = clearNilStr(groupName);
        groupModel.notice = clearNilStr(groupNotice);
        groupModel.groupNumber = clearNilStr([groupMember stringValue]);
        if(loadGroupInfoSuccess) {
            loadGroupInfoSuccess(groupModel);
        }
    });
    
    return manager;
}

// 获取群公告是否已读，只有工作交流群才有群公告
-(IM_RequestManager *)loadNoticeWithGroupId:(NSString *)groupId
                          loadNoticeSuccess:(LoadNoticeSuccess)loadNoticeSuccess
                             loadNoticeFail:(LoadNoticeFail)loadNoticeFail {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"groupId":clearNilStr(groupId)}];
    [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfGet) loadUrlStr:LoadNoticeUrl params:param success:^(NSDictionary *responseObject) {
        BOOL hasError = YES;
        if(responseObject) {
            hasError = NO;
            if(loadNoticeSuccess) {
                loadNoticeSuccess([responseObject boolValueForKey:@"data" default:YES]);
            }
        }
        
        if(hasError) {
            if(loadNoticeFail) {
                loadNoticeFail();
            }
        }
    } fail:^(NSError *error) {
        if(loadNoticeFail) {
            loadNoticeFail();
        }
    }];
    return manager;
}

// 标记群公告是已读，只有工作交流群才有群公告
-(IM_RequestManager *)markNoticeReadedGroupId:(NSString *)groupId
                            markNoticeSuccess:(MarkNoticeSuccess)markNoticeSuccess
                               markNoticeFail:(MarkNoticeFail)markNoticeFail {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"groupId":clearNilStr(groupId)}];
    [[DZJHttpManager shareManager] loadModel:(DZJLoadModelOfPut) loadUrlStr:UpdateReadNotice params:param success:^(NSDictionary *responseObject) {
        if(markNoticeSuccess) {
            markNoticeSuccess();
        }
    } fail:^(NSError *error) {
        if(markNoticeFail) {
            markNoticeFail();
        }
    }];
    
    return manager;
}

#pragma mark - private

-(NSDate *)preDateWithDate:(NSDate *)date {
    NSDate *preDate = [NSDate dateWithTimeIntervalSince1970:([date timeIntervalSince1970] - 2*60)];
    return preDate;
}

// 合并新旧数据
-(NSArray *)compareMsgsWithOldMsgs:(NSArray *)oldMsgs newMsgs:(NSArray *)newMsgs {
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:oldMsgs];
    if(newMsgs.count == 0) {
        return mArr;
    }
    
    NSMutableSet *im_ids = [self loadIdsWithArr:mArr];
    mArr = [self mergeArr:mArr newMsgs:newMsgs im_ids:im_ids];
    NSMutableArray *sortedMarr = [self sortMsgs:mArr];
    return [sortedMarr copy];
}

-(NSMutableSet *)loadIdsWithArr:(NSMutableArray *)mArr {
    NSMutableSet *im_ids = [NSMutableSet new];
    for (int i = 0; i < mArr.count; i++) {
        IM_MessageModel *tmpModel = [mArr objectAtIndex:i];
        if(tmpModel) {
            if(clearNilStr(tmpModel.IM_id).length > 0) {
                [im_ids addObject:clearNilStr(tmpModel.IM_id)];
            }
            if(clearNilStr(tmpModel.localStateId).length > 0) {
                [im_ids addObject:clearNilStr(tmpModel.localStateId)];
            }
        }
    }
    return im_ids;
}

-(NSMutableArray *)mergeArr:(NSMutableArray *)mArr newMsgs:(NSMutableArray *)newMsgs im_ids:(NSMutableSet *)im_ids {
    for (int i = 0; i < newMsgs.count; i++) {
        IM_MessageModel *tmpModel = [newMsgs objectAtIndex:i];
        if(tmpModel) {
            if(tmpModel.IM_id != nil) {
                if(![im_ids containsObject:clearNilStr(tmpModel.IM_id)]) {
                    [im_ids addObject:clearNilStr(tmpModel.IM_id)];
                    [mArr addObject:tmpModel];
                }
            }
            if(tmpModel.localStateId != nil) {
                if(![im_ids containsObject:clearNilStr(tmpModel.localStateId)]) {
                    [im_ids addObject:clearNilStr(tmpModel.localStateId)];
                    [mArr addObject:tmpModel];
                }
            }
        }
    }
    return mArr;
}

-(NSMutableArray *)sortMsgs:(NSMutableArray *)mArr {
    NSMutableArray *sortedMarr = [NSMutableArray arrayWithArray:mArr];
    for (int i = 0; i < sortedMarr.count-1; i++) {
        for(int j = 0; j < sortedMarr.count-i-1; j++) {
            IM_MessageModel *preModel = [sortedMarr objectAtIndex:j];
            IM_MessageModel *behndModel = [sortedMarr objectAtIndex:j+1];
            if([preModel.updatedTime timeIntervalSince1970] > [behndModel.updatedTime timeIntervalSince1970]) {
                [sortedMarr exchangeObjectAtIndex:j withObjectAtIndex:j+1];
            } else if ([preModel.updatedTime timeIntervalSince1970] == [behndModel.updatedTime timeIntervalSince1970]) {
                if([preModel.createdTime timeIntervalSince1970] > [behndModel.createdTime timeIntervalSince1970]) {
                    [sortedMarr exchangeObjectAtIndex:j withObjectAtIndex:j+1];
                }
            }
        }
    }
    return sortedMarr;
}

#pragma mark - lazy

-(NSString *)currentTimeStr {
    return [NSDate createSSSDate:[NSDate date]];
}

-(NSString *)im_file_url {
    LoadBuildVersion version = [[DZJLoadDefaultSetting sharedInstance] showCurrentLoadVersion];
    if (version == LoadBuildVersionOfOnline) {
        return @"https://dzj-prod-1.oss-cn-shanghai.aliyuncs.com/";
    }else if (version == LoadBuildVersionOfTest172_9){
        return @"http://172.29.28.9/";
    }else if (version == LoadBuildVersionOfTest172_26){
        return @"http://172.29.28.26/";
    }else if (version == LoadBuildVersionOfAliYun){
        return @"http://dzj-test.oss-cn-shanghai.aliyuncs.com/";
    }else{
        NSParameterAssert(LS(@"未知设置"));
        return nil;
    }
}
@end

