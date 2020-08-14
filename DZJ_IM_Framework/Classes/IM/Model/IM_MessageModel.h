//
//  IM_MessageModel.h
//  L_Chat
//
//  Created by dzj on 2020/6/8.
//  Copyright © 2020 paul. All rights reserved.
//

#import "JSONModel.h"

typedef enum : NSUInteger {
    IM_MessageStateSending,  // 发送中 默认
    IM_MessageStateSended,   // 已发送
    IM_MessageStateSendFail, // 发送失败
    IM_MessageStateDeteting, // 删除中
    IM_MessageStateDeleted,   // 已删除
    IM_MessageStateUnsend   // 未发送
} IM_MessageState;

typedef enum : NSUInteger {
    IM_MsgTypeDefault, // 默认类型 按通用样式处理
    IM_MsgTypeText, // 文本 TEXT
    IM_MsgTypeImage, // 图片 IMAGE
    IM_MsgTypeImageVideo, // 从相册选择的视频 FILE
    IM_MsgTypeVideo, // 分享的视频 VIDEO
    IM_MsgTypeFile, // 文件 FILE
    IM_MsgTypeAudio, // 语音 VOICE
    IM_MsgTypeMSL, // 宣讲日志 MSL_PREACH_LOG
    IM_MsgTypeNews, // 新闻 NEWS
    IM_MsgTypePopular, // 科普 POPULAR
    IM_MsgTypeArticle, // 文章 ARTICLE
    IM_MsgTypeCase, // 病历 CASE
    IM_MsgTypeNotice, // 公告 NOTICE
    IM_MsgTypeHealthRecord, // 健康咨询
    IM_MsgTypeApplaud, // 互动消息鼓掌喝彩
    IM_MsgTypeFlower, // 互动消息送花
    IM_MsgTypeFirsJoinGroup, // 第一次进群消息提示
    IM_MsgTypeCreateGroup // 新建群消息提示
} IM_MsgType;

NS_ASSUME_NONNULL_BEGIN

@interface IM_JSONModel : JSONModel

@end

// 视频类型消息子模型
@interface IM_VideoContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *name; // 标题
@property (nonatomic, copy  ) NSString *video_id; // id
@property (nonatomic, copy  ) NSString *img; // 图片地址

@end

// 文件类型消息子模型
@interface IM_FileContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *name; // 文件名
@property (nonatomic, copy  ) NSString *url; // 文件地址
@property (nonatomic, strong) NSNumber *size; // 文件大小 B

@property (nonatomic, strong) NSData *fileData; // data类型文件 本地定义，用于上传
@property (nonatomic, copy  ) NSString *fileName; // data类型文件的名字，用于上传
@property (nonatomic, strong) UIImage *snapImage; // 视频的快览图 仅用于从相册或文件选择视频
@end

// 宣讲日志类型消息子模型
@interface IM_MSLContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *preachId; // 宣讲id
@property (nonatomic, copy  ) NSString *preachTheme; // 主题
@property (nonatomic, strong) NSDate *preachTime; // 时间
@property (nonatomic, strong) NSArray *preachAttachment; // 图片数组

@end

// 新闻和科普类型消息子模型
@interface IM_NewsContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *imgUrl; // 图片地址
@property (nonatomic, copy  ) NSString *newsTitle; // 标题
@property (nonatomic, copy  ) NSString *newsId; // 新闻或科普id

@end

// 文章类型消息子模型
@interface IM_ArticleContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *title; // 标题
@property (nonatomic, copy  ) NSString *summary; // 摘要
@property (nonatomic, copy  ) NSString *productId; // id

@end

// 病历类型消息子模型
@interface IM_CaseContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *diseaseName; // 疾病名
@property (nonatomic, copy  ) NSString *caseSummary; // 摘要
@property (nonatomic, copy  ) NSString *productId; // id

@end

// 公告类型消息子模型
@interface IM_NoticeContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *notice; // 公告内容

@end

// 健康咨询类型消息子模型
@interface IM_HealthRecordContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *content; //

@end

// 语音类型消息子模型
@interface IM_VoiceContentModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *url; // 语音地址
@property (nonatomic, strong) NSNumber *duration; // 语音时长
@property (nonatomic, strong) NSDictionary *blob; // 未知

@property (nonatomic, strong) NSData *voiceData; // data类型语音 本地定义，用于上传
@property (nonatomic, copy  ) NSString *voiceName; // data类型语音的临时名字 本地定义，用于上传

@end

/// 通用类型消息
@interface IM_CommonMessageModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *name; // 标题
@property (nonatomic, copy  ) NSString *summary; // 摘要
@property (nonatomic, copy  ) NSString *miniProgramUrl; // 跳转链接
@property (nonatomic, copy  ) NSString *h5Url; // 跳转链接
@property (nonatomic, copy  ) NSString *nativeUrl; // 跳转链接
@property (nonatomic, copy  ) NSString *imgUrl; // 图片地址

@end

/// 消息模型
@interface IM_MessageModel : IM_JSONModel

@property (nonatomic, copy  ) NSString *IM_id; // 消息id
@property (nonatomic, strong) NSDate *createdTime; // 消息创建时间
@property (nonatomic, strong) NSDate *updatedTime; // 消息更新时间
@property (nonatomic, strong) NSArray *tags; // 消息所有者标签组
@property (nonatomic, copy  ) NSString *contentType; // 消息类型
@property (nonatomic, copy  ) NSString *source; // 未知
@property (nonatomic, assign) BOOL isDeleted; // 是否撤销
@property (nonatomic, copy  ) NSString *fromUserId; // 发送者Id
@property (nonatomic, copy  ) NSString *toUserId; // 接收者Id
@property (nonatomic, copy  ) NSString *nickName; // 昵称
@property (nonatomic, copy  ) NSString *avatar; // 头像地址
@property (nonatomic, copy  ) NSString *targetType; // 聊天类型 单聊-USER 群聊-GROUP
@property (nonatomic, copy  ) NSString *gender; // 性别
@property (nonatomic, copy  ) NSString *content; // 消息内容

/*
 contentType
 "TEXT",                    -> 纯文本类型，content为纯文字
 "IMAGE",                   -> 图片类型，content为图片的地址
 "VIDEO",                   -> 视频类型，content为json格式的字典字符串，"{\"name\":\"...\",\"id\":\"2073\",\"img\":\"http:...\"}"
 "FILE",                    -> 文件类型，content为json格式的字典字符串，"{\"name\":\"文字.svg\",\"url\":\"http://...\",\"size\":960}"
 "MSL_PREACH_LOG",          -> 宣讲日志，content为json格式的字典字符串，"{\"preachId\":186,\"preachTheme\":\"111\",\"preachTime\":\"2020-06-15T08:52:19.263Z\",\"preachAttachment\":[\"2020/06/15/5ee736e5e4b0e6314c1b2521.png\"]}"
 "NEWS",                    -> 新闻类型，content为json格式的字典字符串，"{\"imgUrl\":\"2020/05/04/5eaf35a9e4b0f2212f94af6e\",\"newsTitle\":\"场景测试标题2020-05-04 05:18:47.937\",\"newsId\":2317}"
 "ARTICLE",                 -> 文章类型，content为json格式的字典字符串，"{\"title\":\"...\",\"summary\":\"...\",\"productId\":1100524}"
 "CASE",                    -> 病历类型，content为json格式的字典字符串，"{\"diseaseName\":\"干眼综合征,兔眼\",\"caseSummary\":\"FBl3cp94RTf9k8AZYT92SbDys58ojHFHsc074TXJV83Lu12h8d\",\"productId\":1107960}"
 "POPULAR",                 -> 科普 同NEWS
 "NOTICE",                  -> 公告，content为json格式的字典字符串，"{\"notice\":\"jdjdj\"}"
 "HEALTH_RECORD",           -> 健康咨询，content为纯文本，需要在文字下方给出当前用户的健康档案跳转入口
 "VOICE"                    -> 语音类型，content为json格式的字典字符串，{\"duration\":78,\"blob\":{},\"url\":\"2020/05/27/5ecddc50e4b09a8306b6b51f\"}
 "INTERACTION_APPLAUD"      -> 互动消息鼓掌喝彩类型，content为纯字符串 "互动消息"
 "INTERACTION_FLOWERS"      -> 互动消息送花类型，content为纯字符串 "互动消息"
 */

// 以下为自定义属性
@property (nonatomic, assign) IM_MessageState state; // 消息发送和删除状态
@property (nonatomic, assign) BOOL isSelfSend; // 是否是自己发送的 YES-自己发的 NO-接收到的
@property (nonatomic, assign) BOOL isShowTime; // 是否展示时间 与前一条数据中的updatedTime对比 当时间间隔大于某个规定时间时展示 YES-展示，NO-不展示
@property (nonatomic, copy  ) NSString *localStateId; // 此id默认为空字符串，当消息发送中或发送失败进行重发时有临时生成的唯一值，用于更新状态使用，更新完成后恢复空字符串
@property (nonatomic, assign) IM_MsgType msgType; // 消息类型contentType的枚举值转化
@property (nonatomic, copy  ) NSString *targetId; // 所在会话id
@property (nonatomic, strong) NSData *imageData; // 上传过程中的本地图片data
@property (nonatomic, copy  ) NSString *dzjUserId; // 会话id 目前只有被邀请入群通知消息（IM_JOIN_GROUP）用到此id
@property (nonatomic, copy  ) NSString *groupId; // 群id 目前只有被邀请入群通知消息（IM_JOIN_GROUP）用到此id
@property (nonatomic, copy  ) NSString *type; // 通知类型 目前只有被邀请入群通知消息（IM_JOIN_GROUP）会用到此id

// 以下是自定义的模型 是 content JSON字符串根据 contentType 转换出来的
@property (nonatomic, strong) IM_VideoContentModel *videoModel; // 视频消息内容
@property (nonatomic, strong) IM_FileContentModel *fileModel; // 视频消息内容
@property (nonatomic, strong) IM_MSLContentModel *mslModel; // 宣讲日志消息内容
@property (nonatomic, strong) IM_NewsContentModel *newsModel; // 新闻和科普消息内容
@property (nonatomic, strong) IM_ArticleContentModel *articleModel; // 文章消息内容
@property (nonatomic, strong) IM_CaseContentModel *caseModel; // 病历消息内容
@property (nonatomic, strong) IM_NoticeContentModel *noticeModel; // 公告消息内容
@property (nonatomic, strong) IM_HealthRecordContentModel *healthRecordModel; // 健康咨询消息内容
@property (nonatomic, strong) IM_VoiceContentModel *voiceModel; // 语音消息内容
@property (nonatomic, strong) IM_CommonMessageModel *commonModel; // 其他消息内容

/// 创建发送模型
/// @param msgType 消息类型
/// @param content 消息内容
/// @param targetType 聊天类型 单聊-USER 群聊-GROUP
/// @param targetId 所在会话id
+(IM_MessageModel *)createModelWithMsgType:(IM_MsgType)msgType
                                   content:(NSString *)content
                                targetType:(NSString *)targetType
                                  targetId:(NSString *)targetId;
@end

NS_ASSUME_NONNULL_END
