//
//  IM_ViewController.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/12.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_ViewController.h"
#import "IM_TableView.h" // 带有定制下拉头视图的列表父视图
#import "IM_BottomView.h" // 底部输入视图
#import "IM_CellHeader.h" // 不同类型聊天cell样式
#import "IM_RequestManager.h" // 消息请求管理类
#import "IM_Timer.h" // 计时器
#import "IM_CellManager.h" // cell管理工具
#import "DZJConstants.h" // 全局静态常量管理类
#import "IM_SendMsgManager.h" // 发送消息管理工具
#import "IM_OperationMsgManager.h" // cell操作管理工具
#import "IM_DeletedCell.h" // 撤回样式
#import "IM_SelectMsgManager.h" // 特殊类型消息展示面板数据处理工具
#import "IM_GroupInfoModel.h" // 群信息模型
#import "IM_ShowNoticeView.h" // 展示群公告视图
#import "IM_MsgCacheManager.h" // 未发送消息缓存管理工具
#import "IM_WelcomCell.h" // 欢迎语cell样式
#import "IM_InteractiveTableViewCell.h" // 互动消息类型样式
#import "IM_AudioPlayManager.h" // 语音播放管理器

@interface IM_ViewController ()<UITableViewDataSource, UIScrollViewDelegate>

// view
@property (nonatomic, strong) IM_TableView *tableView; // 聊天列表
@property (nonatomic, strong) IM_BottomView *bottomView; // 底部输入视图
@property (nonatomic, strong) IM_ShowNoticeView *showNoticeView; // 展示群公告视图

// tool
@property (nonatomic, strong) NSMutableArray *dataArray; // 聊天消息数组
@property (nonatomic, strong) NSArray *selectItems; // 特殊类型消息数组
@property (nonatomic, assign) NSInteger offset; // 分页下标 起始 0
@property (nonatomic, strong) NSDate *updateTime; // 最后刷新消息的时间
@property (nonatomic, copy  ) NSString *targetId; // 列表传进来的id 用于请求页面数据
@property (nonatomic, copy  ) NSString *targetType; // 列表传进来的Type 用于请求页面数据
@property (nonatomic, copy  ) NSString *groupId; // 列表传进来的群id 用于请求页面数据
@property (nonatomic, strong) IM_Timer *runloopTimer; // 轮询消息计时器
@property (nonatomic, strong) IM_CellManager *cellManager; // cell管理工具
@property (nonatomic, strong) IM_SendMsgManager *sendMsgManager; // 发送消息管理工具
@property (nonatomic, strong) IM_OperationMsgManager *operationMsgManager; // cell操作管理工具
@property (nonatomic, strong) IM_SelectMsgManager *selectMsgManager; // 特殊类型消息展示面板数据处理工具

@end

@implementation IM_ViewController

#pragma mark - public
-(void)handleDataWithQuery:(NSDictionary *)query {
    if(query) {
        if([query objectForKey:@"targetId"]) {
            // 会话
            self.targetId = clearNilStr([query objectForKey:@"targetId"]);
        }
        if([query objectForKey:@"targetType"]) {
            // 会话类型
            self.targetType = clearNilStr([query objectForKey:@"targetType"]);
        }
        if([query objectForKey:@"targetTitle"]) {
            // 会话类型
            self.navigationItem.title = [self loadTitleWithTargetType:clearNilStr(self.targetType) name:clearNilStr([query objectForKey:@"targetTitle"]) member:@"0"];
        }
        NSString *chatGroupId = [query objectForKey:@"chatGroupId"];
        if(chatGroupId != nil && clearNilStr(chatGroupId).length > 0) {
            // 工作交流群才会传
            self.groupId = clearNilStr(chatGroupId);
        }
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.offset = 0;
    [self loadCustomView];
    [self configViewBlock];
    [self loadCustomViewData];
    [self addNotification];
}

-(void)dealloc {
    [self removeNotification];
    [self stopRunLoopLoadNewMsg];
}

-(void)backToVc {
    [super backToVc];
    [self dealBackAction];
}

// 滑动返回会走这里
- (void)didMoveToParentViewController:(nullable UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if(!parent){
        [self dealBackAction];
    }
}
#pragma mark - private

// 处理返回到列表的操作
-(void)dealBackAction {
    [self stopPlayingCell]; // 停止正在播放录音的cell
    [self stopRunLoopLoadNewMsg]; // 停止轮询新消息
    [[IM_MsgCacheManager shareInstance] removeCreateGroupMsg]; // 删除新建群通知消息缓存
    [[IM_MsgCacheManager shareInstance] removeJoinGroupMsg]; // 删除被邀请进去通知消息缓存
    [[IM_RequestManager shareInstance] leaveIMWithTargetUserId:self.targetId leaveSuccess:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LeaveIMNotification object:nil userInfo:@{@"dzjUserId":self.targetId}];
    } leaveFail:^{
        
    }];
}

// 加载视图
-(void)loadCustomView {
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-HOME_INDICATOR_HEIGHT);
    }];
    
    [self.view layoutIfNeeded];
    
    [self.view insertSubview:self.tableView atIndex:0];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
}

// 配置视图回调事件
-(void)configViewBlock {
    @weakify(self)
    // 底部输入视图
    [self.bottomView configClickSureBtnAction:^(NSString *text) {
        // 发送按钮
        @strongify(self)
        [self sendtText:text];
    } clickSendAction:^(NSString *text) {
        // 键盘发送按钮
        @strongify(self)
        [self sendtText:text];
    } clickItemBtnAction:^(NSInteger selectIndex) {
        // 其他消息类型选择按钮事件
        NSLog(@"selectIndex:%ld", selectIndex);
        @strongify(self)
        if(selectIndex < self.selectItems.count) {
            IM_SelectMsgModel *model = self.selectItems[selectIndex];
            if(model.selectType == IM_SelectItemType_Image) {
                [self sendImages];
            } else if(model.selectType == IM_SelectItemType_File) {
                IM_MessageModel *msgModel = [IM_MessageModel createModelWithMsgType:IM_MsgTypeFile content:@"" targetType:self.targetType targetId:self.targetId];
                [self sendMsgWithModel:msgModel];
            } else {
                [DZJRouter openURL:@"webview" query:@{@"link":clearNilStr(model.selectLink)} animated:YES];
            }
        }
    } clickAddBtnAction:^{
        // 加号按钮
        @strongify(self)
        [self refreshBottomViewData:YES];
        [self.bottomView refreshVoiceView:YES];
        [self.bottomView refreshSelectView:YES];
        [self reloadIMTableViewToBottom:0.1];
    } clickMoreBtnAction:^{
        // 更多按钮
        @strongify(self)
        [self refreshBottomViewData:NO];
        [self.bottomView refreshVoiceView:YES];
        [self.bottomView refreshSelectView:YES];
        [self reloadIMTableViewToBottom:0.1];
    } clickVoiceBtnAction:^{
        // 语音切换
        @strongify(self)
        [self.bottomView refreshSelectView:NO];
        [self reloadIMTableViewToBottom:0.1];
    }];
    
    [self.bottomView configTextViewDidBeginEdit:^(UITextView * _Nonnull textView) {
        // 开始编辑
        @strongify(self)
        [self scrollChatTableToBottom:0.1];
        [self.bottomView refreshSelectView:NO];
    } textViewDidEditing:^(UITextView * _Nonnull textView) {
        // 正在编辑
    } textViewDidEndEdit:^(UITextView * _Nonnull textView) {
        // 结束编辑
        [[IM_MsgCacheManager shareInstance] createUnSendMsgCache:self.targetId content:clearNilStr(textView.text)];
    }];
    
    [self.bottomView configStartVoice:^{
        // 开始录音
        @strongify(self)
        [self unfocus];
    } cancelVoice:^{
        // 取消录音
    } finishVoice:^(id  _Nonnull voiceData, CGFloat duration) {
        // 结束录音
        IM_MessageModel *model = [IM_MessageModel createModelWithMsgType:IM_MsgTypeAudio content:@"" targetType:self.targetType targetId:self.targetId];
        IM_VoiceContentModel *voiceModel = [[IM_VoiceContentModel alloc] init];
        voiceModel.voiceData = voiceData;
        voiceModel.duration = [NSNumber numberWithString:[NSString stringWithFormat:@"%.1lf", duration]];
        model.voiceModel = voiceModel;
        [self sendMsgWithModel:model];
    }];
}

// 加载视图数据
-(void)loadCustomViewData {
    self.tableView.alpha = 0;
    [self loadCacheData];
    [self refreshData];
    [self startRunLoopLoadNewMsg];
    [self refreshBottomViewData:YES];
    [self loadBotomViewIsSHowMoreWithTargetType:self.targetType];
    [self loadGroupInfo:clearNilStr(self.groupId) targetId:clearNilStr(self.targetId) targetType:clearNilStr(self.targetType)];
}

-(void)loadCacheData {
    IM_MessageModel *model = [[IM_MsgCacheManager shareInstance] loadUnsendMsgCacheWithId:self.targetId];
    if(model) {
        [self.bottomView.inputView.textView setText:clearNilStr(model.content)];
        [self.bottomView refreshVoiceView:YES];
    }
}

// 刷新底部视图items isAdd：YES-点击加号 NO-点击更多"..."
-(void)refreshBottomViewData:(BOOL)isAdd {
    IM_SelectMsgType type = IM_SelectMsgType_Default;
    if ([self.targetType isEqualToString:@"BRANCH_CENTER"]) {
        // 分中心聊天群
        type = IM_SelectMsgType_BRANCH_CENTER;
    } else if ([self.targetType isEqualToString:@"COMPANY_GROUP"]) {
        // M端省总和联络员的群,M端省总和全国M端的群,机构管理员和运营的交流群
        type = IM_SelectMsgType_COMPANY_GROUP;
    } else if ([self.targetType isEqualToString:@"WORKING_GROUP"]) {
        // G端交流群,工作交流群
        type = IM_SelectMsgType_WORKING_GROUP;
    } else if ([self.targetType isEqualToString:@"CONFERENCE_GROUP"]) {
        // 会议群
        type = IM_SelectMsgType_CONFERENCE_GROUP;
    } else if ([self.targetType isEqualToString:@"USER"]) {
        // 个人聊天
        type = IM_SelectMsgType_USER;
    } else if ([self.targetType isEqualToString:@"COMPANY_BUSINESS_SERVICE"]) {
        // 新增类型
        type = IM_SelectMsgType_Default;
    } else if ([self.targetType isEqualToString:@"PESTILENCE_WARNING_V2"]) {
        // 新增类型-新冠肺炎
        type = IM_SelectMsgType_Default;
    } else {
        // 默认类型
        type = IM_SelectMsgType_Default;
    }
    if(isAdd) {
        self.selectItems = [self.selectMsgManager loadAddSelectItemWithSelectMsgType:type targetId:self.targetId groupId:clearNilStr(self.groupId)];
    } else {
        self.selectItems = [self.selectMsgManager loadMoreSelectItemWithSelectMsgType:type targetId:self.targetId groupId:clearNilStr(self.groupId)];
    }
    [self.bottomView loadSelectItems:self.selectItems];
}

// 根据聊天类型确定是否展示更多按钮
-(void)loadBotomViewIsSHowMoreWithTargetType:(NSString *)targetType {
    BOOL isShowMore = NO;
    if([targetType isEqualToString:@"BRANCH_CENTER"] ||
       [targetType isEqualToString:@"COMPANY_GROUP"] ||
       [targetType isEqualToString:@"WORKING_GROUP"] ||
       [targetType isEqualToString:@"CONFERENCE_GROUP"]) {
        isShowMore = YES;
    }
    [self.bottomView configisShowMore:isShowMore];
}

// 发送文本消息
-(void)sendtText:(NSString *)text {
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(text.length > 0) {
        [self sendMsgWithModel:[IM_MessageModel createModelWithMsgType:IM_MsgTypeText content:text targetType:self.targetType targetId:self.targetId]];
    } else {
        [DZJToast toast:@"不能发送空白内容"];
    }
}

// 刷新列表数据 isToBottom是否定位到底部 YES-是 NO-不动
-(void)reloadIMTableViewToBottom:(BOOL)isToBottom {
    [self reloadIMTableViewToBottom:isToBottom msgs:@[]];
}
// 刷新列表数据 isToBottom是否定位到底部 YES-是 NO-不动 msgs是要合并到列表的新数据
-(void)reloadIMTableViewToBottom:(BOOL)isToBottom msgs:(NSArray *)msgs {
    if(msgs.count > 0) {
        self.dataArray = [NSMutableArray arrayWithArray:[[IM_RequestManager shareInstance] compareMsgsWithOldMsgs:self.dataArray newMsgs:msgs]];
    }
    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
    }];
    if(isToBottom) {
        [self scrollChatTableToBottom:0.1];
    }
}

// 单行刷新列表
-(void)reloadIMtableViewSingleLineWith:(IM_MessageModel *)model {
    
    NSInteger index = 0;
    for (NSInteger i = self.dataArray.count-1; i >= 0; i--) {
        IM_MessageModel *indexModel = [self.dataArray objectAtIndex:i];
        if([model.localStateId isEqual:clearNilStr(indexModel.localStateId)]) {
            index = i;
            break;
        }
    }
    
    if(index != 0) {
        [self.dataArray replaceObjectAtIndex:index withObject:model];
    }
    
    NSIndexPath *indexPath = [self loadCellIndexPathWithModel:model];
    if(indexPath != nil && indexPath.row < self.dataArray.count) {
        IM_BasicCellTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if(cell) {
            [cell fillWithData:model];
        } else {
            [self reloadIMTableViewToBottom:NO];
        }
    }
}

-(IM_BasicCellTableViewCell *)loadCellWithModel:(IM_MessageModel *)model {
    IM_BasicCellTableViewCell *cell = nil;
    NSIndexPath *indexPath = [self loadCellIndexPathWithModel:model];
    if(indexPath) {
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

-(NSIndexPath *)loadCellIndexPathWithModel:(IM_MessageModel *)model {
    NSIndexPath *indexPath = nil;
    NSInteger index = 0;
    for (NSInteger i = self.dataArray.count-1; i >= 0; i--) {
        IM_MessageModel *msgModel = [self.dataArray objectAtIndex:i];
        if(clearNilStr(model.localStateId).length > 0) {
            if([model.localStateId isEqualToString:clearNilStr(msgModel.localStateId)]) {
                index = i;
                break;
            }
        } else if(clearNilStr(model.IM_id).length > 0) {
            if([model.IM_id isEqualToString:clearNilStr(msgModel.IM_id)]) {
                index = i;
                break;
            }
        }
    }
    [self.dataArray replaceObjectAtIndex:index withObject:model];
    if(index < self.dataArray.count) {
        indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    return indexPath;
}

// 将列表滑动至底部
-(void)scrollChatTableToBottom:(CGFloat)time {
    if(self.dataArray.count > 0 && self.tableView.frame.size.height > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf scrollToIndexPath:[NSIndexPath indexPathForRow:weakSelf.dataArray.count-1 inSection:0] animated:NO];
            if(self.tableView.alpha == 0) {
                self.tableView.alpha = 1;
            }
        });
    } else {
        // 无数据，不用滑动
    }
}

// 将列表滑动至指定单元格
-(void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
}

// 刷新当前时间之前的历史消息
-(void)refreshData {
    if(clearNilStr(self.targetId).length == 0) {
        [DZJToast toast:@"会话id不存在"];
        return;
    }
    self.offset = 0;
    @weakify(self)
    [DZJHUDProgress showLoadingInView:self.view];
    [[IM_RequestManager shareInstance] loadHistoryMessgeTargetUserId:clearNilStr(self.targetId) beforeTime:[NSDate date] limit:50 loadMsgSuccess:^(NSArray<IM_MessageModel *> *msgs) {
        @strongify(self)
        [DZJHUDProgress hideAllHUDsForView:self.view];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:msgs];
        
        // 获取新建群通知消息，建群后第一次进入需要展示文案"交流群创建成功，可邀请其他成员加入啦"
        NSDictionary *createGroupInfo = [[IM_MsgCacheManager shareInstance] loadCreateGroupMsg];
        if(createGroupInfo) {
            NSData *JSONData = [NSJSONSerialization dataWithJSONObject:createGroupInfo options:NSJSONWritingPrettyPrinted error:nil];
            if(JSONData) {
                NSString *content = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
                IM_MessageModel *createGroupInfoModel = [IM_MessageModel createModelWithMsgType:(IM_MsgTypeCreateGroup) content:clearNilStr(content) targetType:[createGroupInfo objectForKey:@"type"] targetId:[createGroupInfo objectForKey:@""]];
                [self.dataArray addObject:createGroupInfoModel];
            }
        }
        
        // 获取被邀请加入群通知消息，被邀请进群后第一次进入需要展示文案"欢迎加入交流群，您也可以邀请其他成员加入"
        NSDictionary *joinGroupInfo = [[IM_MsgCacheManager shareInstance] loadJoinGroupMsg];
        if(joinGroupInfo) {
            NSData *JSONData = [NSJSONSerialization dataWithJSONObject:joinGroupInfo options:NSJSONWritingPrettyPrinted error:nil];
            if(JSONData) {
                NSString *content = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
                IM_MessageModel *joinGroupInfoModel = [IM_MessageModel createModelWithMsgType:(IM_MsgTypeFirsJoinGroup) content:content targetType:[joinGroupInfo objectForKey:@"type"] targetId:[joinGroupInfo objectForKey:@""]];
                [self.dataArray addObject:joinGroupInfoModel];
            }
        }
        
        [self reloadIMTableViewToBottom:YES];
    } loadMsgFail:^{
        DLog(@"请求失败");
        [DZJHUDProgress hideAllHUDsForView:self.view];
        [self reloadIMTableViewToBottom:YES];
    }];
}

// 加载更多历史消息
-(void)loadMoreData {
    if(clearNilStr(self.targetId).length == 0) {
        [DZJToast toast:@"会话id不存在"];
        return;
    }
    self.offset = self.dataArray.count;
    
    IM_MessageModel *firstModel = self.dataArray.firstObject;
    @weakify(self)
    [[IM_RequestManager shareInstance] loadHistoryMessgeTargetUserId:clearNilStr(self.targetId) beforeTime:firstModel.updatedTime limit:20 loadMsgSuccess:^(NSArray<IM_MessageModel *> *msgs) {
        @strongify(self)
        if(msgs.count > 0) {
            [self.dataArray insertObjects:msgs atIndex:0];
            [self.tableView tableViewEndRefresh];
        } else {
            if(self.dataArray.count > 0) {
                IM_MessageModel *model = [self.dataArray objectAtIndex:0];
                model.isShowTime = YES;
                [self.tableView reloadData];
            }
            [self.tableView tableViewNoMoreData];
        }
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (int i = 0; i < msgs.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        if(indexPaths.count > 0) {
            [UIView performWithoutAnimation:^{
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationNone)];
                [self scrollToIndexPath:[NSIndexPath indexPathForRow:msgs.count inSection:0] animated:NO];
            }];
        }
    } loadMsgFail:^{
        [self reloadIMTableViewToBottom:NO];
        [self.tableView tableViewEndRefresh];
    }];
}

// 加载最新消息
-(void)loadNewData {
    if(clearNilStr(self.targetId).length == 0) {
        [DZJToast toast:@"会话id不存在"];
        return;
    }
    BOOL isToBottom = YES;
    if(self.tableView.contentOffset.y+self.tableView.height < self.tableView.contentSize.height) {
        isToBottom = NO;
    }
    @weakify(self)
    self.updateTime = [NSDate dateWithTimeIntervalSince1970:([self.updateTime timeIntervalSince1970] - 60*2)];
    [[IM_RequestManager shareInstance] loadAllNewMessgeTargetUserId:clearNilStr(self.targetId) afterTime:self.updateTime limit:50 loadMsgSuccess:^(NSArray<IM_MessageModel *> *msgs) {
        @strongify(self)
        self.updateTime = [NSDate date];
        [self reloadIMTableViewToBottom:isToBottom msgs:msgs];
    } loadMsgFail:^{
        [self reloadIMTableViewToBottom:isToBottom];
    }];
}

// 获取工作交流群或私聊信息
-(void)loadGroupInfo:(NSString *)groupId targetId:(NSString *)targetId targetType:(NSString *)targetType {
    if([targetType isEqualToString:@"createGroup"] || [targetType isEqualToString:@"joinGroup"]) {
        targetType = @"WORKING_GROUP";
    }
    @weakify(self)
    [[IM_RequestManager shareInstance] loadGroupInfoGroupId:clearNilStr(groupId) targetId:clearNilStr(targetId) targetType:clearNilStr(targetType) loadGroupInfoSuccess:^(IM_GroupInfoModel *groupInfoModel) {
        @strongify(self)
        NSString *originTitle = clearNilStr(groupInfoModel.groupTitle);
        if(originTitle.length == 0) {
            originTitle = self.navigationItem.title;
        }
        self.navigationItem.title = [self loadTitleWithTargetType:clearNilStr(groupInfoModel.targetType) name:clearNilStr(originTitle) member:clearNilStr(groupInfoModel.groupNumber)];
        
        // 只有工作交流群才需要检查是否有公告
        if([targetType isEqualToString:@"WORKING_GROUP"] && clearNilStr(groupId).length > 0) {
            [[IM_RequestManager shareInstance] loadNoticeWithGroupId:clearNilStr(groupId) loadNoticeSuccess:^(BOOL hasRead) {
                if(hasRead == NO) {
                    // 公告未读 弹窗提示
                    if(clearNilStr(groupInfoModel.notice).length > 0) {
                        [self showNotice:clearNilStr(groupInfoModel.notice) groupId:groupId];
                    }
                }
            } loadNoticeFail:^{
                
            }];
        }
    } loadGroupInfoFail:^{
        
    }];
}

// 弹出公告弹窗
-(void)showNotice:(NSString *)notice groupId:(NSString *)groupId {
    [self.showNoticeView showNoticeWithTitle:@"群公告" content:clearNilStr(notice) didClickReadBtnBlock:^{
        [[IM_RequestManager shareInstance] markNoticeReadedGroupId:groupId markNoticeSuccess:^{
            
        } markNoticeFail:^{
            
        }];
    }];
}

// 格式化标题
-(NSString *)loadTitleWithTargetType:(NSString *)targetType name:(NSString *)name member:(NSString *)member {
    NSString *memberStr = @"";
    if([targetType isEqualToString:@"USER"]) {
        // 私聊不需要展示数字
    } else {
        if(member.length > 0 && (![member isEqual:@"0"])) {
            memberStr = [NSString stringWithFormat:@"(%@)", member];
        }
    }
    if([targetType isEqualToString:@"BRANCH_CENTER"]) {
        return [NSString stringWithFormat:@"%@%@", name, memberStr];
    } else if([targetType isEqualToString:@"CONFERENCE_GROUP"]) {
        return [NSString stringWithFormat:@"%@%@", name, memberStr];
    } else {
        return [NSString stringWithFormat:@"%@%@", name, memberStr];
    }
}

-(void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(abortGroup) name:KIMAbortGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewMessage) name:IM_LOAD_NEW_MESSAGE object:nil];
}

-(void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification *)noti {
    [self scrollChatTableToBottom:0.1];
}

// 退群通知事件
-(void)abortGroup {
    [DZJRouter popViewController:NO];
}

// H5通知Native拉取新消息通知事件
-(void)loadNewMessage {
    [self refreshData];
}

// 发送消息
-(void)sendMsgWithModel:(IM_MessageModel *)model {
    @weakify(self)
    NSArray *tmpArray = [self.sendMsgManager sendMsgWithModel:model currentMsgs:self.dataArray sendMsgSuccess:^(NSArray<IM_MessageModel *> *msgs, IM_MessageModel *sendedModel) {
        @strongify(self)
        self.dataArray = [NSMutableArray arrayWithArray:[[IM_RequestManager shareInstance] compareMsgsWithOldMsgs:self.dataArray newMsgs:msgs]];
        [self reloadIMtableViewSingleLineWith:sendedModel];
    } sendMsgFail:^(IM_MessageModel *failModel) {
        @strongify(self)
        for (int i = 0; i < self.dataArray.count; i++) {
            IM_MessageModel *tmpModel = [self.dataArray objectAtIndex:i];
            if([tmpModel.localStateId isEqual:clearNilStr(failModel.localStateId)]) {
                [self.dataArray replaceObjectAtIndex:i withObject:failModel];
            }
        }
        [self reloadIMtableViewSingleLineWith:failModel];
    } sendProgress:^(CGFloat progressValue, id sendingObj, IM_MessageModel *sendingModel) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            IM_BasicCellTableViewCell *cell = [self loadCellWithModel:sendingModel];
            if(cell) {
                IM_ProcessType type = IM_ProcessTypeLine;
                if(cell.data.msgType == IM_MsgTypeImage ||
                   cell.data.msgType == IM_MsgTypeImageVideo ||
                   cell.data.msgType == IM_MsgTypeFile) {
                    type = IM_ProcessTypeCircle;
                }
                [cell showProcessView:progressValue type:type];
            }
        });
    } preparedSendMsgSuccess:^(NSArray<IM_MessageModel *> *msgs) {
        @strongify(self)
        [self reloadIMTableViewToBottom:YES msgs:msgs];
    }];
    [self reloadIMTableViewToBottom:YES msgs:tmpArray];
}

// 发送多张图片
-(void)sendImages {
    @weakify(self)
    [self.sendMsgManager sendImagesWithtargetType:self.targetType targetId:self.targetId currentMsgs:self.dataArray sendMsgSuccess:^(NSArray<IM_MessageModel *> *msgs, IM_MessageModel *sendedModel) {
        @strongify(self)
        self.dataArray = [NSMutableArray arrayWithArray:[[IM_RequestManager shareInstance] compareMsgsWithOldMsgs:self.dataArray newMsgs:msgs]];
        [self reloadIMtableViewSingleLineWith:sendedModel];
    } sendMsgFail:^(IM_MessageModel *failModel) {
        @strongify(self)
        for (int i = 0; i < self.dataArray.count; i++) {
            IM_MessageModel *tmpModel = [self.dataArray objectAtIndex:i];
            if([tmpModel.localStateId isEqual:clearNilStr(failModel.localStateId)]) {
                [self.dataArray replaceObjectAtIndex:i withObject:failModel];
            }
        }
        [self reloadIMtableViewSingleLineWith:failModel];
    } sendProgress:^(CGFloat progressValue, id sendingObj, IM_MessageModel *sendingModel) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            IM_BasicCellTableViewCell *cell = [self loadCellWithModel:sendingModel];
            if(cell) {
                IM_ProcessType type = IM_ProcessTypeLine;
                if(cell.data.msgType == IM_MsgTypeImage ||
                   cell.data.msgType == IM_MsgTypeImageVideo ||
                   cell.data.msgType == IM_MsgTypeFile) {
                    type = IM_ProcessTypeCircle;
                }
                [cell showProcessView:progressValue type:type];
            }
        });
    } preparedSendMsgSuccess:^(NSArray<IM_MessageModel *> *msgs) {
        @strongify(self)
        self.dataArray = [NSMutableArray arrayWithArray:[msgs copy]];
        [self reloadIMTableViewToBottom:YES msgs:msgs];
    }];
}

// 开始轮询请求最新消息
-(void)startRunLoopLoadNewMsg {
    [self.runloopTimer startTimerWithTimerType:(IM_TimerTypeGCD) timeInterval:10 startTimerBlock:^(CGFloat seconds) {
        if(![[IM_AudioPlayManager shareInstance] isPlayingAudio]) {
            [self loadNewData];
        }
    }];
}

// 停止轮询请求最新消息
-(void)stopRunLoopLoadNewMsg {
    if(_runloopTimer) {
        [self.runloopTimer stopTimerWithTimerType:(IM_TimerTypeGCD) stopTimerBlock:^{
            self.runloopTimer = nil;
        }];
    }
}

// 撤回消息
-(void)deleteMsgWithModel:(IM_MessageModel *)model {
    NSArray *tmpArray = [self.sendMsgManager deleteMsgWithModel:model currentMsgs:self.dataArray deleteMsgSuccess:^(IM_MessageModel *model) {
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.dataArray];
        for (NSInteger i = mArr.count - 1; i >= 0; i--) {
            IM_MessageModel *tmpModel = [mArr objectAtIndex:i];
            if(model.IM_id == tmpModel.IM_id) {
                [mArr replaceObjectAtIndex:i withObject:model];
                break;
            }
        }
        [self reloadIMTableViewToBottom:YES msgs:mArr];
    } deleteMsgFail:^{
        
    }];
    [self reloadIMTableViewToBottom:YES msgs:tmpArray];
}

// 检查是否有正在播放录音的cell 如果有直接停止播放
-(void)stopPlayingCell {
    IM_BasicCellTableViewCell *playingCell = [self.operationMsgManager playingVoiceCell];
    if (playingCell) {
        [self.operationMsgManager stopPlayAudio:playingCell];
    }
}

#pragma mark - delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataArray.count) {
        IM_MessageModel *model = self.dataArray[indexPath.row];
        if(model.isDeleted) {
            IM_DeletedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IM_DeletedCell"];
            if(cell == nil) {
                cell = [[IM_DeletedCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"IM_DeletedCell"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell fillWithData:model];
            return cell;
        } else if(model.msgType == IM_MsgTypeFlower || model.msgType == IM_MsgTypeApplaud) {
            IM_InteractiveTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"IM_InteractionTableViewCell"];
            if(cell == nil) {
                cell = [[IM_InteractiveTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"IM_InteractionTableViewCell"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell fillWithData:model];
            return cell;
        } else if(model.msgType == IM_MsgTypeCreateGroup || model.msgType == IM_MsgTypeFirsJoinGroup) {
            IM_WelcomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IM_WelcomCell"];
            if(cell == nil) {
                cell = [[IM_WelcomCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"IM_WelcomCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell fillWithData:model];
            return cell;
        } else {
            IM_BasicCellTableViewCell *cell = [self.cellManager loadCellWithModel:model];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            @weakify(self)
            cell.selectMessage = ^(IM_BasicCellTableViewCell * _Nullable cell) {
                // 点击消息
                @strongify(self)
                if([self.operationMsgManager playingVoiceCell] != nil) {
                    if([self.operationMsgManager playingVoiceCell].data.IM_id != cell.data.IM_id) {
                        [self stopPlayingCell];
                        [self.operationMsgManager tapMsgCell:cell];
                    } else {
                        [self stopPlayingCell];
                    }
                } else {
                    [self.operationMsgManager tapMsgCell:cell];
                }
            };
            cell.longPressMessage = ^(IM_BasicCellTableViewCell * _Nullable cell) {
                // 长按消息
                [self stopPlayingCell];
                [self.operationMsgManager longPressMsgCell:cell];
            };
            cell.retryMessage = ^(IM_BasicCellTableViewCell * _Nullable cell) {
                // 点击重发消息
                @strongify(self)
                [self stopPlayingCell];
                [self.dataArray removeObject:cell.data];
                cell.data.state = IM_MessageStateSending;
                [self reloadIMTableViewToBottom:YES];
                [self sendMsgWithModel:cell.data];
            };
            cell.selectMessageAvatar = ^(IM_BasicCellTableViewCell * _Nullable cell) {
                // 点击头像
                @strongify(self)
                [self stopPlayingCell];
                [self.operationMsgManager tapMsgAvatarCell:cell];
            };
            cell.deleteMessage = ^(IM_BasicCellTableViewCell * _Nullable cell) {
                // 撤回消息
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"撤回后其他群成员将不可见该消息。是否确定撤回？（可撤回30分钟之内的消息）" preferredStyle:(UIAlertControllerStyleAlert)];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {}]];
                [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    @strongify(self)
                    [self stopPlayingCell];
                    [self deleteMsgWithModel:cell.data];
                }]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[DZJRouter sharedInstance].currentViewController presentViewController:alert animated:YES completion:^{
                        
                    }];
                });
            };
            return cell;
        }
    } else {
        return [UITableViewCell new];
    }
}

-(void)unfocus {
    [self.bottomView refreshSelectView:NO];
    [self.bottomView.inputView.textView resignFirstResponder];
}

#pragma mark - lazy

-(IM_TableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[IM_TableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 100;
        [_tableView registerClass:[IM_DeletedCell class] forCellReuseIdentifier:@"IM_DeletedCell"];
        [_tableView registerClass:[IM_InteractiveTableViewCell class] forCellReuseIdentifier:@"IM_InteractiveTableViewCell"];
        @weakify(self)
        [_tableView configBeginRefresh:^{
            @strongify(self)
            [self loadMoreData];
        } beginDrug:^{
            @strongify(self)
            [self unfocus];
        } didSelected:^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            [self unfocus];
        }];
        [self.cellManager configTableView:_tableView];
    }
    return _tableView;
}

-(IM_BottomView *)bottomView {
    if(_bottomView == nil) {
        _bottomView = [[IM_BottomView alloc] init];
        _bottomView.layer.shadowColor = [UIColor whiteColor].CGColor;
        _bottomView.layer.shadowOpacity = 0.5;
        _bottomView.layer.shadowOffset = CGSizeMake(0, 0);
        _bottomView.layer.shadowRadius = 4.0;
        _bottomView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, -2, ScreenWidth, 60)].CGPath;
    }
    return _bottomView;
}

-(NSMutableArray *)dataArray {
    if(_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

-(IM_Timer *)runloopTimer {
    if(_runloopTimer == nil) {
        _runloopTimer = [[IM_Timer alloc] init];
    }
    return _runloopTimer;
}

-(NSDate *)updateTime {
    if(_updateTime == nil) {
        _updateTime = [NSDate date];
    }
    return _updateTime;
}

-(IM_CellManager *)cellManager {
    if(_cellManager == nil) {
        _cellManager = [[IM_CellManager alloc] init];
    }
    return _cellManager;
}

-(IM_SendMsgManager *)sendMsgManager {
    if(_sendMsgManager == nil) {
        _sendMsgManager = [[IM_SendMsgManager alloc] init];
        [_sendMsgManager configViewController:self];
    }
    return _sendMsgManager;
}

-(IM_OperationMsgManager *)operationMsgManager {
    if(_operationMsgManager == nil) {
        _operationMsgManager = [[IM_OperationMsgManager alloc] init];
        [_operationMsgManager configViewController:self];
    }
    return _operationMsgManager;
}

-(IM_SelectMsgManager *)selectMsgManager {
    if(_selectMsgManager == nil) {
        _selectMsgManager = [[IM_SelectMsgManager alloc] init];
    }
    return _selectMsgManager;
}

-(IM_ShowNoticeView *)showNoticeView {
    if(_showNoticeView == nil) {
        _showNoticeView = [[IM_ShowNoticeView alloc] init];
    }
    return _showNoticeView;
}

@end
