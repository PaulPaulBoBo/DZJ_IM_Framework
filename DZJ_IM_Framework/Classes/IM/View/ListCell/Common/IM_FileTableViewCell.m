//
//  IM_FileTableViewCell.m
//  L_Chat
//
//  Created by dzj on 2020/6/9.
//  Copyright © 2020 paul. All rights reserved.
//

#import "IM_FileTableViewCell.h"

@interface IM_FileTableViewCell()

@property (nonatomic, strong) UIImageView *fileImageView; // 文件图标
@property (nonatomic, strong) UILabel *fileNameLabel; // 文件名标签
@property (nonatomic, strong) UILabel *fileSizeLabel; // 文件大小标签

@end

static CGFloat FileBoardSpace = 10;

@implementation IM_FileTableViewCell

#pragma mark - public

// 单元填充函数
- (void)fillWithData:(IM_MessageModel *)data {
    [super fillWithData:data];
    if(data.fileModel) {
        self.fileNameLabel.text = clearNilStr(data.fileModel.name);
        self.fileImageView.image = [self imageWithFileType:clearNilStr([clearNilStr(data.fileModel.name) componentsSeparatedByString:@"."].lastObject)];
        if(data.fileModel.size.floatValue < 1000) {
            self.fileSizeLabel.text = [NSString stringWithFormat:@"%.0fB", data.fileModel.size.floatValue];
        } else if(data.fileModel.size.floatValue >= 1000 && data.fileModel.size.floatValue < 1000*1000) {
            self.fileSizeLabel.text = [NSString stringWithFormat:@"%.1fKB", data.fileModel.size.floatValue/1000.0];
        } else {
            self.fileSizeLabel.text = [NSString stringWithFormat:@"%.1fMB", data.fileModel.size.floatValue/(1000.0*1000.0)];
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
    [self.container addSubview:self.fileImageView];
    [self.fileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.container).offset(FileBoardSpace);
        make.bottom.lessThanOrEqualTo(self.container).offset(-FileBoardSpace);
        make.height.equalTo(@60);
        make.width.equalTo(@60);
    }];
    
    [self.container addSubview:self.fileNameLabel];
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fileImageView.mas_right).offset(FileBoardSpace);
        make.right.equalTo(self.container).offset(-(FileBoardSpace));
        make.top.equalTo(self.container).offset(FileBoardSpace);
    }];
    
    [self.container addSubview:self.fileSizeLabel];
    [self.fileSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fileImageView.mas_right).offset(FileBoardSpace);
        make.right.lessThanOrEqualTo(self.container).offset(-(FileBoardSpace));
        make.top.equalTo(self.fileNameLabel.mas_bottom).offset(FileBoardSpace);
        make.bottom.lessThanOrEqualTo(self.container).offset(-FileBoardSpace);
    }];
}

-(UIImage *)imageWithFileType:(NSString *)type {
    NSString *imageName = @"im_file_unknown";
    if([type rangeOfString:@"doc"].length > 0) {
        imageName = @"im_file_word";
    } else if([type rangeOfString:@"pdf"].length > 0) {
        imageName = @"im_file_pdf";
    } else if([type rangeOfString:@"xl"].length > 0) {
        imageName = @"im_file_excel";
    } else if([type rangeOfString:@"ppt"].length > 0) {
        imageName = @"im_file_ppt";
    }
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
    return image;
}

#pragma mark - lazy

-(UIImageView *)fileImageView {
    if(_fileImageView == nil) {
        _fileImageView = [[UIImageView alloc] init];
        _fileImageView.clipsToBounds = YES;
        _fileImageView.layer.cornerRadius = 8;
        _fileImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _fileImageView;
}

-(UILabel *)fileNameLabel {
    if(_fileNameLabel == nil) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.font = [UIFont systemFontOfSize:15];
        _fileNameLabel.textColor = [UIColor blackColor];
        _fileNameLabel.textAlignment = NSTextAlignmentLeft;
        _fileNameLabel.numberOfLines = 0;
        _fileNameLabel.userInteractionEnabled = YES;
    }
    return _fileNameLabel;
}

-(UILabel *)fileSizeLabel {
    if(_fileSizeLabel == nil) {
        _fileSizeLabel = [[UILabel alloc] init];
        _fileSizeLabel.font = [UIFont systemFontOfSize:15];
        _fileSizeLabel.textColor = [UIColor blackColor];
        _fileSizeLabel.textAlignment = NSTextAlignmentLeft;
        _fileSizeLabel.numberOfLines = 0;
        _fileSizeLabel.userInteractionEnabled = YES;
    }
    return _fileSizeLabel;
}

@end
