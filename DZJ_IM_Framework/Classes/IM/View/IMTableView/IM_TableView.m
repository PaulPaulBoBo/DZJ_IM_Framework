//
//  IM_TableView.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/15.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_TableView.h"
#import "IM_HeaderView.h"

@interface IM_TableView()<UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IM_HeaderView *headerView; // 没有更多历史消息展示视图
@property (nonatomic, strong) NSMutableDictionary *cellHeightDic; // 行高缓存字典

@property (nonatomic, strong) BeginRefresh beginRefresh;
@property (nonatomic, strong) BeginDrug beginDrug;
@property (nonatomic, strong) DidSelected didSelected;

@end

@implementation IM_TableView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self layoutIfNeeded];
        [self addSubview:self.headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self).offset(-40);
            make.height.equalTo(@40);
            make.width.mas_equalTo(ScreenWidth);
        }];
    }
    return self;
}

#pragma mark - public

// 主动调用刷新
-(void)tableViewBeginRefresh {
    [self transToRefreshing];
}

// 主动结束刷新
-(void)tableViewEndRefresh {
    [self transToEndRefresh];
}

// 主动结束刷新病设置没有更多数据
-(void)tableViewNoMoreData {
    [self transToNoMoreData];
}

// 配置回调
-(void)configBeginRefresh:(BeginRefresh)beginRefresh beginDrug:(BeginDrug)beginDrug didSelected:(DidSelected)didSelected {
    self.beginRefresh = beginRefresh;
    self.beginDrug = beginDrug;
    self.didSelected = didSelected;
}

#pragma mark - delegate

// 列表单元格即将绘制代理
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 缓存cell高度, 解决上拉加载更多数据跳动问题
    [self.cellHeightDic setObject:@(cell.frame.size.height) forKey:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [self.cellHeightDic objectForKey:indexPath];
    if (height) return height.doubleValue;
    return UITableViewAutomaticDimension;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y <= 0 &&
       scrollView.contentOffset.y >= -40) {
        [self.headerView rotatePersent:(-scrollView.contentOffset.y)/40.0];
    } else {
        [self.headerView rotatePersent:0];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.didSelected) {
        self.didSelected(indexPath);
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(self.headerView.type == IM_HeaderViewTypeNoMore) {
        return;
    }
    if(scrollView.contentOffset.y > 0) {
        // 取消或不在不在刷新区域
        [self transToWait];
    } else if(scrollView.contentOffset.y <= 0 &&
              scrollView.contentOffset.y >= -40) {
        // 继续下拉刷新列表
        [self transToWait];
    } else {
        // 松开刷新
        [self transToRefreshing];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(self.beginDrug) {
        self.beginDrug();
    }
}

#pragma mark - private

-(void)transToWait {
    [self.headerView refreshState:IM_HeaderViewTypeWaiting];
}

-(void)transToRefreshing {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height, 0, 0, 0);
        self.contentOffset = CGPointMake(0, -(self.headerView.frame.size.height));
        [self.headerView refreshState:IM_HeaderViewTypeRefreshing];
    } completion:^(BOOL finished) {
        if(self.beginRefresh) {
            self.beginRefresh();
        }
    }];
}

-(void)transToEndRefresh {
    @weakify(self)
    [self.headerView refreshState:IM_HeaderViewTypeEndRefresh];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self)
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            @strongify(self)
            [self.headerView refreshState:IM_HeaderViewTypeWaiting];
        }];
    });
}

-(void)transToNoMoreData {
    @weakify(self)
    [self.headerView refreshState:IM_HeaderViewTypeNoMore];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self)
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }];
    });
}

#pragma mark - lazy

-(NSMutableDictionary *)cellHeightDic {
    if(_cellHeightDic == nil) {
        _cellHeightDic = [[NSMutableDictionary alloc] init];
    }
    return _cellHeightDic;
}

-(IM_HeaderView *)headerView {
    if(_headerView == nil) {
        _headerView = [[IM_HeaderView alloc] init];
        [_headerView refreshState:(IM_HeaderViewTypeWaiting)];
    }
    return _headerView;
}

@end
