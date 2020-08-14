//
//  IM_CellManager.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/17.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IM_CellHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_CellManager : NSObject

/// 配置列表 将cell注册操作封装进去
/// @param tableView 列表
-(void)configTableView:(UITableView *)tableView;

/// 根据数据源和下标返回对应的cell
/// @param model 数据源模型
-(id)loadCellWithModel:(IM_MessageModel *)model;

@end

NS_ASSUME_NONNULL_END
