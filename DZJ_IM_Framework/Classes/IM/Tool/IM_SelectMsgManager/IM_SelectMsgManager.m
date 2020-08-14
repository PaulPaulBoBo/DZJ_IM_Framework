//
//  IM_SelectMsgManager.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/29.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_SelectMsgManager.h"

@implementation IM_SelectMsgModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        if(dic) {
            self.selectTitle = clearNilStr([dic objectForKey:@"selectTitle"]);
            self.selectLink = clearNilStr([dic objectForKey:@"selectLink"]);
            self.selectImage = clearNilStr([dic objectForKey:@"selectImage"]);
            self.selectType = [[dic objectForKey:@"selectType"] integerValue];
        }
    }
    return self;
}

@end

@implementation IM_SelectMsgManager

#pragma mark - public

/// 根据面板类型获取加号对应的选项
/// @param selectMsgType 面板类型
-(NSArray *)loadAddSelectItemWithSelectMsgType:(IM_SelectMsgType)selectMsgType targetId:(NSString *)targetId groupId:(NSString *)groupId {
    IM_SelectMsgModel *imageModel = [self createSelectModelTitle:@"图片" link:@"" image:@"im_sel_img" type:(IM_SelectItemType_Image)];
    IM_SelectMsgModel *fileModel = [self createSelectModelTitle:@"文件" link:@"" image:@"im_sel_file" type:(IM_SelectItemType_File)];
    IM_SelectMsgModel *mslModel = [self createSelectModelTitle:@"宣讲日志" link:@"" image:@"im_sel_log" type:(IM_SelectItemType_Link)];
    NSArray *items = @[];
    switch (selectMsgType) {
        case IM_SelectMsgType_BRANCH_CENTER:
        case IM_SelectMsgType_COMPANY_GROUP:
        case IM_SelectMsgType_CONFERENCE_GROUP:
        case IM_SelectMsgType_USER:
        case IM_SelectMsgType_COMPANY_BUSINESS_SERVICE:
        case IM_SelectMsgType_PESTILENCE_WARNING_V2:
        case IM_SelectMsgType_Default: {
            items = @[imageModel, fileModel];
        } break;
        case IM_SelectMsgType_WORKING_GROUP: {
            mslModel.selectLink = [NSString stringWithFormat:@"%@communication-group/create-preach-log?dzjUserId=%@", URL_H5, clearNilStr(targetId)];
            items = @[imageModel, fileModel, mslModel];
        } break;
        default: {
            items = @[imageModel, fileModel];
        } break;
    }
    return items;
}

/// 根据面板类型获取更多对应的选项
/// @param selectMsgType 面板类型
-(NSArray *)loadMoreSelectItemWithSelectMsgType:(IM_SelectMsgType)selectMsgType targetId:(NSString *)targetId groupId:(NSString *)groupId {
    IM_SelectMsgModel *groupMemberModel = [self createSelectModelTitle:@"群成员" link:@"" image:@"im_sel_members" type:(IM_SelectItemType_Link)];
    IM_SelectMsgModel *logModel = [self createSelectModelTitle:@"日志统计" link:[NSString stringWithFormat:@"%@communication-group/preach-logs-statistics?groupId=%@", URL_H5, clearNilStr(groupId)] image:@"im_sel_statistics" type:(IM_SelectItemType_Link)];
    IM_SelectMsgModel *settingModel = [self createSelectModelTitle:@"设置" link:[NSString stringWithFormat:@"%@communication-group/setting?groupId=%@&dzjUserId=%@", URL_H5, clearNilStr(groupId), clearNilStr(targetId)] image:@"im_sel_setting" type:(IM_SelectItemType_Link)];
    
    NSArray *items = @[];
    switch (selectMsgType) {
        case IM_SelectMsgType_BRANCH_CENTER:
        case IM_SelectMsgType_COMPANY_GROUP: {
            groupMemberModel.selectLink = [NSString stringWithFormat:@"%@communication-group/group-member-list?groupId=%@&readOnly=true&type=SIMPLE", URL_H5, clearNilStr(groupId)];
            items = @[groupMemberModel];
        } break;
        case IM_SelectMsgType_CONFERENCE_GROUP: {
            groupMemberModel.selectLink = [NSString stringWithFormat:@"%@communication-group/group-member-list?groupId=%@&readOnly=true&type=CONFERENCE", URL_H5, clearNilStr(groupId)];
            items = @[groupMemberModel];
        } break;
        case IM_SelectMsgType_WORKING_GROUP: {
            groupMemberModel.selectLink = [NSString stringWithFormat:@"%@communication-group/group-member-list?groupId=%@&type=WORKING", URL_H5, clearNilStr(groupId)];
            items = @[groupMemberModel, logModel, settingModel];
        } break;
        case IM_SelectMsgType_USER:
        case IM_SelectMsgType_COMPANY_BUSINESS_SERVICE:
        case IM_SelectMsgType_PESTILENCE_WARNING_V2:
        case IM_SelectMsgType_Default:{
            items = @[];
        } break;
        default: {
            items = @[];
        } break;
    }
    return items;
}

#pragma mark - private

-(IM_SelectMsgModel *)createSelectModelTitle:(NSString *)title link:(NSString *)link image:(NSString *)image type:(IM_SelectItemType)type {
    IM_SelectMsgModel *model = [[IM_SelectMsgModel alloc] init];
    model.selectTitle = clearNilStr(title);
    model.selectLink = clearNilStr(link);
    model.selectImage = clearNilStr(image);
    model.selectType = type;
    return model;
}

@end
