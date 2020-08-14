//
//  IM_BottomSelectView.m
//  L_Chat
//
//  Created by dzj on 2020/6/4.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_BottomSelectView.h"
#import "IM_BottomSelectItemView.h"
#import "IM_SelectMsgManager.h"

@interface IM_BottomSelectView()

@property (nonatomic, strong) DidSelectItemInCollectionView didSelectItemInCollectionView;
@property (nonatomic, assign) BOOL isShow;

@end

static CGFloat TABHeight = 5; // 顶部和底部间距
static CGFloat SpaceHeight = 10; // 两行间距

@implementation IM_BottomSelectView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isShow = NO;
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self loadCustomView];
    }
    return self;
}

#pragma mark - public

// 刷新选择视图状态
-(void)refreshSelectView:(BOOL)show {
    self.isShow = show;
    if(self.scrollView.superview != nil) {
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.bottom.equalTo(self);
            if(self.isShow) {
                make.height.equalTo(@(SelectViewHeight));
            } else {
                make.height.equalTo(@0);
            }
        }];
    }
}

// 配置点击回调
-(void)configDidSelectItemInCollectionView:(DidSelectItemInCollectionView)didSelectItemInCollectionView {
    self.didSelectItemInCollectionView = didSelectItemInCollectionView;
}

// 加载item数据
-(void)loadCustomeViewWithItems:(NSArray *)items {
    [self.scrollView removeAllSubviews];
    self.items = [NSMutableArray arrayWithArray:items];
    UIView *lastView = nil;
    if(items.count >= 0 && items.count <= max_col*max_row) {
        lastView = [self addSubPageViewWithLastView:lastView items:items];
        [self.scrollView addSubview:lastView];
        [self.scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, SelectViewHeight)];
    } else {
        NSArray *arr = [self sepArr:items maxLength:max_col*max_row];
        for (int i = 0; i < arr.count; i++) {
            lastView = [self addSubPageViewWithLastView:lastView items:arr[i]];
            [self.scrollView addSubview:lastView];
            if(i == arr.count-1) {
                [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.scrollView);
                }];
            }
        }
        [self.scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*arr.count, SelectViewHeight)];
    }
}

#pragma mark - private

-(void)loadCustomView {
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.bottom.equalTo(self);
        make.height.equalTo(@0);
    }];
}

// 添加单页视图到滑动视图上
-(UIView *)addSubPageViewWithLastView:(UIView *)lastView items:(NSArray *)items {
    UIView *pageView = [self createPageItems:items];
    [self.scrollView addSubview:pageView];
    [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(lastView == nil) {
            make.left.equalTo(self.scrollView);
        } else {
            make.left.equalTo(lastView.mas_right);
        }
        make.top.bottom.equalTo(self.scrollView);
        make.width.equalTo(@([UIScreen mainScreen].bounds.size.width));
        make.height.equalTo(@(SelectViewHeight));
    }];
    return pageView;
}

// 分割数组 适应单页大小
-(NSArray *)sepArr:(NSArray *)array maxLength:(NSInteger)maxLength{
    NSMutableArray *mArr = [NSMutableArray new];
    NSMutableArray *singleArr = [NSMutableArray new];
    for (int i = 0; i < array.count; i++) {
        [singleArr addObject:array[i]];
        if(singleArr.count >= maxLength) {
            [mArr addObject:[singleArr copy]];
            [singleArr removeAllObjects];
        } else {
            if(i == array.count-1) {
                [mArr addObject:[singleArr copy]];
                [singleArr removeAllObjects];
            }
        }
    }
    return [mArr copy];
}

// 创建单页视图
-(UIView *)createPageItems:(NSArray *)items {
    UIView *page = [[UIView alloc] init];
    UIView *lastView = nil;
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width/max_col;
    CGFloat itemHeight = (SelectViewHeight - TABHeight*2.0 - SpaceHeight)/max_row;
    for(int i = 0; i < items.count; i++) {
        IM_SelectMsgModel *model = items[i];
        IM_BottomSelectItemView *item = [self createItemViewWithImageUrlStr:model.selectImage title:model.selectTitle];
        [page addSubview:item];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastView == nil) {
                make.left.equalTo(page);
                make.top.equalTo(page).offset(TABHeight);
            } else {
                if(i < max_col) {
                    make.top.equalTo(page).offset(TABHeight);
                } else {
                    make.bottom.equalTo(page).offset(-(TABHeight));
                }
                if(i%max_col == 0) {
                    make.left.equalTo(page);
                } else {
                    make.left.equalTo(lastView.mas_right);
                }
            }
            make.width.equalTo(@(itemWidth));
            make.height.equalTo(@(itemHeight));
        }];
        lastView = item;
    }
    return page;
}

// 创建单个元素
-(IM_BottomSelectItemView *)createItemViewWithImageUrlStr:(NSString *)imageUrlStr title:(NSString *)title {
    IM_BottomSelectItemView *itemView = [[IM_BottomSelectItemView alloc] init];
    [itemView loadItemWithIcon:imageUrlStr title:title];
    [itemView configDidClickItem:^(IM_BottomSelectItemView * _Nullable item) {
        BOOL hasItem = NO;
        int i = 0;
        for(; i < self.items.count; i++) {
            IM_SelectMsgModel *model = self.items[i];
            if([item.title.text isEqual:model.selectTitle]) {
                hasItem = YES;
                break;
            }
        }
        if(hasItem) {
            [self clickItemIndex:i];
        }
    }];
    return itemView;
}

// 点击某个Item
-(void)clickItemIndex:(NSInteger)index {
    if(index < self.items.count) {
        if(self.didSelectItemInCollectionView) {
            self.didSelectItemInCollectionView(index);
        }
    }
}

#pragma mark - lazy

-(UIScrollView *)scrollView {
    if(_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

-(NSArray *)items {
    if(_items == nil) {
        _items = [[NSArray alloc] init];
    }
    return _items;
}

@end
