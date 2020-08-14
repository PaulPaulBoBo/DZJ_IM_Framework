//
//  IM_WelcomCell.m
//  DoctorCloud
//
//  Created by dzj on 2020/7/13.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_WelcomCell.h"
#import "TTTAttributedLabel.h"

@interface IM_WelcomCell()<TTTAttributedLabelDelegate>

@property (nonatomic, strong) TTTAttributedLabel *contentLabel;
@property (nonatomic, strong) NSString *groupId;

@end

static NSString *CreateGroupTotalMsg = @"交流群创建成功，可邀请其他成员加入啦";
static NSString *JoinGroupTotalMsg = @"欢迎加入交流群，您也可以邀请其他成员加入";
static NSString *MarkMsg = @"邀请其他成员";

@implementation IM_WelcomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self loadCustomView];
    }
    return self;
}

#pragma mark - public

// 加载数据
-(void)fillWithData:(IM_MessageModel *)model {
    if(model) {
        self.groupId = model.groupId;
        NSString *msgContent = @"";
        if([model.targetType isEqual:@"createGroup"]) {
            msgContent = CreateGroupTotalMsg;
        } else if([model.targetType isEqual:@"joinGroup"]) {
            msgContent = CreateGroupTotalMsg;
        }
        [self loadContent:msgContent];
    }
}

#pragma mark - delegate

// 响应点击链接事件
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if([[NSString stringWithFormat:@"%@", url] isEqualToString:MarkMsg] && clearNilStr(self.groupId).length > 0) {
        [DZJRouter openURL:@"webview" query:@{@"link":[NSString stringWithFormat:@"communication-group/invite-members?groupId=%@", self.groupId]} animated:YES];
    }
}

#pragma mark - private

-(void)loadCustomView {
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
}

-(void)loadContent:(NSString *)content {
    self.contentLabel.text = clearNilStr(content);
    [self.contentLabel addLinkToURL:MarkMsg withRange:[content rangeOfString:MarkMsg]];
}

#pragma mark - lazy

-(TTTAttributedLabel *)contentLabel {
    if(_contentLabel == nil) {
        _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.numberOfLines = 0;
        _contentLabel.userInteractionEnabled = YES;
        _contentLabel.delegate = self;
        NSDictionary *attributesDic = @{(NSString *)kCTForegroundColorAttributeName:(__bridge id)[UIColor colorWithHexString:@"#10A4AB"].CGColor,
                                        (NSString *)kCTUnderlineStyleAttributeName:@(YES)};
        _contentLabel.linkAttributes = attributesDic;
        _contentLabel.activeLinkAttributes = attributesDic;
        [_contentLabel setLineBreakMode:(NSLineBreakByCharWrapping)];
    }
    return _contentLabel;
}


@end
