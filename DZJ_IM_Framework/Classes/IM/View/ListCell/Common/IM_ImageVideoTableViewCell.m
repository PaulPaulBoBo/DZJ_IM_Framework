//
//  IM_ImageVideoTableViewCell.m
//  DoctorCloud
//
//  Created by dzj on 2020/7/28.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_ImageVideoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "IM_RequestManager.h"

@interface IM_ImageVideoTableViewCell()

@property (nonatomic, strong) UIImageView *imageVideoView;
@property (nonatomic, strong) UIImageView *playImageVideoView;

@end

static CGFloat ImageVideoSpace = 0;
static CGFloat ImageVideoSide = 150;

@implementation IM_ImageVideoTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    @weakify(self)
    [super fillWithData:data];
    self.arrowImageView.hidden = YES;
    self.imgView.hidden = YES;
    self.imageVideoView.image = self.imageVideoView.image?self.imageVideoView.image:[UIImage imageNamed:@"4_3PlaceholdeImg"];
    if(data.fileModel) {
        if(data.state == IM_MessageStateSending) {
            self.imageVideoView.image = data.fileModel.snapImage?data.fileModel.snapImage:[UIImage imageNamed:@"4_3PlaceholdeImg"];
            if(self.imageVideoView.image) {
                [self.imageVideoView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(self.imageVideoView.image.size.width/self.imageVideoView.image.size.height*ImageVideoSide));
                }];
                self.imgView.hidden = NO;
            }
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @strongify(self)
            NSString *videoUrl = clearNilStr(data.fileModel.url);
            if([videoUrl rangeOfString:@"http"].length == 0) {
                videoUrl = [NSString stringWithFormat:@"%@%@", clearNilStr([IM_RequestManager shareInstance].im_file_url), clearNilStr(data.fileModel.url)];
            }
            [self getThumbnailImage:videoUrl finish:^(UIImage *image, NSString *videoURLStr) {
                if(clearNilStr(videoURLStr).length > 0 && [clearNilStr(videoURLStr) rangeOfString:clearNilStr(data.fileModel.url)].length > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageVideoView.image = image;
                        if(image) {
                            [self.imageVideoView mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.width.equalTo(@(image.size.width/image.size.height*ImageVideoSide));
                            }];
                            self.imgView.hidden = NO;
                        }
                    });
                }
            }];
        });
    }
}

#pragma mark - life

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadCustomView];
    }
    return self;
}

#pragma mark - private

-(void)loadCustomView {
    if(self.imageVideoView.superview == nil) {
        [self.container addSubview:self.imageVideoView];
    }
    [self.imageVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(ImageVideoSpace);
        make.right.equalTo(self.container).offset(-ImageVideoSpace);
        make.top.equalTo(self.container).offset(ImageVideoSpace);
        make.bottom.equalTo(self.container).offset(-ImageVideoSpace);
        make.width.equalTo(@(ImageVideoSide));
        make.height.equalTo(@(ImageVideoSide));
    }];
    
    [self layoutIfNeeded];
    if(self.playImageVideoView.superview == nil) {
        [self.imageVideoView addSubview:self.playImageVideoView];
    }
    
    [self.playImageVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.imageVideoView.mas_centerX);
        make.centerY.equalTo(self.imageVideoView.mas_centerY);
        make.width.height.equalTo(@30);
    }];
}

- (void)getThumbnailImage:(NSString*)videoURL finish:(void(^)(UIImage *image, NSString *videoURLStr))finish {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:videoURL] options:nil];
    NSParameterAssert(asset);//断言
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    NSTimeInterval time = 0.1;
    CGImageRef thumbnailImageRef =NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *error =nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime,60) actualTime:NULL error:&error];
    if(error) {
        NSLog(@"%@", error );
    }
    if(thumbnailImageRef) {
        if(finish) {
            finish([[UIImage alloc] initWithCGImage:thumbnailImageRef], videoURL);
        }
    }
}
#pragma mark - lazy

-(UIImageView *)imageVideoView {
    if(_imageVideoView == nil) {
        _imageVideoView = [[UIImageView alloc] init];
        _imageVideoView.contentMode = UIViewContentModeScaleAspectFill;
        _imageVideoView.userInteractionEnabled = YES;
    }
    return _imageVideoView;
}

-(UIImageView *)playImageVideoView {
    if(_playImageVideoView == nil) {
        _playImageVideoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"im_play"]];
        _playImageVideoView.contentMode = UIViewContentModeScaleAspectFill;
        _playImageVideoView.userInteractionEnabled = YES;
        _playImageVideoView.backgroundColor = [UIColor whiteColor];
        [_playImageVideoView round:15];
    }
    return _playImageVideoView;
}

@end
