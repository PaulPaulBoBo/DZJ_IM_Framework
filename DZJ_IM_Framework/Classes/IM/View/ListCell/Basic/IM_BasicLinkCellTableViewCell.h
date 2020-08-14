//
//  IM_BasicLinkCellTableViewCell.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/18.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_BasicCellTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_BasicLinkCellTableViewCell : IM_BasicCellTableViewCell

@property (nonatomic, strong) UILabel *linkTitleLabel; // 链接标题
@property (nonatomic, strong) UILabel *linkSubTitleLabel; // 链接子标题
@property (nonatomic, strong) UIImageView *linkImage; // 链接图片

/// 单元填充函数
/// @param data 填充数据源
- (void)fillWithData:(IM_MessageModel *)data;

@end

NS_ASSUME_NONNULL_END
