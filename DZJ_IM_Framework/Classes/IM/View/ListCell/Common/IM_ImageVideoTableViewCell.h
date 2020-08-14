//
//  IM_ImageVideoTableViewCell.h
//  DoctorCloud
//
//  Created by dzj on 2020/7/28.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_BasicCellTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_ImageVideoTableViewCell : IM_BasicCellTableViewCell

@property (nonatomic, strong, readonly) UIImageView *imgView;

/// 单元填充函数
/// @param data 填充数据源
- (void)fillWithData:(IM_MessageModel *)data;

@end

NS_ASSUME_NONNULL_END
