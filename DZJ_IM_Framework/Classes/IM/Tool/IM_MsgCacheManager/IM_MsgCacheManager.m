//
//  IM_MsgCacheManager.m
//  DoctorCloud
//
//  Created by dzj on 2020/7/1.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_MsgCacheManager.h"
#import "IM_RequestManager.h"
#import "DZJConstants.h"

static NSString *CacheFileName = @"IM_UnSendMsgCache_File_%@_%@.plist";

static IM_MsgCacheManager *msgCacheManage = nil;

@implementation IM_MsgCacheManager

// 单例
+(instancetype)shareInstance {
    if(msgCacheManage == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            msgCacheManage = [[IM_MsgCacheManager alloc] init];
            [msgCacheManage addNotification];
        });
    }
    return msgCacheManage;
}

#pragma mark - public

/// read

// 获取是否有某个群的未发送的消息缓存
-(BOOL)hasUnsendMsgCache:(NSString *)targetId {
    BOOL hasUnsendMsgCache = NO;
    if([self isExistPathKey:clearNilStr(targetId)]) {
        hasUnsendMsgCache = YES;
    } else {
        hasUnsendMsgCache = NO;
    }
    return hasUnsendMsgCache;
}

// 获取某个群的未发送消息缓存
-(IM_MessageModel *)loadUnsendMsgCacheWithId:(NSString *)targetId {
    IM_MessageModel *model = nil;
    NSDictionary *dic = [self readDataWithKey:clearNilStr(targetId)];
    if(dic) {
        NSError *error = nil;
        model = [[IM_MessageModel alloc] initWithDictionary:dic error:&error];
    }
    return model;
}

// 获取所有缓存过的未发送的消息
-(NSArray<IM_MessageModel *> *)loadAllUnsendMsgCache {
    NSMutableArray *models = [[NSMutableArray alloc] init];
    NSArray *keys = [self transPathToKeys:[self readAllFile]];
    for (int i = 0; i < keys.count; i++) {
        IM_MessageModel *model = nil;
        model = [self loadUnsendMsgCacheWithId:[keys objectAtIndex:i]];
        if(model) {
            [models addObject:model];
        }
    }
    return [models copy];
}

/// 获取新建群通知消息（需要在返回到列表时清掉该缓存） @{@"dzjUserId":@"", @"groupId":@""}
-(NSDictionary *)loadCreateGroupMsg {
    return [self readDataWithKey:IM_CREATE_GROUP];
}

/// 获取被邀请加入群通知消息（需要在返回到列表时清掉该缓存） @{@"dzjUserId":@"", @"groupId":@""}
-(NSDictionary *)loadJoinGroupMsg {
    return [self readDataWithKey:IM_JOIN_GROUP];
}

/// write

// 新建未发送消息缓存
-(void)createUnSendMsgCache:(NSString *)targetId content:(NSString *)content {
    if(clearNilStr(content).length == 0) {
        [self deleteDataWithKey:clearNilStr(targetId)];
    } else {
        IM_MessageModel *model = [IM_MessageModel createModelWithMsgType:(IM_MsgTypeDefault) content:content targetType:@"SELF" targetId:targetId];
        model.state = IM_MessageStateUnsend;
        [self createMsgCache:model];
    }
}

// 新建消息缓存
-(void)createMsgCache:(IM_MessageModel *)model {
    if(model != nil) {
        NSDictionary *jsonDic = [model toDictionary];
        if(jsonDic) {
            BOOL isSuc = [self saveData:jsonDic key:model.targetId];
            if(isSuc) {
                DLog(@"未发送消息保存成功！");
            } else {
                DLog(@"未发送消息保存失败！");
            }
        }
    }
}

/// update

// 更新未发送消息缓存
-(void)updateUnSendMsgCache:(NSString *)targetId content:(NSString *)content {
    if(clearNilStr(content).length == 0) {
        [self deleteDataWithKey:clearNilStr(targetId)];
    } else {
        IM_MessageModel *model = [IM_MessageModel createModelWithMsgType:(IM_MsgTypeDefault) content:content targetType:@"SELF" targetId:targetId];
        model.state = IM_MessageStateUnsend;
        [self updateMsgCache:model];
    }
}

// 更新消息缓存
-(void)updateMsgCache:(IM_MessageModel *)model {
    if([self isExistPathKey:clearNilStr(model.targetId)]) {
        [self deleteDataWithKey:clearNilStr(model.targetId)];
    }
    [self createMsgCache:model];
}

/// delete

// 删除某条
-(void)deleteMsgCache:(NSString *)targetId {
    if([self isExistPathKey:clearNilStr(targetId)]) {
        BOOL isSuc = [self deleteDataWithKey:clearNilStr(targetId)];
        if(isSuc) {
            DLog(@"未发送消息删除成功！");
        } else {
            DLog(@"未发送消息删除失败！");
        }
    }
}

// 删除所有未发送消息缓存
-(void)deleteUnsendAllMsgCache {
    NSArray *keys = [self transPathToKeys:[self readAllFile]];
    for (int i = 0; i < keys.count; i++) {
        if([self isExistPathKey:[keys objectAtIndex:i]]) {
            BOOL isSuc = [self deleteDataWithKey:[keys objectAtIndex:i]];
            if(isSuc) {
                DLog(@"消息删除成功！");
            } else {
                DLog(@"消息删除失败！");
            }
        }
    }
}

// 删除新建群通知消息
-(void)removeCreateGroupMsg {
    [self deleteDataWithKey:IM_CREATE_GROUP];
}

// 删除被邀请进去通知消息
-(void)removeJoinGroupMsg {
    [self deleteDataWithKey:IM_JOIN_GROUP];
}

#pragma mark - private

-(void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGroup:) name:IM_CREATE_GROUP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinGroup:) name:IM_JOIN_GROUP object:nil];
}

-(void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 新建群通知事件，不需要被外部调用，该方法仅由通知触发
-(void)createGroup:(NSNotification *)noti {
    [self saveData:noti.userInfo key:IM_CREATE_GROUP];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DZJRouter openURL:@"messagecenter/list" query:nil animated:NO];
        [DZJRouter openURL:@"root/im" query:@{@"targetId":clearNilStr(noti.userInfo[@"dzjUserId"]) , @"targetType":@"WORKING_GROUP", @"targetTitle":@"", @"chatGroupId":clearNilStr(noti.userInfo[@"groupId"])} animated:NO];
    });
}

// 被邀请进群通知事件，不需要被外部调用，该方法仅由通知触发
-(void)joinGroup:(NSNotification *)noti {
    [self saveData:noti.userInfo key:IM_JOIN_GROUP];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DZJRouter openURL:@"messagecenter/list" query:nil animated:NO];
        [DZJRouter openURL:@"root/im" query:@{@"targetId":clearNilStr(noti.userInfo[@"dzjUserId"]) , @"targetType":@"WORKING_GROUP", @"targetTitle":@"", @"chatGroupId":clearNilStr(noti.userInfo[@"groupId"])} animated:NO];
    });
}

/// 存储数据
/// @param dic 数据字典
/// @param key 文件标识 唯一的id
-(BOOL)saveData:(NSDictionary *)dic key:(NSString *)key {
    // 获取路径
    NSString *filePath = [self loadPath:key];
    // 写入数据
    BOOL isSuc = [dic writeToFile:filePath atomically:YES];
    return isSuc;
}

/// 读取数据
/// @param key 文件标识 唯一的id
-(NSDictionary *)readDataWithKey:(NSString *)key {
    // 文件路径
    NSString *filePath = [self loadPath:key];
    // 解析数据
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return dict;
}

/// 删除数据
/// @param key 文件标识 唯一的id
-(BOOL)deleteDataWithKey:(NSString *)key {
    // 文件路径
    NSString *filePath = [self loadPath:key];
    NSError *error = nil;
    BOOL isSuc = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    return isSuc;
}

/// 获取路径
/// @param key 文件标识 唯一的id
-(NSString *)loadPath:(NSString *)key {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:CacheFileName, clearNilStr([UserStorage sharedInstance].userInfo.userID), key]];
    return filePath;
}

/// 是否存在文件
/// @param key 文件标识 唯一的id
-(BOOL)isExistPathKey:(NSString *)key {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self loadPath:key]];
}

// 取出文件路径中的key
-(NSArray *)transPathToKeys:(NSArray *)paths {
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < paths.count; i++) {
        NSString *path = [paths objectAtIndex:i];
        if(path && [path rangeOfString:@"/"].length > 0 && [path rangeOfString:@"."].length > 0) {
            NSString *key = [[[path componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject componentsSeparatedByString:@"_"].lastObject;
            if(key != nil && key.length > 0) {
                if([self isExistPathKey:key]) {
                    [keys addObject:key];
                }
            }
        }
    }
    return [keys copy];
}

/// 获取所有文件目录
-(NSArray *)readAllFile {
    // 工程目录
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:rootPath];
    
    BOOL isDir = NO;
    BOOL isExist = NO;
    NSMutableArray *paths = [NSMutableArray new];
    //列举目录内容，可以遍历子目录
    for (NSString *path in myDirectoryEnumerator.allObjects) {
        isExist = [myFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", rootPath, path] isDirectory:&isDir];
        if (!isDir) {
            NSLog(@"%@", path);    // 文件路径
            [paths addObject:path];
        }
    }
    return [paths copy];
}

@end
