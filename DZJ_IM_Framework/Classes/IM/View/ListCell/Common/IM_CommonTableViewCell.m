//
//  IM_CommonTableViewCell.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/17.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_CommonTableViewCell.h"

@interface IM_CommonTableViewCell()

@end

@implementation IM_CommonTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    [self updateLinkLayer:clearNilStr(data.commonModel.imgUrl).length > 0];
    self.linkTitleLabel.text = clearNilStr(data.commonModel.name);
    self.linkTitleLabel.numberOfLines = 0;
    self.linkSubTitleLabel.text = clearNilStr(data.commonModel.summary);
    self.linkSubTitleLabel.numberOfLines = 0;
}

#pragma mark - private

- (void)updateLinkLayer:(BOOL)hasImage {
    if(self.linkImage.superview != nil) {
        if(!hasImage) {
            [self.linkImage removeFromSuperview];
            
            if(self.linkTitleLabel.superview == nil) {
                [self.container addSubview:self.linkTitleLabel];
            }
            [self.linkTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
                make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
                make.top.equalTo(self.container).offset(self.containerInnerBoardSpace);
                make.bottom.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
            }];
            
            if(self.linkSubTitleLabel.superview == nil) {
                [self.container addSubview:self.linkSubTitleLabel];
            }
            [self.linkSubTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
                make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
                make.top.equalTo(self.linkTitleLabel.mas_bottom).offset(self.containerInnerBoardSpace);
                make.bottom.lessThanOrEqualTo(self.container).offset(-(self.containerInnerBoardSpace));
            }];
        } else {
            [self.linkImage loadImageWithURL:clearNilStr(self.data.commonModel.imgUrl)];
        }
    }
}

@end
