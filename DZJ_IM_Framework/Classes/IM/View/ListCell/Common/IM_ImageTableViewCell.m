//
//  IM_ImageTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_ImageTableViewCell.h"

@interface IM_ImageTableViewCell()

@property (nonatomic, strong) UIImageView *imgView;

@end

static CGFloat ImageSpace = 0;
static CGFloat ImageSide = 100;

@implementation IM_ImageTableViewCell

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    self.arrowImageView.hidden = YES;
    self.imgView.hidden = YES;
    if([data.imageData isKindOfClass:[NSData class]]) {
        self.imgView.image = [UIImage imageWithData:data.imageData];
        if(self.imgView.image) {
            [self.imgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(self.imgView.image.size.width/self.imgView.image.size.height*ImageSide));
            }];
            self.imgView.hidden = NO;
        }
    } else {
        if(data.fileModel != nil) {
            [self.imgView loadImageWithURL:clearNilStr(data.fileModel.url) placeholder:self.imgView.image?self.imgView.image:[UIImage imageNamed:@"4_3PlaceholdeImg"] completed:^(UIImage *image, NSError *error) {
                if(image) {
                    [self.imgView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.width.equalTo(@(image.size.width/image.size.height*100));
                    }];
                    self.imgView.hidden = NO;
                }
            }];
        } else {
            [self.imgView loadImageWithURL:data.content placeholder:self.imgView.image?self.imgView.image:[UIImage imageNamed:@"4_3PlaceholdeImg"] completed:^(UIImage *image, NSError *error) {
                if(image) {
                    [self.imgView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.width.equalTo(@(image.size.width/image.size.height*100));
                    }];
                    self.imgView.hidden = NO;
                }
            }];
        }
    }
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
    if(self.imgView.superview == nil) {
        [self.container addSubview:self.imgView];
    }
    [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).offset(ImageSpace);
        make.right.equalTo(self.container).offset(-ImageSpace);
        make.top.equalTo(self.container).offset(ImageSpace);
        make.bottom.equalTo(self.container).offset(-ImageSpace);
        make.width.equalTo(@(ImageSide));
        make.height.equalTo(@(ImageSide));
    }];
}

#pragma mark - lazy

-(UIImageView *)imgView {
    if(_imgView == nil) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.userInteractionEnabled = YES;
    }
    return _imgView;
}

@end
