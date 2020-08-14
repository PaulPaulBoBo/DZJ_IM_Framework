//
//  IM_OperationMsgManager.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/22.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_OperationMsgManager.h"
#import "ZLPhoto.h"
#import "IM_CellHeader.h"
#import "IM_AudioPlayManager.h" // 播放录音管理器
#import "IM_ShowNoticeView.h" // 展示群公告视图
#import "IM_RequestManager.h" // 消息请求类
#import "DZJConstants_interface.h"
#import "IM_ShowPlayVideoView.h" // 视频播放

@interface IM_OperationMsgManager()<ZLPhotoPickerBrowserViewControllerDelegate>

@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIView *tmpView;
@property (nonatomic, strong) IM_AudioPlayManager *audioPlayManager; // 语音播放控制器
@property (nonatomic, strong) IM_BasicCellTableViewCell *operatingCell; // 当前被操作的cell
@property (nonatomic, strong) IM_ShowNoticeView *showNoticeView; // 展示群公告视图

@end

static BOOL isPlayingVoice = NO; // 当前是否正在播放录音

@implementation IM_OperationMsgManager

#pragma mark - public

/// 配置视图控制器
/// @param viewController 聊天页面控制器
-(void)configViewController:(UIViewController *)viewController {
    self.rootViewController = viewController;
}

/// 点击消息
/// @param cell cell
-(void)tapMsgCell:(IM_BasicCellTableViewCell *)cell {
    if(cell.data.state == IM_MessageStateSended) {
        self.operatingCell = cell;
        switch (cell.data.msgType) {
            case IM_MsgTypeText: {
                // 文本
            } break;
            case IM_MsgTypeImage: {
                // 图片
                if(cell.data.fileModel != nil) {
                    [self showEditPhotoVCWithPhotoURL:clearNilStr(cell.data.fileModel.url)];
                } else {
                    [self showEditPhotoVCWithPhotoURL:clearNilStr(cell.data.content)];
                }
            } break;
            case IM_MsgTypeImageVideo: {
                // 从相册选择的视频
                IM_ShowPlayVideoView *playVideo = [[IM_ShowPlayVideoView alloc] init];
                [playVideo showVideoWithVideoUrl:[NSString stringWithFormat:@"%@%@", clearNilStr([IM_RequestManager shareInstance].im_file_url), clearNilStr(cell.data.fileModel.url)] didClickReadBtnBlock:^{
                    
                }];
            } break;
            case IM_MsgTypeVideo: {
                // 视频
                if(cell.data.videoModel) {
                    [DZJRouter openURL:@"video/detail" query:@{@"videoId" : [NSString stringWithFormat:@"%@", cell.data.videoModel.video_id]} animated:YES];
                }
            } break;
            case IM_MsgTypeFile: {
                // 文件
                if(cell.data.fileModel) {
                    NSString *urlStr = [NSString stringWithFormat:@"%@%@", clearNilStr([IM_RequestManager shareInstance].im_file_url), cell.data.fileModel.url];
                    [DZJRouter openURL:@"doc/detail" query:@{@"name":clearNilStr(cell.data.fileModel.name), @"url":urlStr} animated:YES];
                }
            } break;
            case IM_MsgTypeAudio: {
                // 语音
                if(cell.data.voiceModel.voiceData == nil) {
                    if([cell.data.voiceModel.url rangeOfString:@"http"].length > 0) {
                        cell.data.voiceModel.voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:cell.data.voiceModel.url]];
                    } else {
                        cell.data.voiceModel.voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", clearNilStr([IM_RequestManager shareInstance].im_file_url), cell.data.voiceModel.url]]];
                    }
                }
                [self startPlayAudio:cell.data.voiceModel.voiceData];
            } break;
            case IM_MsgTypeMSL: {
                // 宣讲日志
                if(cell.data.mslModel) {
                    [self openLink:[NSString stringWithFormat:@"%@communication-group/preach-log-detail?logId=%@", URL_H5, cell.data.mslModel.preachId]];
                }
            } break;
            case IM_MsgTypeNews:
            case IM_MsgTypePopular: {
                // 新闻 科普
                if(cell.data.newsModel) {
                    [self openLink:[NSString stringWithFormat:@"%@%@%@", URL_H5, @"news/view/",clearNilStr(cell.data.newsModel.newsId)]];
                }
            } break;
            case IM_MsgTypeArticle: {
                // 文章
                if(cell.data.articleModel) {
                    [self openLink:[NSString stringWithFormat:@"%@",cell.data.articleModel]];
                }
            } break;
            case IM_MsgTypeCase: {
                // 病历
                if(cell.data.caseModel) {
                    [self openLink:[NSString stringWithFormat:URL_H5_market_case_detail, cell.data.caseModel.productId]];
                }
            } break;
            case IM_MsgTypeNotice: {
                // 公告
                if(cell.data.noticeModel) {
                    [self showNotice:clearNilStr(cell.data.noticeModel.notice)];
                }
            } break;
            case IM_MsgTypeHealthRecord: {
                // 健康咨询
                if(cell.data.healthRecordModel) {
                    [self openLink:[NSString stringWithFormat:@"%@to_c/health-file/index?patientId=%@&isPay=true", URL_H5, cell.data.fromUserId]];
                }
            } break;
            case IM_MsgTypeDefault: {
                // 通用类型
                if(cell.data.commonModel) {
                    if(clearNilStr(cell.data.commonModel.nativeUrl).length > 0) {
                        [DZJRouter openURL:clearNilStr(cell.data.commonModel.nativeUrl) query:nil animated:YES];
                    } else if(clearNilStr(cell.data.commonModel.h5Url).length > 0) {
                        [self openLink:clearNilStr(cell.data.commonModel.h5Url)];
                    }
                }
            } break;
            default:
                // 其他未知类型
                break;
        }
    }
}

/// 长按消息
/// @param cell cell
-(void)longPressMsgCell:(IM_BasicCellTableViewCell *)cell {
    
}

// 点击头像
-(void)tapMsgAvatarCell:(IM_BasicCellTableViewCell *)cell {
    [DZJRouter openURL:@"webview" query:@{@"link":[NSString stringWithFormat:@"/user/homepage/%@", cell.data.fromUserId]} animated:YES];
}

// 停止播放录音
-(void)stopPlayAudio:(IM_BasicCellTableViewCell *)cell {
    self.operatingCell = cell;
    [self stopPlayAudio];
}

// 获取正在播放语音的cell 有-直接返回cell 没有-返回nil
-(IM_BasicCellTableViewCell *)playingVoiceCell {
    if(isPlayingVoice) {
        return self.operatingCell;
    } else {
        return nil;
    }
}

#pragma mark - private

// 弹出公告弹窗
-(void)showNotice:(NSString *)notice {
    [self.showNoticeView showNoticeWithTitle:@"群公告" content:clearNilStr(notice) didClickReadBtnBlock:^{
    }];
}

// 在webView中打开链接
-(void)openLink:(NSString *)link {
    if(link != nil && link.length > 0 && clearNilStr(link).length > 0) {
        [DZJRouter openURL:@"webview" query:@{@"link":clearNilStr(link)} animated:YES];
    }
}

// 开始播放录音
-(void)startPlayAudio:(NSData *)data {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isPlayingVoice = YES;
        [weakSelf.audioPlayManager startPlayWithData:data];
    });
}

// 结束当前正在播放的录音
-(void)stopPlayAudio {
    [self.audioPlayManager stopPlaying];
}

#pragma mark - delegate
- (void)showEditPhotoVCWithPhotoURL:(NSString *)photoURL {
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto new];
    if([photoURL rangeOfString:@"http"].length == 0) {
        photoURL = [NSString stringWithFormat:@"%@%@", URL_downloadImage, photoURL];
    }
    photo.photoURL = [NSURL URLWithString:photoURL];
    pickerBrowser.photos = [@[photo] mutableCopy];
    
    // 是否可以删除照片
    pickerBrowser.editing = NO;
    // 传入组
    pickerBrowser.currentIndex = 0;
    pickerBrowser.delegate = self;
    pickerBrowser.hideSelected = YES;
    
    pickerBrowser.reeditBlock = ^(NSMutableArray *editedAssets) {
    };
    [pickerBrowser showPushPickerVc:[DZJRouter sharedInstance].currentViewController];
}

#pragma mark - lazy

-(UIViewController *)rootViewController {
    if(_rootViewController == nil) {
        _rootViewController = [DZJRouter sharedInstance].currentViewController;
    }
    return _rootViewController;
}

-(IM_AudioPlayManager *)audioPlayManager {
    if(_audioPlayManager == nil) {
        _audioPlayManager = [IM_AudioPlayManager shareInstance];
        @weakify(self)
        [_audioPlayManager configStartPlayingBlock:^(BOOL isPlaying) {
            @strongify(self)
            if(isPlaying) {
                isPlayingVoice = NO;
                [_audioPlayManager stopPlaying];
                NSLog(@"正在播放的录音已停止...");
                [((IM_AudioTableViewCell *)self.operatingCell) stopVoiceAnimation];
            } else {
                NSLog(@"正在播放录音...");
                isPlayingVoice = YES;
                [((IM_AudioTableViewCell *)self.operatingCell) startVoiceAnimation];
            }
        } playCompleteBlock:^(BOOL hasError) {
            @strongify(self)
            NSLog(@"结束播放录音...");
            isPlayingVoice = NO;
            [((IM_AudioTableViewCell *)self.operatingCell) stopVoiceAnimation];
        } playingProcessBlock:^(CGFloat playingProcess) {
        }];
    }
    return _audioPlayManager;
}

-(IM_ShowNoticeView *)showNoticeView {
    if(_showNoticeView == nil) {
        _showNoticeView = [[IM_ShowNoticeView alloc] init];
    }
    return _showNoticeView;
}

@end
