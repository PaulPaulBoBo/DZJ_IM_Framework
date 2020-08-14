//
//  IM_AudioTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_AudioTableViewCell.h"
//im_voice_icon
@interface IM_AudioTableViewCell()

@property (nonatomic, strong) UIImageView *voiceImageView; // 左侧图标
@property (nonatomic, strong) UILabel *voiceTimeLabel; // 语音时长标签

@end

static CGFloat MinTimeLabelWidth = 30; // 最小时间标签宽度
static CGFloat VoiceContainerHeigh = 20; // 承载视图高度

@implementation IM_AudioTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    if(data.voiceModel) {
        if(data.voiceModel.duration.floatValue > 0) {
            self.voiceTimeLabel.text = [NSString stringWithFormat:@"%.0lf'", data.voiceModel.duration.floatValue];
            [self loadCustomViewIsSend:[data.fromUserId isEqualToString:[UserStorage sharedInstance].userInfo.userID] duration:data.voiceModel.duration.floatValue];
        }
    }
}

// 启动语音播放动画
-(void)startVoiceAnimation {
    NSArray *imageArray = @[[UIImage imageNamed:@"im_voice_icon_1"], [UIImage imageNamed:@"im_voice_icon_2"], [UIImage imageNamed:@"im_voice_icon_3"]];
    self.voiceImageView.animationImages = imageArray;
    self.voiceImageView.animationDuration = 1;
    self.voiceImageView.animationRepeatCount = 0; //循环次数
    [self.voiceImageView startAnimating];
}

// 停止语音播放动画
-(void)stopVoiceAnimation {
    [self.voiceImageView stopAnimating];
}

#pragma mark - life

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadCustomViewIsSend:NO duration:0];
    }
    return self;
}

#pragma mark - private

-(void)loadCustomViewIsSend:(BOOL)isSend duration:(CGFloat)duration {
    if(self.voiceImageView.superview == nil) {
        [self.container addSubview:self.voiceImageView];
    }
    if(isSend) {
        self.voiceImageView.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        self.voiceImageView.transform = CGAffineTransformMakeRotation(0);
    }
    [self.voiceImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(isSend) {
            make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace/2.0));
        } else {
            make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        }
        
        make.top.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.bottom.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.height.width.equalTo(@(VoiceContainerHeigh));
    }];
    
    if(self.voiceTimeLabel.superview == nil) {
        [self.container addSubview:self.voiceTimeLabel];
    }
    [self.voiceTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(isSend) {
            make.right.equalTo(self.voiceImageView.mas_left).offset(-(self.containerInnerBoardSpace/2.0));
            make.left.equalTo(self.container).offset(self.containerInnerBoardSpace).offset(duration);
        } else {
            make.left.equalTo(self.voiceImageView.mas_right).offset(self.containerInnerBoardSpace/2.0);
            make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace/2.0));
        }
        
        make.top.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.bottom.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.height.equalTo(@(VoiceContainerHeigh));
        make.width.greaterThanOrEqualTo(@(MinTimeLabelWidth));
    }];
}

#pragma mark - lazy

-(UIImageView *)voiceImageView {
    if(_voiceImageView == nil) {
        _voiceImageView = [[UIImageView alloc] init];
        _voiceImageView.image = [UIImage imageNamed:@"im_voice_icon_3"];
        _voiceImageView.contentMode = UIViewContentModeScaleAspectFit;
        _voiceImageView.userInteractionEnabled = YES;
    }
    return _voiceImageView;
}

-(UILabel *)voiceTimeLabel {
    if(_voiceTimeLabel == nil) {
        _voiceTimeLabel = [[UILabel alloc] init];
        _voiceTimeLabel.font = [UIFont systemFontOfSize:15];
        _voiceTimeLabel.textColor = [UIColor colorWithHexString:@"0x2dc4c0"];
        _voiceTimeLabel.textAlignment = NSTextAlignmentCenter;
        _voiceTimeLabel.numberOfLines = 0;
        _voiceTimeLabel.userInteractionEnabled = YES;
    }
    return _voiceTimeLabel;
}

@end
