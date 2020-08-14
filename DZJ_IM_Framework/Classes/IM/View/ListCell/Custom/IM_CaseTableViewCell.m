//
//  IM_CaseTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_CaseTableViewCell.h"

@interface IM_CaseTableViewCell()

@end

@implementation IM_CaseTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    if(data.caseModel) {
        [self updateLinkLayer];
        self.linkTitleLabel.text = clearNilStr(data.caseModel.diseaseName);
        self.linkSubTitleLabel.text = clearNilStr(data.caseModel.caseSummary);
    }
}

#pragma mark - private

- (void)updateLinkLayer {
    if(self.linkImage.superview != nil) {
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
    }
}

@end
