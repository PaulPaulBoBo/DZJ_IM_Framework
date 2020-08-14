//
//  IM_ShowPlayVideoView.m
//  DoctorCloud
//
//  Created by dzj on 2020/7/28.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_ShowPlayVideoView.h"
#import <AVKit/AVKit.h>

@interface IM_ShowPlayVideoView()

@property (nonatomic, strong) DidClickCloseBtnBlock didClickCloseBtnBlock;
@property (nonatomic, copy  ) NSString *videoUrl;

@end

@implementation IM_ShowPlayVideoView

#pragma mark - Public

// 弹出视频播放视图
-(void)showVideoWithVideoUrl:(NSString *)videoUrl didClickReadBtnBlock:(DidClickCloseBtnBlock)didClickCloseBtnBlock {
    @weakify(self)
    NSURL *webVideoUrl = nil;
    NSString *cachePath = [self loadLocalCachePathWithUrl:videoUrl];
    if(cachePath != nil) {
        webVideoUrl = [NSURL fileURLWithPath:cachePath];
    } else {
        webVideoUrl = [NSURL URLWithString:clearNilStr(videoUrl)];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @strongify(self)
            [self saveVideoWithUrl:videoUrl];
        });
    }

    AVPlayerViewController *ctrl = [[AVPlayerViewController alloc] init];
    ctrl.player = [[AVPlayer alloc] initWithURL:webVideoUrl];
    [[DZJRouter sharedInstance].currentViewController presentViewController:ctrl animated:YES completion:nil];
    [ctrl.player play];
}

-(NSString *)loadLocalCachePathWithUrl:(NSString *)videoUrl {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", cachesDir, [videoUrl componentsSeparatedByString:@"/"].lastObject];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        filePath = nil;
    }
    return filePath;
}

-(void)saveVideoWithUrl:(NSString *)videoUrl {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", cachesDir, [videoUrl componentsSeparatedByString:@"/"].lastObject];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:clearNilStr(videoUrl)]];
    if(data) {
        [data writeToFile:filePath atomically:YES];
    }
}

@end
