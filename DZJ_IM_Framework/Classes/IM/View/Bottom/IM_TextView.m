//
//  IM_TextView.m
//  L_Chat
//
//  Created by dzj on 2020/6/3.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_TextView.h"

@implementation IM_TextView
- (instancetype)init
{
    self = [super init];
    if (self) {
        UIMenuItem *menuReturn = [[UIMenuItem alloc] initWithTitle:@"换行" action:@selector(insertReturn)];
        [UIMenuController sharedMenuController].menuItems = @[menuReturn];
    }
    return self;
}

// 插入换行符
-(void)insertReturn {
    NSRange range = self.selectedRange;
    if(self.selectedRange.location >= 0 &&
       self.selectedRange.location+self.selectedRange.length <= self.text.length) {
        NSMutableString *str = [NSMutableString stringWithString:self.text];
        [str insertString:@"\n" atIndex:self.selectedRange.location];
        self.text = [str copy];
        self.selectedRange = NSMakeRange(range.location+1 > self.text.length?self.text.length:range.location+1, 0);
    }
}

// 选中文字后是否能够弹出菜单
- (BOOL)canBecameFirstResponder {
    return YES;
}

// 选中文字后的系统菜单响应的选项
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        if(self.selectedRange.length > 0) {
            return YES;
        } else {
            return NO;
        }
    } else if (action == @selector(paste:)) {
        return YES;
    } else if (action == @selector(cut:)) {
        if(self.text.length == 0) {
            return NO;
        } else {
            return YES;
        }
    } else if (action == @selector(selectAll:)) {
        if(self.text.length == 0) {
            return NO;
        } else {
            return YES;
        }
    } else if (action == @selector(select:)) {
        if((self.selectedRange.length > 0 && self.selectedRange.length < self.text.length) ||
           self.text.length == 0) {
            return NO;
        } else {
            return YES;
        }
    } else if (action == @selector(insertReturn)) {
        if(self.selectedRange.length == 0) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

@end
