//
//  IM_CommonTableViewCell.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/17.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_BasicLinkCellTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_CommonTableViewCell : IM_BasicLinkCellTableViewCell

/// 单元填充函数
/// @param data 填充数据源
- (void)fillWithData:(IM_MessageModel *)data;

@end

NS_ASSUME_NONNULL_END
