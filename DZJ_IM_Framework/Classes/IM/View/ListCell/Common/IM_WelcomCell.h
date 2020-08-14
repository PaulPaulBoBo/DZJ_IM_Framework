//
//  IM_WelcomCell.h
//  DoctorCloud
//
//  Created by dzj on 2020/7/13.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IM_MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_WelcomCell : UITableViewCell

/// 加载数据
/// @param model 填充数据源
-(void)fillWithData:(IM_MessageModel *)model;

@end

NS_ASSUME_NONNULL_END
