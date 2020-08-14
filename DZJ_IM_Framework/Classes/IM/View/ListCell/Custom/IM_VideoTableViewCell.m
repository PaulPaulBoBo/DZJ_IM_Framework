//
//  IM_VideoTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_VideoTableViewCell.h"

@interface IM_VideoTableViewCell()

@end

@implementation IM_VideoTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    if(data.videoModel) {
        self.linkTitleLabel.text = data.videoModel.name;
        if(data.videoModel.img != nil && data.videoModel.img.length > 0) {
            [self.linkImage loadImageWithURL:data.videoModel.img placeholder:[UIImage imageNamed:@"4_3PlaceholdeImg"] completed:^(UIImage *image, NSError *error) {
                
            }];
        }
        [self.linkSubTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.linkTitleLabel.mas_bottom);
        }];
    }
}

@end
