//
//  IM_TableView.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/15.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BeginRefresh)(void);
typedef void(^BeginDrug)(void);
typedef void(^DidSelected)(NSIndexPath *indexPath);

@interface IM_TableView : UITableView

/// 主动调用刷新
-(void)tableViewBeginRefresh;

/// 主动结束刷新
-(void)tableViewEndRefresh;

/// 主动结束刷新病设置没有更多数据
-(void)tableViewNoMoreData;

/// 配置回调
/// @param beginRefresh 开始刷新
/// @param beginDrug 开始拖动
/// @param didSelected 点击某行没有添加事件的空白区域
-(void)configBeginRefresh:(BeginRefresh)beginRefresh beginDrug:(BeginDrug)beginDrug didSelected:(DidSelected)didSelected;

@end

NS_ASSUME_NONNULL_END
