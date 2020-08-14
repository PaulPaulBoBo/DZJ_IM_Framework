//
//  IM_NewsTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_NewsTableViewCell.h"

@interface IM_NewsTableViewCell()

@end

@implementation IM_NewsTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    if(data.newsModel) {
        self.linkTitleLabel.text = data.newsModel.newsTitle;
        if(data.newsModel.imgUrl != nil && data.newsModel.imgUrl.length > 0) {
            [self.linkImage loadImageWithURL:data.newsModel.imgUrl placeholder:[UIImage imageNamed:@"4_3PlaceholdeImg"] completed:^(UIImage *image, NSError *error) {
                
            }];
        }
        [self.linkSubTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.linkTitleLabel.mas_bottom);
        }];
    }
}

@end
