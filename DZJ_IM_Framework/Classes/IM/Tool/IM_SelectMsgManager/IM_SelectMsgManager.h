//
//  IM_SelectMsgManager.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/29.
//  Copyright © 2020 大专家.com. All rights reserved.
//  特殊类型消息展示面板数据处理

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    IM_SelectMsgType_BRANCH_CENTER, // 分中心聊天群
    IM_SelectMsgType_COMPANY_GROUP, // M端省总和联络员的群,M端省总和全国M端的群,机构管理员和运营的交流群
    IM_SelectMsgType_WORKING_GROUP, // G端交流群,工作交流群
    IM_SelectMsgType_CONFERENCE_GROUP, // 会议群
    IM_SelectMsgType_USER, // 个人聊天
    IM_SelectMsgType_COMPANY_BUSINESS_SERVICE, // 新增类型
    IM_SelectMsgType_PESTILENCE_WARNING_V2, // 新增类型-新冠肺炎
    IM_SelectMsgType_Default, // 默认类型
} IM_SelectMsgType; // 选择面板类型

typedef enum : NSUInteger {
    IM_SelectItemType_Image,
    IM_SelectItemType_File,
    IM_SelectItemType_Link,
} IM_SelectItemType; // 选择项类型

@interface IM_SelectMsgModel : JSONModel

@property (nonatomic, copy  ) NSString *selectTitle; // 标题
@property (nonatomic, copy  ) NSString *selectLink; // 跳转链接
@property (nonatomic, copy  ) NSString *selectImage; // 图标
@property (nonatomic, assign) IM_SelectItemType selectType; // 类型

@end

@interface IM_SelectMsgManager : NSObject

/// 根据面板类型获取加号对应的选项
/// @param selectMsgType 面板类型
/// @param targetId 聊天id
/// @param groupId 群id
-(NSArray *)loadAddSelectItemWithSelectMsgType:(IM_SelectMsgType)selectMsgType targetId:(NSString *)targetId groupId:(NSString *)groupId;

/// 根据面板类型获取更多对应的选项
/// @param selectMsgType 面板类型
/// @param targetId 聊天id
/// @param groupId 群id
-(NSArray *)loadMoreSelectItemWithSelectMsgType:(IM_SelectMsgType)selectMsgType targetId:(NSString *)targetId groupId:(NSString *)groupId;

@end

NS_ASSUME_NONNULL_END
