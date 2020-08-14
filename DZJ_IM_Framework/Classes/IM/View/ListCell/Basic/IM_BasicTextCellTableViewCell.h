//
//  IM_BasicTextCellTableViewCell.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/18.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_BasicCellTableViewCell.h"
#import "TTTAttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_BasicTextCellTableViewCell : IM_BasicCellTableViewCell

@property (nonatomic, strong) TTTAttributedLabel *contentLabel; // 文本标签

/// 单元填充函数
/// @param data 填充数据源
- (void)fillWithData:(IM_MessageModel *)data;

@end

NS_ASSUME_NONNULL_END
