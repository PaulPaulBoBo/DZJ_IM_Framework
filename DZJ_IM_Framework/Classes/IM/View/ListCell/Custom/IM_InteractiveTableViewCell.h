//
//  IM_InteractiveTableViewCell.h
//  DoctorCloud
//
//  Created by dzj on 2020/7/17.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IM_MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_InteractiveTableViewCell : UITableViewCell

/// 单元填充函数
/// @param data 填充数据源
- (void)fillWithData:(IM_MessageModel *)data;

@end

NS_ASSUME_NONNULL_END
