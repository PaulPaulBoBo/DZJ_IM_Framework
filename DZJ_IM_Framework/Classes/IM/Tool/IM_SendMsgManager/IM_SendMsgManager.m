//
//  IM_SendMsgManager.m
//  DoctorCloud
//
//  Created by dzj on 2020/6/18.
//  Copyright © 2020 大专家.com. All rights reserved.
//

#import "IM_SendMsgManager.h"
#import "ZLPhoto.h"

@implementation IM_FileInfoModel

+(BOOL)propertyIsOptional:(NSString *)propertyName {
    if([propertyName isEqual:@"key"]) {
        return NO;
    } else {
        return YES;
    }
}

-(void)setKey:(NSString *)key {
    _key = key;
    if(_name == nil || _name.length == 0) {
        _name = clearNilStr([key componentsSeparatedByString:@"/"].lastObject);
    }
}

@end

typedef void(^UploadSuccess)(IM_FileInfoModel *model, id sendObj, IM_MessageModel *msgModel);
typedef void(^UploadFail)(void);
typedef void(^UploadCancel)(void);
typedef void(^PreparedUploadSuccess)(NSArray *objs);
typedef void(^SendingIndex)(NSArray *msgModels);

@interface IM_SendMsgManager()<ZLPhotoPickerViewControllerDelegate, ZLPhotoPickerBrowserViewControllerDelegate, UIDocumentPickerDelegate>

@property (nonatomic, strong) UploadSuccess uploadSuccess;
@property (nonatomic, strong) UploadFail uploadFail;
@property (nonatomic, strong) UploadCancel uploadCancel;
@property (nonatomic, strong) SendProgress sendProgress;
@property (nonatomic, strong) PreparedUploadSuccess preparedUploadSuccess;
@property (nonatomic, strong) SendingIndex sendingIndex;

@property (nonatomic, strong) UIViewController *rootViewController;

@end

@implementation IM_SendMsgManager

#pragma mark - public

// 配置视图控制器
-(void)configViewController:(UIViewController *)viewController {
    self.rootViewController = viewController;
}

// 发送消息
-(NSArray *)sendMsgWithModel:(IM_MessageModel *)model
                 currentMsgs:(NSArray *)currentMsgs
              sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                 sendMsgFail:(SendMsgFail)sendMsgFail
                sendProgress:(SendProgress)sendProgress
      preparedSendMsgSuccess:(PreparedSendMsgSuccess)preparedSendMsgSuccess {
    return [self sendDealedMsgWithModel:model currentMsgs:currentMsgs sendMsgSuccess:sendMsgSuccess sendMsgFail:sendMsgFail sendProgress:sendProgress preparedSendMsgSuccess:preparedSendMsgSuccess];
}

static NSInteger sendingIndex = 0;
// 发送多张图片
-(NSArray *)sendImagesWithtargetType:(NSString *)targetType
                            targetId:(NSString *)targetId
                         currentMsgs:(NSArray *)currentMsgs
                      sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                         sendMsgFail:(SendMsgFail)sendMsgFail
                        sendProgress:(SendProgress)sendProgress
              preparedSendMsgSuccess:(PreparedSendMsgSuccess)preparedSendMsgSuccess {
    __block NSMutableArray *tmpCurrentMsgs = [NSMutableArray arrayWithArray:currentMsgs];
    __block NSMutableArray *sendingImages = [NSMutableArray new];
    @weakify(self)
    self.sendingIndex = ^(NSArray *msgModels) {
        @strongify(self)
        tmpCurrentMsgs = [NSMutableArray arrayWithArray:msgModels];
        sendingIndex++;
        if(sendingIndex < sendingImages.count) {
            IM_MessageModel *newTmpModel = [sendingImages objectAtIndex:sendingIndex];
            if(newTmpModel.state == IM_MessageStateSending) {
                [self sendDealedMsgWithModel:newTmpModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:sendMsgSuccess sendMsgFail:sendMsgFail sendProgress:sendProgress preparedSendMsgSuccess:nil];
            }
        }
    };
    [self jumpToSelectImageVC];
    
    self.preparedUploadSuccess = ^(NSArray *objs) {
        @strongify(self)
        sendingIndex = 0;
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:tmpCurrentMsgs];
        for (int i = 0; i < objs.count; i++) {
            if([[objs objectAtIndex:i] isKindOfClass:[IM_FileContentModel class]]) {
                IM_MessageModel *newTmpModel = [IM_MessageModel createModelWithMsgType:IM_MsgTypeFile content:@"" targetType:targetType targetId:targetId];
                IM_FileContentModel *fileModel = [[IM_FileContentModel alloc] init];
                fileModel = [objs objectAtIndex:i];
                newTmpModel.fileModel = fileModel;
                newTmpModel.state = IM_MessageStateSending;
                newTmpModel.msgType = IM_MsgTypeImageVideo;
                [mArr addObject:newTmpModel];
                [sendingImages addObject:newTmpModel];
            } else {
                IM_MessageModel *newTmpModel = [IM_MessageModel createModelWithMsgType:IM_MsgTypeImage content:@"" targetType:targetType targetId:targetId];
                newTmpModel.imageData = [objs objectAtIndex:i];
                newTmpModel.state = IM_MessageStateSending;
                [mArr addObject:newTmpModel];
                [sendingImages addObject:newTmpModel];
            }
        }
        tmpCurrentMsgs = [NSMutableArray arrayWithArray:[mArr copy]];
        IM_MessageModel *firstNewTmpModel = [tmpCurrentMsgs objectAtIndex:tmpCurrentMsgs.count-objs.count];
        [self sendDealedMsgWithModel:firstNewTmpModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:sendMsgSuccess sendMsgFail:sendMsgFail sendProgress:sendProgress preparedSendMsgSuccess:nil];
        if(preparedSendMsgSuccess) {
            preparedSendMsgSuccess([mArr copy]);
        }
    };
    return currentMsgs;
}

// 撤回消息
-(NSArray *)deleteMsgWithModel:(IM_MessageModel *)model
                   currentMsgs:(NSArray *)currentMsgs
              deleteMsgSuccess:(DeleteMsgSuccess)deleteMsgSuccess
                 deleteMsgFail:(DeleteMsgFail)deleteMsgFail {
    model.isDeleted = YES;
    [[IM_RequestManager shareInstance] deleteMsg:model currentMsgs:currentMsgs deleteMsgSuccess:^(IM_MessageModel *model) {
        if(deleteMsgSuccess) {
            deleteMsgSuccess(model);
        }
    } deleteMsgFail:^{
        if(deleteMsgFail) {
            deleteMsgFail();
        }
    }];
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:currentMsgs];
    for (NSInteger i = mArr.count - 1; i >= 0; i--) {
        IM_MessageModel *tmpModel = [mArr objectAtIndex:i];
        if(model.IM_id == tmpModel.IM_id) {
            [mArr replaceObjectAtIndex:i withObject:model];
            break;
        }
    }
    return mArr;
}

#pragma mark - private

/// 发送处理后的消息
/// @param model 消息模型
/// @param currentMsgs 当前列表内的历史消息数组
-(NSArray *)sendDealedMsgWithModel:(IM_MessageModel *)waitingDealModel
                       currentMsgs:(NSArray *)currentMsgs
                    sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                       sendMsgFail:(SendMsgFail)sendMsgFail
                      sendProgress:(SendProgress)sendProgress
            preparedSendMsgSuccess:(PreparedSendMsgSuccess)preparedSendMsgSuccess {
    __block NSMutableArray *tmpCurrentMsgs = [NSMutableArray arrayWithArray:currentMsgs];
    switch (waitingDealModel.msgType) {
        case IM_MsgTypeImage: {
            return [self sendDealedImageMsgWithModel:waitingDealModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:sendMsgSuccess sendMsgFail:sendMsgFail sendProgress:sendProgress preparedSendMsgSuccess:preparedSendMsgSuccess];
        } break;
        case IM_MsgTypeFile:
        case IM_MsgTypeImageVideo:{
            return [self sendDealedFileMsgWithModel:waitingDealModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:sendMsgSuccess sendMsgFail:sendMsgFail sendProgress:sendProgress preparedSendMsgSuccess:preparedSendMsgSuccess];
        } break;
        case IM_MsgTypeAudio: {
            return [self sendDealedAudioMsgWithModel:waitingDealModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:sendMsgSuccess sendMsgFail:sendMsgFail sendProgress:sendProgress preparedSendMsgSuccess:preparedSendMsgSuccess];
        } break;
        default: {
            [tmpCurrentMsgs addObject:waitingDealModel];
            [[IM_RequestManager shareInstance] sendMsg:waitingDealModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:^(NSArray<IM_MessageModel *> *msgs, IM_MessageModel *sendedModel) {
                if(sendMsgSuccess) {
                    sendMsgSuccess([msgs copy], sendedModel);
                }
            } sendMsgFail:^(IM_MessageModel *failModel){
                if(sendMsgFail) {
                    sendMsgFail(failModel);
                }
            }];
            return tmpCurrentMsgs;
        } break;
    }
}

-(NSArray *)sendDealedImageMsgWithModel:(IM_MessageModel *)waitingDealModel
                            currentMsgs:(NSArray *)currentMsgs
                         sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                            sendMsgFail:(SendMsgFail)sendMsgFail
                           sendProgress:(SendProgress)sendProgress
                 preparedSendMsgSuccess:(PreparedSendMsgSuccess)preparedSendMsgSuccess {
    __block NSMutableArray *tmpCurrentMsgs = [NSMutableArray arrayWithArray:currentMsgs];
    NSDictionary *fileDict = @{@"data":waitingDealModel.imageData,@"type":@"image/jpeg",@"name":@"image.jpg"};
    [self uploadImageData:fileDict msgModel:waitingDealModel uploadSuccess:^(IM_FileInfoModel *model, id sendObj, IM_MessageModel *msgModel) {
        if(msgModel) {
            msgModel.content = [NSString stringWithFormat:@"%@", clearNilStr(model.key)];
            [[IM_RequestManager shareInstance] sendMsg:msgModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:^(NSArray<IM_MessageModel *> *msgs, IM_MessageModel *sendedModel) {
                tmpCurrentMsgs = [NSMutableArray arrayWithArray:msgs];
                if(sendMsgSuccess) {
                    sendMsgSuccess([msgs copy], sendedModel);
                }
                if(self.sendingIndex) {
                    self.sendingIndex(tmpCurrentMsgs);
                }
            } sendMsgFail:^(IM_MessageModel *failModel){
                if(sendMsgFail) {
                    sendMsgFail(failModel);
                }
                if(self.sendingIndex) {
                    self.sendingIndex(tmpCurrentMsgs);
                }
            }];
        }
    } uploadFail:^{
        
    } uploadCancel:^{
        
    } sendProgress:^(CGFloat progressValue, id sendingObj, IM_MessageModel *sendingModel) {
        BOOL isExist = NO;
        IM_MessageModel *newTmpModel = [[IM_MessageModel alloc] init];
        for (NSInteger i = tmpCurrentMsgs.count - 1; i >= 0; i--) {
            newTmpModel = [tmpCurrentMsgs objectAtIndex:i];
            if(newTmpModel.imageData != nil) {
                if(newTmpModel.imageData == sendingObj) {
                    isExist = YES;
                    break;
                }
            }
        }
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:tmpCurrentMsgs];
        if(!isExist) {
            [mArr addObject:newTmpModel];
        }
        if(sendProgress) {
            sendProgress(progressValue, nil, newTmpModel);
        }
    }];
    return tmpCurrentMsgs;
}

-(NSArray *)sendDealedFileMsgWithModel:(IM_MessageModel *)waitingDealModel
                           currentMsgs:(NSArray *)currentMsgs
                        sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                           sendMsgFail:(SendMsgFail)sendMsgFail
                          sendProgress:(SendProgress)sendProgress
                preparedSendMsgSuccess:(PreparedSendMsgSuccess)preparedSendMsgSuccess {
    __block NSMutableArray *tmpCurrentMsgs = [NSMutableArray arrayWithArray:currentMsgs];
    [self sendWaitingDealModel:waitingDealModel fileUploadSuccess:^(IM_FileInfoModel *model, id sendObj, IM_MessageModel *msgModel) {
        IM_FileContentModel *fileModel = [[IM_FileContentModel alloc] init];
        fileModel.name = model.name;
        fileModel.url = model.key;
        fileModel.size = model.fileSize;
        msgModel.fileModel = fileModel;
        NSError *parseError = nil;
        NSDictionary *dic = [msgModel.fileModel toDictionary];
        NSData *contentData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
        msgModel.content = [[NSString alloc] initWithData:contentData encoding:(NSUTF8StringEncoding)];
        
        [[IM_RequestManager shareInstance] sendMsg:msgModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:^(NSArray<IM_MessageModel *> *msgs, IM_MessageModel *sendedModel) {
            if(sendMsgSuccess) {
                sendMsgSuccess([msgs copy], sendedModel);
            }
        } sendMsgFail:^(IM_MessageModel *failModel){
            if(sendMsgFail) {
                sendMsgFail(failModel);
            }
        }];
        
    } uploadFail:^{
        
    } uploadCancel:^{
        
    } sendProgress:^(CGFloat progressValue, id sendingObj, IM_MessageModel *sendingModel) {
        if(sendProgress) {
            sendProgress(progressValue, [tmpCurrentMsgs copy], sendingModel);
        }
    } preparedUploadSuccess:^(NSArray *objs) {
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:tmpCurrentMsgs];
        for (int i = 0; i < objs.count; i++) {
            if([[objs objectAtIndex:i] isKindOfClass:[IM_FileContentModel class]]) {
                IM_MessageModel *newTmpModel = [IM_MessageModel createModelWithMsgType:IM_MsgTypeFile content:@"" targetType:waitingDealModel.targetType targetId:waitingDealModel.targetId];
                IM_FileContentModel *fileModel = [[IM_FileContentModel alloc] init];
                fileModel = [objs objectAtIndex:i];
                newTmpModel.fileModel = fileModel;
                newTmpModel.state = IM_MessageStateSending;
                newTmpModel.localStateId = waitingDealModel.localStateId;
                newTmpModel.msgType = waitingDealModel.msgType;
                [mArr addObject:newTmpModel];
            }
        }
        tmpCurrentMsgs = [NSMutableArray arrayWithArray:[mArr copy]];
        if(preparedSendMsgSuccess) {
            preparedSendMsgSuccess([tmpCurrentMsgs copy]);
        }
    }];
    return tmpCurrentMsgs;
}

-(NSArray *)sendDealedAudioMsgWithModel:(IM_MessageModel *)waitingDealModel
                            currentMsgs:(NSArray *)currentMsgs
                         sendMsgSuccess:(SendMsgSuccess)sendMsgSuccess
                            sendMsgFail:(SendMsgFail)sendMsgFail
                           sendProgress:(SendProgress)sendProgress
                 preparedSendMsgSuccess:(PreparedSendMsgSuccess)preparedSendMsgSuccess {
    __block NSMutableArray *tmpCurrentMsgs = [NSMutableArray arrayWithArray:currentMsgs];
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:tmpCurrentMsgs];
    IM_MessageModel *newTmpModel = [IM_MessageModel createModelWithMsgType:IM_MsgTypeAudio content:@"" targetType:waitingDealModel.targetType targetId:waitingDealModel.targetId];
    newTmpModel.voiceModel = waitingDealModel.voiceModel;
    newTmpModel.state = IM_MessageStateSending;
    [mArr addObject:newTmpModel];
    tmpCurrentMsgs = [NSMutableArray arrayWithArray:[mArr copy]];
    if(preparedSendMsgSuccess) {
        preparedSendMsgSuccess(tmpCurrentMsgs);
    }
    
    [self sendWaitingDealModel:newTmpModel fileName:clearNilStr(newTmpModel.voiceModel.voiceName) uploadSuccess:^(IM_FileInfoModel *model, id sendObj, IM_MessageModel *msgModel) {
        msgModel.voiceModel.url = [NSString stringWithFormat:@"%@" ,model.key];
        msgModel.voiceModel.voiceData = [NSData data];
        NSError *parseError = nil;
        NSDictionary *dic = @{@"url":clearNilStr(msgModel.voiceModel.url),
                              @"duration":clearNilStr([msgModel.voiceModel.duration stringValue])};
        NSData *contentData = [NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&parseError];
        msgModel.content = [[NSString alloc] initWithData:contentData encoding:(NSUTF8StringEncoding)];
        
        [[IM_RequestManager shareInstance] sendMsg:msgModel currentMsgs:tmpCurrentMsgs sendMsgSuccess:^(NSArray<IM_MessageModel *> *msgs, IM_MessageModel *sendedModel) {
            if(sendMsgSuccess) {
                sendMsgSuccess([msgs copy], sendedModel);
            }
        } sendMsgFail:^(IM_MessageModel *failModel){
            if(sendMsgFail) {
                sendMsgFail(failModel);
            }
        }];
        
    } uploadFail:^{
        
    } uploadCancel:^{
        
    } sendProgress:^(CGFloat progressValue, id sendingObj, IM_MessageModel *sendingModel) {
        sendingModel.voiceModel.voiceData = sendingObj;
        BOOL isExist = NO;
        for (NSInteger i = tmpCurrentMsgs.count-1; i >= 0; i--) {
            IM_MessageModel *tmpModel = [tmpCurrentMsgs objectAtIndex:i];
            if(clearNilStr(tmpModel.localStateId).length > 0 && clearNilStr(sendingModel.localStateId)) {
                isExist = YES;
                break;
            }
        }
        if(!isExist) {
            NSMutableArray *mArr = [NSMutableArray arrayWithArray:tmpCurrentMsgs];
            [mArr addObject:sendingModel];
            if(sendProgress) {
                sendProgress(progressValue, [mArr copy], sendingModel);
            }
        }
    }];
    return tmpCurrentMsgs;
}

// 根据localStateId找到对应的数据
-(IM_MessageModel *)loadLoacalModel:(NSString *)localId inDatArray:(NSArray *)dataArray {
    IM_MessageModel *model = nil;
    for (NSInteger i = dataArray.count-1; i >= 0; i--) {
        model = [dataArray objectAtIndex:i];
        if([model.localStateId isEqualToString:localId]) {
            break;
        }
    }
    return model;
}

// 发送文件特殊处理
-(void)sendWaitingDealModel:(IM_MessageModel *)waitingDealModel fileUploadSuccess:(UploadSuccess)uploadSuccess uploadFail:(UploadFail)uploadFail uploadCancel:(UploadCancel)uploadCancel sendProgress:(SendProgress)sendProgress preparedUploadSuccess:(PreparedUploadSuccess)preparedUploadSuccess {
    self.uploadSuccess = ^(IM_FileInfoModel *model, id sendObj, IM_MessageModel *msgModel) {
        if(uploadSuccess) {
            uploadSuccess(model, sendObj, waitingDealModel);
        }
    };
    
    self.uploadFail = ^{
        if(uploadFail) {
            uploadFail();
        }
    };
    
    self.uploadCancel = ^{
        if(uploadCancel) {
            uploadCancel();
        }
    };
    
    self.sendProgress = ^(CGFloat progressValue, id sendingObj, IM_MessageModel *sendingModel) {
        if(sendProgress) {
            sendProgress(progressValue, sendingObj, waitingDealModel);
        }
    };
    
    if(waitingDealModel.fileModel.fileData == nil) {
        self.preparedUploadSuccess = ^(NSArray *objs) {
            if(preparedUploadSuccess) {
                preparedUploadSuccess(objs);
            }
        };
        
        [self presentDocumentPicker];
    } else {
        if(preparedUploadSuccess) {
            preparedUploadSuccess(@[waitingDealModel.fileModel]);
        }
        [self uploadFileData:@{@"data":waitingDealModel.fileModel.fileData,@"type":clearNilStr([waitingDealModel.fileModel.name componentsSeparatedByString:@"."].lastObject),@"name":clearNilStr(waitingDealModel.fileModel.name)}];
    }
}

// 发送语音特殊处理
-(void)sendWaitingDealModel:(IM_MessageModel *)waitingDealModel fileName:(NSString *)fileName uploadSuccess:(UploadSuccess)uploadSuccess uploadFail:(UploadFail)uploadFail uploadCancel:(UploadCancel)uploadCancel sendProgress:(SendProgress)sendProgress {
    self.uploadSuccess = ^(IM_FileInfoModel *model, id sendObj, IM_MessageModel *msgModel) {
        if(uploadSuccess) {
            uploadSuccess(model, sendObj, waitingDealModel);
        }
    };
    
    self.uploadFail = ^{
        if(uploadFail) {
            uploadFail();
        }
    };
    
    self.uploadCancel = ^{
        if(uploadCancel) {
            uploadCancel();
        }
    };
    
    self.sendProgress = ^(CGFloat progressValue, id sendingObj, IM_MessageModel *sendingModel) {
        if(sendProgress) {
            sendProgress(progressValue, sendingObj, waitingDealModel);
        }
    };
    
    [self uploadFileData:@{@"data":waitingDealModel.voiceModel.voiceData,@"type":@"amr",@"name":fileName}];
}

// 选择图片方式
- (void)jumpToSelectImageVC {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"取 消")style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:LS(@"拍 照")style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openZLCameraPickerVC];
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:LS(@"从相册选择")style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openZLPhotoPickerVC];
    }];
    
    [alertController addAction:cancelAction];
    // 判断是否支持相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:cameraAction];
    }
    [alertController addAction:photoAction];
    // 放主线程中弹出   避免延迟
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}

// 拍照获取图片
- (void)openZLCameraPickerVC {
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    cameraVc.maxCount = 9;
    @weakify(self)
    cameraVc.callback = ^(NSArray *cameras){
        @strongify(self)
        // cameras就是拍摄的照片数组
        if (cameras.count > 0) {
            NSMutableArray *images = [NSMutableArray new];
            for (int i = 0; i < cameras.count; i++) {
                ZLCamera* imageAgo = [cameras objectAtIndex:i];
                UIImage *image = [UIImage fixOrientation:imageAgo.thumbImage];
                [images addObject:UIImagePNGRepresentation(image)];
            }
            if(self.preparedUploadSuccess) {
                self.preparedUploadSuccess(images);
            }
        }
    };
    [cameraVc showPickerVc:self.rootViewController];
}

// 使用相册中的图片
-(void)openZLPhotoPickerVC {
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.delegate = self;
    pickerVc.maxCount = 9;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    [pickerVc showPickerVc:self.rootViewController];
}

// 从相册中选择图片完成回调
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets {
    if (assets.count > 0) {
        NSMutableArray *images = [NSMutableArray new];
        for (int i = 0; i < assets.count; i++) {
            ZLPhotoAssets *asset = [assets objectAtIndex:i];
            if(asset.isVideoType) {
                ALAssetRepresentation *asRe = [asset.asset defaultRepresentation];
                long long size = asRe.size;
                NSMutableData *data = [[NSMutableData alloc] initWithCapacity:size];
                void *buffer = [data mutableBytes];
                [asRe getBytes:buffer fromOffset:0 length:size error:nil];
                NSString *name = [self loadVideoNameWithAsset:asset];
                NSData *videoData = [[NSData alloc] initWithBytes:buffer length:size];
                IM_FileContentModel *fileModel = [[IM_FileContentModel alloc] init];
                fileModel.fileData = videoData;
                fileModel.fileName = name;
                fileModel.name = name;
                fileModel.size = @(videoData.length);
                fileModel.snapImage = [UIImage fixOrientation:asset.originImage];
                if(videoData) {
                    [images addObject:fileModel];
                }
            } else {
                UIImage *image = [UIImage fixOrientation:asset.originImage];
                if(image != nil) {
                    [images addObject:UIImagePNGRepresentation(image)];
                }
            }
        }
        if(self.preparedUploadSuccess) {
            self.preparedUploadSuccess(images);
        }
    } else {
        // 取消选择
        if(self.uploadCancel) {
            self.uploadCancel();
        }
    }
}

-(NSString *)loadVideoNameWithAsset:(ZLPhotoAssets *)asset {
    NSString *name = [asset.assetURL.absoluteString componentsSeparatedByString:@"id="].lastObject;
    if(name == nil || name.length == 0) {
        name = [NSString stringWithFormat:@"video_%@.MOV", [NSDate createSSSDate:[NSDate date]]];
    } else {
        name = [name stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];
    }
    return name;
}

// 选择文件
- (void)presentDocumentPicker {
    NSArray *types = @[@"public.content",@"public.text",@"public.image"]; // 可以选择的文件类型
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    [self.rootViewController presentViewController:documentPicker animated:YES completion:nil];
    
    //跟随系统颜色
    [UINavigationBar appearance].tintColor = [UIColor blackColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
}

// 选择文件回调
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    [self dealDocumentUrl:url];
}

// 选择文件回调 适配iOS11
-(void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if(urls.count > 0) {
        NSURL *url = [urls objectAtIndex:0];
        [self dealDocumentUrl:url];
    }
}

// 处理选择文件回调
-(void)dealDocumentUrl:(NSURL *)url {
    BOOL canAccessingResource = [url startAccessingSecurityScopedResource];
    if(canAccessingResource) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        @weakify(self)
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            @strongify(self)
            [self.rootViewController dismissViewControllerAnimated:YES completion:^{
            }];
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            NSString *fileName = newURL.lastPathComponent;
            NSString *fileType = newURL.pathExtension;
            if(self.preparedUploadSuccess) {
                IM_FileContentModel *fileModel = [[IM_FileContentModel alloc] init];
                fileModel.fileData = fileData;
                fileModel.fileName = fileName;
                fileModel.name = fileName;
                fileModel.size = @(fileData.length);
                self.preparedUploadSuccess(@[fileModel]);
            }
            [self uploadFileData:@{@"data":fileData,@"type":clearNilStr(fileType),@"name":clearNilStr(fileName)}];
        }];
    }
    [url stopAccessingSecurityScopedResource];
}

// 上传图片
- (void)uploadImageData:(NSDictionary *)fileDict msgModel:(IM_MessageModel *)msgModel uploadSuccess:(UploadSuccess)uploadSuccess uploadFail:(UploadFail)uploadFail uploadCancel:(UploadCancel)uploadCancel sendProgress:(SendProgress)sendProgress {
    [[DZJHttpManager shareManager]requestWithUpLoadFile:@[fileDict] succeedBlock:^(NSDictionary *responseObject) {
        NSArray *data = [[responseObject objectForKey:@"data"] safeCastForClass:[NSArray class]];
        NSDictionary *dict = data.count > 0 ? data.firstObject : nil;
        if(dict != nil) {
            /*
             图片地址:[dict objectForKey:@"key"],
             图片名字:fileDict[@"name"],
             图片大小(B):[dict objectForKey:@"fileSize"],
             图片类型:[dict objectForKey:@"typeEnum"]
             */
            NSError *error = nil;
            IM_FileInfoModel *fileModel = [[IM_FileInfoModel alloc] initWithDictionary:dict error:&error];
            if(error == nil) {
                if(uploadSuccess) {
                    uploadSuccess(fileModel, [fileDict objectForKey:@"data"], msgModel);
                }
            }
        } else {
            // 上传有问题
            if(uploadFail) {
                uploadFail();
            }
        }
    } failedBlock:^(NSError *error) {
        // 上传失败
        if(uploadFail) {
            uploadFail();
        }
    } progressBlock:^(NSProgress *progress) {
        if(sendProgress) {
            CGFloat processValue = progress.fractionCompleted;
            if (processValue >= 0.99) { //加这个判断是因为图片上传完到服务端返回成功有个时间差
                processValue = 0.99;
            }
            sendProgress(processValue, [fileDict objectForKey:@"data"], nil);
        }
    }];
}

// 上传文件
- (void)uploadFileData:(NSDictionary *)fileDict {
    [[DZJHttpManager shareManager] requestWithUpLoadFile:@[fileDict] succeedBlock:^(NSDictionary *responseObject) {
        NSArray *data = [[responseObject objectForKey:@"data"] safeCastForClass:[NSArray class]];
        NSDictionary *dict = data.count > 0 ? data.firstObject : nil;
        if(dict != nil) {
            /*
             图片地址:[dict objectForKey:@"key"],
             图片名字:fileDict[@"name"],
             图片大小(B):[dict objectForKey:@"fileSize"],
             图片类型:[dict objectForKey:@"typeEnum"]
             */
            NSError *error = nil;
            IM_FileInfoModel *fileModel = [[IM_FileInfoModel alloc] initWithDictionary:dict error:&error];
            fileModel.name = clearNilStr([fileDict objectForKey:@"name"]);
            fileModel.fileSize = @(((NSData *)[fileDict objectForKey:@"data"]).length);
            fileModel.key = [NSString stringWithFormat:@"%@", clearNilStr([dict objectForKey:@"key"])];
            if(error == nil) {
                if(self.uploadSuccess) {
                    self.uploadSuccess(fileModel, [fileDict objectForKey:@"data"], nil);
                }
            }
        } else {
            // 上传有问题
            if(self.uploadFail) {
                self.uploadFail();
            }
        }
    } failedBlock:^(NSError *error) {
        // 上传失败
        if(self.uploadFail) {
            self.uploadFail();
        }
    } progressBlock:^(NSProgress *progress) {
        if(self.sendProgress) {
            CGFloat processValue = progress.fractionCompleted;
            if (processValue >= 0.99) { //加这个判断是因为图片上传完到服务端返回成功有个时间差
                processValue = 0.99;
            }
            self.sendProgress(processValue, [fileDict objectForKey:@"data"], nil);
        }
    }];
}

#pragma mark - lazy

-(UIViewController *)rootViewController {
    if(_rootViewController == nil) {
        _rootViewController = [DZJRouter sharedInstance].currentViewController;
    }
    return _rootViewController;
}

@end
