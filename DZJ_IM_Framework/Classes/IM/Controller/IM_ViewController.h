//
//  IM_ViewController.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/12.
//  Copyright © 2020 大专家.com. All rights reserved.
//  聊天页面控制器

#import "DZJViewController.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *LeaveIMNotification = @"LeaveIMSuccess_RefreshList"; // 离开聊天页面成功通知key，在列表页接收到该通知时需要刷新列表

@interface IM_ViewController : DZJViewController

@end

NS_ASSUME_NONNULL_END
