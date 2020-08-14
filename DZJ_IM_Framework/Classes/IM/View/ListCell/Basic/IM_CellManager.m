//
//  IM_CellManager.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/17.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_CellManager.h"

@interface IM_CellManager()

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *Identifier_Text = @"IM_TextTableViewCell";
static NSString *Identifier_Image = @"IM_ImageTableViewCell";
static NSString *Identifier_ImageVideo = @"IM_ImageVideoTableViewCell";
static NSString *Identifier_Video = @"IM_VideoTableViewCell";
static NSString *Identifier_File = @"IM_FileTableViewCell";
static NSString *Identifier_MSL = @"IM_MSLTableViewCell";
static NSString *Identifier_News = @"IM_NewsTableViewCell";
static NSString *Identifier_Article = @"IM_ArticleTableViewCell";
static NSString *Identifier_Case = @"IM_CaseTableViewCell";
static NSString *Identifier_Notice = @"IM_NoticeTableViewCell";
static NSString *Identifier_HealthRecord = @"IM_HealthRecordTableViewCell";
static NSString *Identifier_Audio = @"IM_AudioTableViewCell";
static NSString *Identifier_Common = @"IM_CommonTableViewCell";

@implementation IM_CellManager

#pragma mark - public

// 配置列表 将cell注册操作封装进去
-(void)configTableView:(UITableView *)tableView {
    self.tableView = tableView;
    [tableView registerClass:[IM_TextTableViewCell class] forCellReuseIdentifier:Identifier_Text];
    [tableView registerClass:[IM_ImageTableViewCell class] forCellReuseIdentifier:Identifier_Image];
    [tableView registerClass:[IM_VideoTableViewCell class] forCellReuseIdentifier:Identifier_Video];
    [tableView registerClass:[IM_FileTableViewCell class] forCellReuseIdentifier:Identifier_File];
    [tableView registerClass:[IM_MSLTableViewCell class] forCellReuseIdentifier:Identifier_MSL];
    [tableView registerClass:[IM_NewsTableViewCell class] forCellReuseIdentifier:Identifier_News];
    [tableView registerClass:[IM_ArticleTableViewCell class] forCellReuseIdentifier:Identifier_Article];
    [tableView registerClass:[IM_CaseTableViewCell class] forCellReuseIdentifier:Identifier_Case];
    [tableView registerClass:[IM_NoticeTableViewCell class] forCellReuseIdentifier:Identifier_Notice];
    [tableView registerClass:[IM_HealthRecordTableViewCell class] forCellReuseIdentifier:Identifier_HealthRecord];
    [tableView registerClass:[IM_AudioTableViewCell class] forCellReuseIdentifier:Identifier_Audio];
    [tableView registerClass:[IM_CommonTableViewCell class] forCellReuseIdentifier:Identifier_Common];
    [tableView registerClass:[IM_CommonTableViewCell class] forCellReuseIdentifier:Identifier_Common];
}

// 根据数据源和下标返回对应的cell
-(id)loadCellWithModel:(IM_MessageModel *)model {
    if(model.msgType == IM_MsgTypeFile) {
        if([[model.fileModel.url lowercaseString] rangeOfString:@".mp4"].length > 0 ||
           [[model.fileModel.url lowercaseString] rangeOfString:@".wmv"].length > 0 ||
           [[model.fileModel.url lowercaseString] rangeOfString:@".avi"].length > 0 ||
           [[model.fileModel.url lowercaseString] rangeOfString:@".mpg"].length > 0 ||
           [[model.fileModel.url lowercaseString] rangeOfString:@".mpeg"].length > 0 ||
           [[model.fileModel.url lowercaseString] rangeOfString:@".mov"].length > 0) {
            model.msgType = IM_MsgTypeImageVideo;
        } else if([[model.fileModel.url lowercaseString] rangeOfString:@".jpg"].length > 0 ||
                  [[model.fileModel.url lowercaseString] rangeOfString:@".jpeg"].length > 0 ||
                  [[model.fileModel.url lowercaseString] rangeOfString:@".png"].length > 0 ||
                  [[model.fileModel.url lowercaseString] rangeOfString:@".svg"].length > 0 ||
                  [[model.fileModel.url lowercaseString] rangeOfString:@".psd"].length > 0 ||
                  [[model.fileModel.url lowercaseString] rangeOfString:@".tiff"].length > 0) {
            model.msgType = IM_MsgTypeImage;
        } else {
            model.msgType = IM_MsgTypeFile;
        }
    }
    IM_BasicCellTableViewCell *cell = [self loadCellWithType:model.msgType];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell fillWithData:model];
    return cell;
}

#pragma mark - private

// 根据消息类型创建cell
-(id)loadCellWithType:(IM_MsgType)type {
    IM_BasicCellTableViewCell *cell = nil;
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    switch (type) {
        case IM_MsgTypeText: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Text];
            if(cell == nil) {
                cell = [[IM_TextTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Text];
            }
        } break;
        case IM_MsgTypeImage: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Image];
            if(cell == nil) {
                cell = [[IM_ImageTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Image];
            }
        } break;
        case IM_MsgTypeImageVideo: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_ImageVideo];
            if(cell == nil) {
                cell = [[IM_ImageVideoTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_ImageVideo];
            }
        } break;
        case IM_MsgTypeVideo: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Video];
            if(cell == nil) {
                cell = [[IM_VideoTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Video];
            }
        } break;
        case IM_MsgTypeFile: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_File];
            if(cell == nil) {
                cell = [[IM_FileTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_File];
            }
        } break;
        case IM_MsgTypeMSL: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_MSL];
            if(cell == nil) {
                cell = [[IM_MSLTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_MSL];
            }
        } break;
        case IM_MsgTypeNews:
        case IM_MsgTypePopular: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_News];
            if(cell == nil) {
                cell = [[IM_NewsTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_News];
            }
        } break;
        case IM_MsgTypeArticle: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Article];
            if(cell == nil) {
                cell = [[IM_ArticleTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Article];
            }
        } break;
        case IM_MsgTypeCase: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Case];
            if(cell == nil) {
                cell = [[IM_CaseTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Case];
            }
        } break;
        case IM_MsgTypeNotice: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Notice];
            if(cell == nil) {
                cell = [[IM_NoticeTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Notice];
            }
        } break;
        case IM_MsgTypeHealthRecord: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_HealthRecord];
            if(cell == nil) {
                cell = [[IM_HealthRecordTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_HealthRecord];
            }
        } break;
        case IM_MsgTypeAudio: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Audio];
            if(cell == nil) {
                cell = [[IM_AudioTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Audio];
            }
        } break;
        case IM_MsgTypeDefault: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Common];
            if(cell == nil) {
                cell = [[IM_CommonTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Common];
            }
        } break;
        default: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier_Common];
            if(cell == nil) {
                cell = [[IM_CommonTableViewCell alloc] initWithStyle:(style) reuseIdentifier:Identifier_Common];
            }
        } break;
    }
    return cell;
}

@end
