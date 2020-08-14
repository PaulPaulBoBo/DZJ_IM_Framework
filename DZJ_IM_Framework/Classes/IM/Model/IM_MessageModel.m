//
//  IM_MessageModel.m
//  L_Chat
//
//  Created by dzj on 2020/6/8.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_MessageModel.h"

@implementation IM_JSONModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end

@implementation IM_VideoContentModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"video_id":@"id"}];
}

@end

@implementation IM_FileContentModel @end

@implementation IM_MSLContentModel @end

@implementation IM_NewsContentModel @end

@implementation IM_ArticleContentModel @end

@implementation IM_CaseContentModel @end

@implementation IM_NoticeContentModel @end

@implementation IM_HealthRecordContentModel @end

@implementation IM_VoiceContentModel

-(void)setVoiceData:(NSData *)voiceData {
    _voiceData = voiceData;
    self.voiceName = [NSString stringWithFormat:@"audio__%.0f", [[NSDate date] timeIntervalSince1970]];
}

-(void)setDuration:(NSNumber *)duration {
    _duration = duration;
    while (_duration.floatValue > 60) {
        _duration = @60;
    }
}

@end

@implementation IM_CommonMessageModel @end


@implementation IM_MessageModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"IM_id":@"id"}];
}

// 创建发送模型
+(IM_MessageModel *)createModelWithMsgType:(IM_MsgType)msgType
                                   content:(NSString *)content
                                targetType:(NSString *)targetType
                                  targetId:(NSString *)targetId {
    IM_MessageModel *model = [[IM_MessageModel alloc] init];
    
    model.nickName = [UserStorage sharedInstance].userInfo.nickName;
    model.createdTime = [NSDate date];
    model.updatedTime = [NSDate date];
    model.tags = [UserStorage sharedInstance].userInfo.tags;
    model.fromUserId = [UserStorage sharedInstance].userInfo.userID;
    model.toUserId = targetId;
    model.avatar = [UserStorage sharedInstance].userInfo.profileImage;
    model.targetType = targetType;
    model.gender = [UserStorage sharedInstance].userInfo.gender;
    
    model.state = IM_MessageStateSending;
    model.isSelfSend = YES;
    model.localStateId = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    model.targetId = targetId;
    model.msgType = msgType;
    model.content = content;
    
    return model;
}

-(void)setContent:(NSString *)content {
    _content = content;
    NSError *error = nil;
    if([self.contentType isEqual:@"VIDEO"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_VideoContentModel *tmpModel = [[IM_VideoContentModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.videoModel = tmpModel;
        }
    } else if([self.contentType isEqual:@"FILE"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_FileContentModel *tmpModel = [[IM_FileContentModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.fileModel = tmpModel;
        }
    } else if([self.contentType isEqual:@"MSL_PREACH_LOG"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_MSLContentModel *tmpModel = [[IM_MSLContentModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.mslModel = tmpModel;
        }
    } else if([self.contentType isEqual:@"NEWS"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_NewsContentModel *tmpModel = [[IM_NewsContentModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.newsModel = tmpModel;
        }
    } else if([self.contentType isEqual:@"ARTICLE"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_ArticleContentModel *tmpModel = [[IM_ArticleContentModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.articleModel = tmpModel;
        }
    } else if([self.contentType isEqual:@"CASE"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_CaseContentModel *tmpModel = [[IM_CaseContentModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.caseModel = tmpModel;
        }
    } else if([self.contentType isEqual:@"NOTICE"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_NoticeContentModel *tmpModel = [[IM_NoticeContentModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.noticeModel = tmpModel;
        }
    } else if([self.contentType isEqual:@"HEALTH_RECORD"]) {
        IM_HealthRecordContentModel *tmpModel = [[IM_HealthRecordContentModel alloc] init];
        tmpModel.content = clearNilStr(content);
        self.healthRecordModel = tmpModel;
    } else if([self.contentType isEqual:@"VOICE"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_VoiceContentModel *tmpModel = [[IM_VoiceContentModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.voiceModel = tmpModel;
        }
    } else if([self.contentType isEqual:@"createGroup"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        self.dzjUserId = [dic objectForKey:@"dzjUserId"];
        self.groupId = [dic objectForKey:@"groupId"];
        self.type = [dic objectForKey:@"type"];
    } else if([self.contentType isEqual:@"joinGroup"]) {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        self.dzjUserId = [dic objectForKey:@"dzjUserId"];
        self.groupId = [dic objectForKey:@"groupId"];
        self.type = [dic objectForKey:@"type"];
    } else {
        NSDictionary *dic = [self dictionaryWithJsonString:content];
        IM_CommonMessageModel *tmpModel = [[IM_CommonMessageModel alloc] initWithDictionary:dic error:&error];
        if(error == nil) {
            self.commonModel = tmpModel;
        }
    }
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

-(void)setFromUserId:(NSString *)fromUserId {
    _fromUserId = fromUserId;
    if([fromUserId isEqualToString:clearNilStr([UserStorage sharedInstance].userInfo.userID)]) {
        _isSelfSend = YES;
    } else {
        _isSelfSend = NO;
    }
}

-(void)setLocalStateId:(NSString *)localStateId {
    if(localStateId.length > 0) {
        _localStateId = [self createSingleIdWithLocalStateId:localStateId];
    } else {
        _localStateId = [self createSingleIdWithLocalStateId:@""];
    }
}

-(void)setMsgType:(IM_MsgType)msgType {
    _msgType = msgType;
    if(self.contentType.length == 0) {
        switch (msgType) {
            case IM_MsgTypeText: {
                self.contentType = @"TEXT";
            } break;
            case IM_MsgTypeImage: {
                self.contentType = @"IMAGE";
            } break;
            case IM_MsgTypeVideo: {
                self.contentType = @"VIDEO";
            } break;
            case IM_MsgTypeFile: {
                self.contentType = @"FILE";
            } break;
            case IM_MsgTypeMSL: {
                self.contentType = @"MSL_PREACH_LOG";
            } break;
            case IM_MsgTypeNews: {
                self.contentType = @"NEWS";
            } break;
            case IM_MsgTypePopular: {
                self.contentType = @"POPULAR";
            } break;
            case IM_MsgTypeArticle: {
                self.contentType = @"ARTICLE";
            } break;
            case IM_MsgTypeCase: {
                self.contentType = @"CASE";
            } break;
            case IM_MsgTypeNotice: {
                self.contentType = @"NOTICE";
            } break;
            case IM_MsgTypeHealthRecord: {
                self.contentType = @"HEALTH_RECORD";
            } break;
            case IM_MsgTypeAudio: {
                self.contentType = @"VOICE";
            } break;
            case IM_MsgTypeApplaud: {
                self.contentType = @"INTERACTION_APPLAUD";
            } break;
            case IM_MsgTypeFlower: {
                self.contentType = @"INTERACTION_FLOWERS";
            } break;
            case IM_MsgTypeCreateGroup: {
                self.contentType = @"createGroup";
            } break;
            case IM_MsgTypeFirsJoinGroup: {
                self.contentType = @"joinGroup";
            } break;
            default:
                self.contentType = @"COMMON";
                break;
        }
    }
}

-(void)setContentType:(NSString *)contentType {
    _contentType = contentType;
    if([contentType isEqualToString:@"TEXT"]) {
        self.msgType = IM_MsgTypeText;
    } else if([contentType isEqualToString:@"IMAGE"]) {
        self.msgType = IM_MsgTypeImage;
    } else if([contentType isEqualToString:@"VIDEO"]) {
        self.msgType = IM_MsgTypeVideo;
    } else if([contentType isEqualToString:@"FILE"]) {
        self.msgType = IM_MsgTypeFile;
    } else if([contentType isEqualToString:@"MSL_PREACH_LOG"]) {
        self.msgType = IM_MsgTypeMSL;
    } else if([contentType isEqualToString:@"NEWS"]) {
        self.msgType = IM_MsgTypeNews;
    } else if([contentType isEqualToString:@"POPULAR"]) {
        self.msgType = IM_MsgTypePopular;
    } else if([contentType isEqualToString:@"ARTICLE"]) {
        self.msgType = IM_MsgTypeArticle;
    } else if([contentType isEqualToString:@"CASE"]) {
        self.msgType = IM_MsgTypeCase;
    } else if([contentType isEqualToString:@"NOTICE"]) {
        self.msgType = IM_MsgTypeNotice;
    } else if([contentType isEqualToString:@"HEALTH_RECORD"]) {
        self.msgType = IM_MsgTypeHealthRecord;
    } else if([contentType isEqualToString:@"VOICE"]) {
        self.msgType = IM_MsgTypeAudio;
    } else if([contentType isEqualToString:@"INTERACTION_APPLAUD"]) {
        self.msgType = IM_MsgTypeApplaud;
    } else if([contentType isEqualToString:@"INTERACTION_FLOWERS"]) {
        self.msgType = IM_MsgTypeFlower;
    } else if([contentType isEqualToString:@"createGroup"]) {
        self.msgType = IM_MsgTypeCreateGroup;
    } else if([contentType isEqualToString:@"joinGroup"]) {
        self.msgType = IM_MsgTypeFirsJoinGroup;
    } else {
        self.msgType = IM_MsgTypeDefault;
    }
}

-(NSString *)createSingleIdWithLocalStateId:(NSString *)localStateId {
    if([localStateId rangeOfString:@"__"].length == 0) {
        int random = 1000000 + arc4random()%1000000;
        if(localStateId != nil && localStateId.length > 0) {
            localStateId = [NSString stringWithFormat:@"%@__%d", localStateId, random];
        }
    }
    return localStateId;
}

@end
