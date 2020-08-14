//
//  IM_GroupInfoModel.h
//  DoctorCloud
//
//  Created by dzj on 2020/6/29.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM_GroupInfoModel : JSONModel

@property (nonatomic, copy  ) NSString *groupId; // 群id
@property (nonatomic, copy  ) NSString *targetId; // 聊天id
@property (nonatomic, copy  ) NSString *targetType; // 聊天类型
@property (nonatomic, copy  ) NSString *groupTitle; // 聊天标题
@property (nonatomic, copy  ) NSString *groupNumber; // 聊天人数
@property (nonatomic, copy  ) NSString *notice; // 群公告

@end

NS_ASSUME_NONNULL_END
