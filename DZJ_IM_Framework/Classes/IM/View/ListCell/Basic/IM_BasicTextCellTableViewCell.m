//
//  IM_BasicTextCellTableViewCell.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/18.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_BasicTextCellTableViewCell.h"

@interface IM_BasicTextCellTableViewCell()<TTTAttributedLabelDelegate>

@end

@implementation IM_BasicTextCellTableViewCell

#pragma mark - public

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    [self.container removeGestureRecognizer:self.container.tapGes];
    [self loadContent:clearNilStr(data.content)];
}

#pragma mark - delegate

// 响应点击链接事件
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [DZJRouter openURL:@"webview" query:@{@"link":[url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]} animated:YES];
}

// 响应点击号码事件
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:clearNilStr(phoneNumber) preferredStyle:(UIAlertControllerStyleActionSheet)];
    [alert addAction:[UIAlertAction actionWithTitle:@"复制文本" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *past = [UIPasteboard generalPasteboard];
        past.string = clearNilStr(phoneNumber);
        [DZJToast toast:@"复制成功！"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拨打电话" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL *phoneNumberStr = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"telprompt://%@", phoneNumber]];
        [[UIApplication sharedApplication] openURL:phoneNumberStr];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[DZJRouter sharedInstance] currentViewController] presentViewController:alert animated:YES completion:^{
            
        }];
    });
}

#pragma mark - life

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadCustomView];
    }
    return self;
}

#pragma mark - private

-(void)loadCustomView {
    [self.container addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.right.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
        make.top.equalTo(self.container).offset(self.containerInnerBoardSpace);
        make.bottom.equalTo(self.container).offset(-(self.containerInnerBoardSpace));
    }];
}

-(void)loadContent:(NSString *)content {
    self.contentLabel.text = clearNilStr(content);
    NSError * error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber|NSTextCheckingTypeLink  error:&error];
    NSArray *matches = [detector matchesInString:content
                                         options:0
                                           range:NSMakeRange(0, [content length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            [self.contentLabel addLinkToURL:url withRange:matchRange];
        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            NSString *phoneNumber = [match phoneNumber];
            [self.contentLabel addLinkToPhoneNumber:phoneNumber withRange:matchRange];
        }
    }
}

#pragma mark - lazy

-(TTTAttributedLabel *)contentLabel {
    if(_contentLabel == nil) {
        _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
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
