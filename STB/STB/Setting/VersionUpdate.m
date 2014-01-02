//
//  VersionUpdate.m
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "VersionUpdate.h"
#import "MBProgressHUD.h"
#import "UPNPTool.h"
#import "CommonUtil.h"
#import "CommandClient.h"
#import "ConfirmUtil.h"
#import "ConfirmMunePassword.h"

@interface VersionUpdate ()<MBProgressHUDDelegate>
{
    MBProgressHUD *updateAlert;
    NSString *serverSTBVersion;
}
@property (nonatomic,strong) ConfirmUtil *aConfirmUtil;

@end

@implementation VersionUpdate


static NSString *softName = @"flashrom.bin";
static NSString *configName = @"CONFIG.INI";

static MBProgressHUD *updateAlert;


+ (void)DefaultSTB
{
    dispatch_queue_t defaultqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultqueue,^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self STBFilePath]]) {
            NSString *boundSTBPath = [[NSBundle mainBundle] bundlePath];
            boundSTBPath = [boundSTBPath stringByAppendingPathComponent:softName];
            NSError *error = nil;
            
            [[NSFileManager defaultManager] copyItemAtPath:boundSTBPath toPath:[self STBFilePath] error:&error];
            if (error) {
                ERROR(@"机顶盒固件拷贝错误：%@",error);
            }
        }
    });
}

+ (BOOL)IsSTBRemindUpgrade
{
    
    NSNumber *isRemind = [[NSUserDefaults standardUserDefaults] objectForKey:STB_RemindUpgrade];
    if (isRemind==nil) {
        isRemind = [NSNumber numberWithBool:NO];
//        [[NSUserDefaults standardUserDefaults] setObject:isRemind forKey:STB_RemindUpgrade];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return isRemind.boolValue;
}

+ (VersionUpdate*)shareInstance
{
    static VersionUpdate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VersionUpdate alloc] init];
    });
    
    return instance;
}

//默认版本号
+ (NSString*)STBSoftwareVersion
{
    NSString *version = [[NSUserDefaults standardUserDefaults] stringForKey:STB_SOFTWARE_VER];
    if ([NSString isEmpty:version]) {
        version = @"V0";
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:STB_SOFTWARE_VER];
    }
    return version;
}

//默认传输类型
+ (CMD_TRANSFER_CONTENT)STBTransType
{
    CMD_TRANSFER_CONTENT transType = STB_SECTION_ALL;
    NSString *transTypeString = [[NSUserDefaults standardUserDefaults] stringForKey:STB_SOFTWARE_TYPE];
    if ([NSString isEmpty:transTypeString]) {
        transTypeString = @"STB_SECTION_ALL";
        [[NSUserDefaults standardUserDefaults] setObject:transTypeString forKey:STB_SOFTWARE_TYPE];
        [[NSUserDefaults  standardUserDefaults] synchronize];
    }
    if ([transTypeString isEqualToString:@"STB_SECTION_ALL"]) {
        transType = STB_SECTION_ALL;
    }
    else if ([transTypeString isEqualToString:@"STB_SECTION_USER"])
    {
        transType = STB_SECTION_USER;
    }
    else if([transTypeString isEqualToString:@"STB_SECTION_DB"])
    {
        transType = STB_SECTION_DB;
    }
    else
    {
        transType = STB_SECTION_ALL;
    }
    return transType;
}

+ (NSString*)STBFilePath
{
    static NSString *filePath = nil;
    if (filePath==nil) {
        filePath = [NSString cacheFolderPath];
        filePath = [filePath stringByAppendingPathComponent:LocStbFileName];
    }
    return filePath;
}

#pragma mark 提示框
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [updateAlert removeFromSuperview];
	updateAlert = nil;
}


- (void)initAlert
{
    if (updateAlert) {
        [self hudWasHidden:updateAlert];
    }
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    updateAlert = [[MBProgressHUD alloc] initWithView:window];
	[window addSubview:updateAlert];
	updateAlert.delegate = self;
}
#pragma 下载逻辑
//[Parameter]
//PROJECT_NAME=MWATCH MOBILE
//Platform=GX6601 linux
//STB_HARDWARE_VER=V1.00
//STB_SOFTWARE_VER=V2.5.0000
//IOS_MOBILE_APP_VER=V1.00
//ANDROID_MOBILE_APP_VER=V1.00
//
//[Config]
//STB_FILE_NAME=flashrom.bin
//IOS_FILE_NAME=STB.ipa
//ANDROID_FILE_NAME=AndroidTVBox_20131124_2.apk

//检查固件更新
- (void)updateVersionWithAuto:(BOOL)isAuto
{
    [self downloadConfigWithResultCallback:^(id info, FileDownState isSuccess) {
        if (isSuccess==FileDownStateSuccess) {
            NSString *STB_FILE_NAME = [info objectForKey:@"STB_FILE_NAME"];
//            NSString *STB_FILE_NAME = [info objectForKey:@"STB_FILE_NAME_DEV"];
            serverSTBVersion = [info objectForKey:STB_SOFTWARE_VER];
            NSString *transTrantype = [info objectForKey:@"STB_SOFTWARE_TYPE"];
            if (![NSString isEmpty:transTrantype]) {
                [[NSUserDefaults standardUserDefaults] setObject:transTrantype forKey:STB_SOFTWARE_TYPE];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            if (![NSString isEmpty:STB_FILE_NAME]) {
                softName = STB_FILE_NAME;
            }
            
            if (![NSString isEmpty:serverSTBVersion]) {
                NSComparisonResult verResult = [serverSTBVersion compare:[VersionUpdate STBSoftwareVersion]];
                
                if (verResult==NSOrderedDescending)
                {
                    UIAlertView *downAlert = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert")
                                                                        message:MyLocalizedString(@"Do you want to download the latest firmware")
                                                                       delegate:self
                                                              cancelButtonTitle:MyLocalizedString(@"Cancel")
                                                              otherButtonTitles:MyLocalizedString(@"OK"), nil];
                    [downAlert show];
                }
                else if(!isAuto)
                {
                    [CommonUtil showMessage:MyLocalizedString(@"Is the latest firmware")];
                }                
            }
        }
        else
        {
            if (!isAuto) {
                [CommonUtil showMessage:MyLocalizedString(@"Please connect internet")];
            }
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        [self updateSTB];
    }
}

- (void)updateSTB
{
    [self initAlert];
    updateAlert.labelText = MyLocalizedString(@"Downloading...");
    [updateAlert show:YES];
    [self downloadSoftFileWithResultCallback:^(id info, FileDownState isSuccess) {
        if (isSuccess==FileDownStateSuccess)
        {
            updateAlert.labelText = MyLocalizedString(@"Download Completed");
        }
        else
        {
            updateAlert.labelText = MyLocalizedString(@"Download Fail");
        }
        [updateAlert hide:YES afterDelay:2];
    }];
}

#pragma mark 上传逻辑
- (void)uploadFile
{
    NSString *stbFirmwarePath = [VersionUpdate STBFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:stbFirmwarePath]==NO)
    {
        [CommonUtil showMessage:MyLocalizedString(@"Connect Internet to download firmware")];
        return;
    }
    
    
    //上传
    __weak VersionUpdate *weakSelf = self;
    dispatch_block_t uploadBlock = ^{
        [weakSelf initAlert];
        updateAlert.labelText = MyLocalizedString(@"Loading...");
        [updateAlert show:YES];
        
        __weak MBProgressHUD *weakAlert = updateAlert;
        NSString *stbIP = [UPNPTool shareInstance].stbIP;
        if ([NSString isEmpty:stbIP]) {
            [SingleAlert showMessage:MyLocalizedString(@"TV box not found，please check!")];
        }
        else
        {
            NSString *filePath = [NSString cacheFolderPath];
            filePath = [filePath stringByAppendingPathComponent:LocStbFileName];
            const char *aFile = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
            
            const char *aIP = [stbIP cStringUsingEncoding:NSUTF8StringEncoding];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sendSTBFile([VersionUpdate STBTransType],aFile, aIP, ^(_UploadResultStatus aStatus) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        switch (aStatus) {
                            case CMD_RET_TRANSFER_OK:
                                weakAlert.mode = MBProgressHUDModeDeterminateHorizontalBar;
                                weakAlert.labelText = MyLocalizedString(@"Do not power off or turn off");
                                break;
                            case CMD_RET_UPDATE_SUCCESS:
                                weakAlert.labelText = MyLocalizedString(@"MWatch upgrade success");
                                [weakAlert hide:YES afterDelay:2];
                                break;
                            default:
                                weakAlert.labelText = MyLocalizedString(@"MWatch upgrade failed");
                                [weakAlert hide:YES afterDelay:2];
                                break;
                        }
                    });
                },
                            ^(int aProcessValue)
                            {
                                weakAlert.progress = aProcessValue/100.0f;
                            });
            });
        }
    };
    
    
    
    //判断
    [[ConfirmMunePassword shareInstance] confirmMunePassword:^(BOOL aResult) {
        if (aResult) {
            //获取机顶盒版本
            [CommandClient commandSystemInfo:^(id info, HTTPAccessState isSuccess) {
                if (isSuccess==HTTPAccessStateSuccess)//请求成功
                {
                    NSString *currentSTBVer = [info objectForKey:@"Application"];
                    if (![NSString isEmpty:currentSTBVer]) {
                        NSComparisonResult compareResult = [currentSTBVer compare:[VersionUpdate STBSoftwareVersion]];
                        //有最新版本
                        if (compareResult==NSOrderedAscending) {
                            
                            self.aConfirmUtil = [ConfirmUtil Util];
                            [self.aConfirmUtil showConfirmWithTitle:nil withMessage:MyLocalizedString(@"had a latest firmware,do you want to update firmware") WithOKBlcok:^{
                                if([NSString isEmpty:[UPNPTool shareInstance].stbIP])
                                {
                                    [SingleAlert showMessage:MyLocalizedString(@"TV box not found，please check!")];
                                }
                                else
                                {
                                    uploadBlock();
                                }
                            } withCancelBlock:^{
                            }];
                            
                            
                        }
                        else//无最新版本
                        {
                            [CommonUtil showMessage:@"Is the latest firmware"];
                        }
                    }
                    
                }
                else//请求不成功
                {
                    [SingleAlert showMessage:MyLocalizedString(@"TV box not found，please check!")];
                }
            }];
        }
        
    }];
    
}

#pragma mark 下载配置文件
- (void)downloadConfigWithResultCallback:(FileDownloadCallback)aCallback
{
    [DownLoadUtil downFile:configName withLocFileName:configName  withProcessBlock:^(float aProcessValue)
    {
        
    } withDownSuccessBlock:^{
        NSString *configFile = [NSString cacheFolderPath];
        configFile = [configFile stringByAppendingPathComponent:configName];
        
        NSMutableDictionary *dicConfig = [NSMutableDictionary dictionary];
        NSError *error;
        NSString *configContent = [NSString stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:&error];
        NSArray *lines = [configContent componentsSeparatedByString:@"\r\n"];
        for (NSString *temp in lines) {
            NSArray *keyValue = [temp componentsSeparatedByString:@"="];
            if (keyValue.count>1) {
                NSString *key = keyValue[0];
                NSString *value = keyValue[1];
                [dicConfig setObject:value forKey:key];
            }
        }
        INFO(@"upload config:%@",dicConfig);
        aCallback(dicConfig,FileDownStateSuccess);
    } withDownFailBlck:^{
        aCallback(nil,FileDownStateFail);
    }];
}

//下载固件
- (void)downloadSoftFileWithResultCallback:(FileDownloadCallback)aCallback
{
    updateAlert.mode = MBProgressHUDModeDeterminateHorizontalBar;
    [DownLoadUtil downFile:softName withLocFileName:LocStbFileName withProcessBlock:^(float aProcessValue)
     {
         updateAlert.progress = aProcessValue;
     } withDownSuccessBlock:^{
         [[NSUserDefaults standardUserDefaults] setObject:serverSTBVersion forKey:STB_SOFTWARE_VER];
         [[NSUserDefaults standardUserDefaults] synchronize];
         aCallback(nil,FileDownStateSuccess);
     } withDownFailBlck:^{
         aCallback(nil,FileDownStateFail);
     }];
}

@end
