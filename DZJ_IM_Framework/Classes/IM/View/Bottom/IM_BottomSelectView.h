//
//  IM_BottomSelectView.h
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IM_BottomHeader.h" // 公共头文件

static NSInteger max_row = 1;
static NSInteger max_col = 4;
static NSInteger SelectViewHeight = 116;

NS_ASSUME_NONNULL_BEGIN

@interface IM_BottomSelectView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign, readonly) BOOL isShow;

/// 刷新选择视图状态
/// @param show 是否展示 YES-展示 NO-隐藏
-(void)refreshSelectView:(BOOL)show;

/// 配置点击回调
/// @param didSelectItemInCollectionView 点击某个item回调
-(void)configDidSelectItemInCollectionView:(DidSelectItemInCollectionView)didSelectItemInCollectionView;

/// 加载item数据
/// @param items 要展示的数据，目前以字典形式传入，必填字段：@[@{@"title":@"", @"image":@""}]
-(void)loadCustomeViewWithItems:(NSArray *)items;

@end

NS_ASSUME_NONNULL_END
