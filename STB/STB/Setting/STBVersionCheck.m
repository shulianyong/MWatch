//
//  STBVersionCheck.m
//  STB
//
//  Created by shulianyong on 14-2-10.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "STBVersionCheck.h"
#import "CommandClient.h"
#import "UpdateSTBInfo.h"
#import "ServerUpdateSTBInfo.h"
#import "DownLoadUtil.h"
#import "MBProgressHUD.h"
#import "CommonUtil.h"
#import "ConfirmUtil.h"
#import "AppInfo.h"

@interface STBVersionCheck ()<MBProgressHUDDelegate>
{
    MBProgressHUD *updateAlert;
}

@property (nonatomic,readonly) MBProgressHUD *updateAlert;
@property (nonatomic,readonly) ConfirmUtil *aConfirmUtil;

@end

@implementation STBVersionCheck

+ (instancetype)shareInstance
{
    static STBVersionCheck *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STBVersionCheck alloc] init];
    });
    
    return instance;
}

+ (BOOL)IsSTBRemindUpgrade
{
    
    NSNumber *isRemind = [[NSUserDefaults standardUserDefaults] objectForKey:STB_RemindUpgrade];
    if (isRemind==nil) {
        isRemind = [NSNumber numberWithBool:YES];
    }
    return isRemind.boolValue;
}

#pragma mark ---------------提示框

- (ConfirmUtil*)aConfirmUtil
{
    static ConfirmUtil *aConfirmUtil= nil;
    if (aConfirmUtil==nil) {
        aConfirmUtil = [ConfirmUtil Util];
    }
    return aConfirmUtil;
}

- (MBProgressHUD*)updateAlert
{
    return updateAlert;
}

#pragma mark 提示框
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [updateAlert removeFromSuperview];
	updateAlert = nil;
}


- (void)initProgress
{
    if (updateAlert) {
        [self hudWasHidden:updateAlert];
    }
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    updateAlert = [[MBProgressHUD alloc] initWithView:window];
	[window addSubview:updateAlert];
	updateAlert.delegate = self;
}


#pragma mark ---------------- 版本判断

//检查固件类型
- (BOOL)checkDeviceFromSHWVersion:(NSString*)aSHWVersioin
{
    BOOL result = NO;
    
    NSString *stbHWV = [UpdateSTBInfo currentUpdateSTBInfo].hwversion;
    if ([stbHWV length]!=[aSHWVersioin length]) {
        return result;
    }
    
    
	for (int i = 0; i < [aSHWVersioin length]; ++i) {
		NSString *sCharacter = [aSHWVersioin substringWithRange:NSMakeRange(i, 1)];
        NSString *stbCharacter = [stbHWV substringWithRange:NSMakeRange(i, 1)];
        uint sValue = [NSString convertHexString:sCharacter];
        uint stbValue = [NSString convertHexString:stbCharacter];
		if ((stbValue&sValue)==stbValue)
        {
            result = YES;
		}
        else
        {
            result = NO;
            break;
        }
	}
    
    return result;
}

//检查版本号
- (BOOL)checkVersionFromSVersion:(NSString*)aSVersion
{
    BOOL result = NO;
    
    NSString *stbAllVersion = [UpdateSTBInfo currentUpdateSTBInfo].swversion;
    //判断高七位相等
    NSString *insernetSevenVersion = [aSVersion substringToIndex:7];
    NSString *stbSevenVersion = [stbAllVersion substringToIndex:7];
//    UInt64 insernetSevenVersionValue = [NSString convertHexStringToLongLong:insernetSevenVersion];
//    UInt64 stbSevenVersionValue = [NSString convertHexStringToLongLong:stbSevenVersion];
    if (![insernetSevenVersion isEqualToString:stbSevenVersion])//不相等，直接返回
    {
        return result;
    }
    //判断服务器版本号，大于机顶盒版本号
    NSString *internetLastVersion = [aSVersion substringFromIndex:7];
    NSString *stbLastVersion = [stbAllVersion substringFromIndex:7];
    
    UInt32 internetLastVersionValue = [NSString convertHexString:internetLastVersion];
    UInt32 stbLastVersionValue = [NSString convertHexString:stbLastVersion];
    if (internetLastVersionValue>stbLastVersionValue) {
        result=YES;
    }
    
    
    return result;
}


//判断机顶盒序号升级范围
- (BOOL)checkSTBIDFrom:(NSString*)afrom stbIDTo:(NSString*)aTo
{
    BOOL result = NO;
    //判断机顶盒序号升级范围
    NSString *stbID = [UpdateSTBInfo currentUpdateSTBInfo].stbid;
    
    NSComparisonResult fromResult = [stbID compare:afrom];
    NSComparisonResult toResult = [stbID compare:aTo];
    
    
    if((fromResult==NSOrderedDescending|| fromResult==NSOrderedSame) && (toResult==NSOrderedAscending || toResult==NSOrderedSame) )
    {
        result = YES;
    }
    
    return result;
}

#pragma mark ---------------- 上传逻辑

#pragma mark ---------------- 获取机顶盒版本信息（用于更新的）
typedef void(^STBUPdateVersionCallback)(bool isUpdate);

- (void)autoSTBUpgrade
{
    [self checkSTBUPdateVersion:^(bool isUpdate) {
        
    }];
}

- (void)manualSTBUpdate
{
    [self checkSTBUPdateVersion:^(bool isUpdate) {
        if (!isUpdate)
        {
            [CommonUtil showMessage:MyLocalizedString(@"Is the latest firmware")];
        }
    }];
}


- (void)checkSTBUPdateVersion:(STBUPdateVersionCallback)aCallback
{
    __weak STBVersionCheck *weakSelf = self;
    [CommandClient getUpdateSTBInfo:^(id info, HTTPAccessState isSuccess)
    {
        if (isSuccess==HTTPAccessStateSuccess)
        {
            [UpdateSTBInfo setCurrentUpdateSTBInfo:info];
            if ([weakSelf compareSTBUpgrade])
            {
                aCallback(YES);
                [weakSelf.aConfirmUtil showConfirmWithTitle:nil withMessage:MyLocalizedString(@"had a latest firmware,do you want to update firmware") WithOKBlcok:^{
                     [[NSNotificationCenter defaultCenter] postNotificationName:PauseNotification object:nil];
                    [weakSelf uploadFirmware];
                } withCancelBlock:^{
                }];
            }
            else
            {
                aCallback(NO);
            }
        }
    }];
}

- (BOOL)compareSTBUpgrade
{
    BOOL result = NO;
    UpdateSTBInfo *currentSTB = [UpdateSTBInfo currentUpdateSTBInfo];
    
    NSDictionary *dicDownloadFirmwareInfo = [DownLoadFirmwareInfo downLoadFirmwareInfos];
    if (dicDownloadFirmwareInfo)
    {
        DownLoadFirmwareInfo *aServerSTBInfo = [dicDownloadFirmwareInfo objectForKey:currentSTB.hwversion];
        if (aServerSTBInfo)
        {
            BOOL sameDevice = [self checkDeviceFromSHWVersion:aServerSTBInfo.serverFirmwareInfo.hwversion];
            if (sameDevice)//判断同一种设备
            {
                result = YES;
            }
            BOOL versionUpdated = [self checkVersionFromSVersion:aServerSTBInfo.serverFirmwareInfo.swversion];
            result = (result&&versionUpdated);//判断，是否有最新版本
            
            BOOL stbIDCompare = [self checkSTBIDFrom:aServerSTBInfo.serverFirmwareInfo.stbidstart stbIDTo:aServerSTBInfo.serverFirmwareInfo.stbidend];
            result= (result&&stbIDCompare);//判断机顶盒序号是否在升级范围内
        }
    }
    return result;
}

- (void)uploadFirmware
{
    NSDictionary *dicDownloadFirmwareInfo = [DownLoadFirmwareInfo downLoadFirmwareInfos];
    UpdateSTBInfo *currentSTB = [UpdateSTBInfo currentUpdateSTBInfo];
    DownLoadFirmwareInfo *aServerSTBInfo = [dicDownloadFirmwareInfo objectForKey:currentSTB.hwversion];
    
    
    NSString *filePath = [NSString cacheFolderPath];
    filePath = [filePath stringByAppendingPathComponent:aServerSTBInfo.firmwareName];
    const char *aFile = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
    const char *aIP = [[STBInfo shareInstance].stbIP cStringUsingEncoding:NSUTF8StringEncoding];
    
    __weak STBVersionCheck *weakSelf = self;
    [self initProgress];
    self.updateAlert.labelText = MyLocalizedString(@"Loading...");
    [self.updateAlert show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sendSTBFile(STB_SECTION_ALL,aFile, aIP, ^(_UploadResultStatus aStatus) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                switch (aStatus) {
                    case CMD_RET_TRANSFER_OK:
                        weakSelf.updateAlert.mode = MBProgressHUDModeDeterminateHorizontalBar;
                        weakSelf.updateAlert.labelText = MyLocalizedString(@"Do not power off or turn off");
                        break;
                    case CMD_RET_UPDATE_SUCCESS:
                        weakSelf.updateAlert.labelText = MyLocalizedString(@"MWatch upgrade success");
                        [weakSelf.updateAlert hide:YES afterDelay:2];
                        break;
                    default:
                        weakSelf.updateAlert.labelText = MyLocalizedString(@"MWatch upgrade failed");
                        [weakSelf.updateAlert hide:YES afterDelay:2];
                        break;
                }
            });
        },
                    ^(int aProcessValue)
                    {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                        weakSelf.updateAlert.progress = aProcessValue/100.0f;
                        });
                    });
    });
}

#pragma mark ---------------- 下载逻辑

//判断服务器是否有最新固件
- (BOOL)hasUpdateFirmwareFromServerUpdateSTBInfo:(ServerUpdateSTBInfo*)aInfo
{
    BOOL result = YES;
    
    UpdateSTBInfo *stbInfo = [UpdateSTBInfo currentUpdateSTBInfo];
    NSDictionary *dicDownloadFirmwareInfo = [DownLoadFirmwareInfo downLoadFirmwareInfos];
    if (dicDownloadFirmwareInfo&&aInfo&&aInfo.stbinfo.count>0)
    {
        DownLoadFirmwareInfo *localServerSTBInfo = [dicDownloadFirmwareInfo objectForKey:stbInfo.hwversion];
        ServerSTBInfo *currentServerInfo = aInfo.stbinfo[0];
        if (localServerSTBInfo&&currentServerInfo) {
            ServerSTBInfo *localServerFirmwareInfo = localServerSTBInfo.serverFirmwareInfo;
            
            if (localServerFirmwareInfo)
            {
                result = !([localServerFirmwareInfo.hwversion isEqualToString:currentServerInfo.hwversion]
                           && [localServerFirmwareInfo.swversion isEqualToString:currentServerInfo.swversion]
                           && [localServerSTBInfo.stb.stbid isEqualToString:stbInfo.stbid]);
            }
            
        }
        else if (currentServerInfo==nil)
            result = NO;
    }
    return result;
}

#pragma mark －－－－－－－－－－－－－从服务器，判断是否有最新固件，下载固件，总控制
- (void)checkInternetSTBInfo
{
    __weak STBVersionCheck *weakSelf = self;
    
    UpdateSTBInfo *stbInfo = [UpdateSTBInfo currentUpdateSTBInfo];
    if (stbInfo==nil) {
        return;
    }
    [CommandClient getInternetSTBInfo:^(ServerUpdateSTBInfo *info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess)
        {
            //固件下载
            if (info.stbinfo.count>0 && [self hasUpdateFirmwareFromServerUpdateSTBInfo:info]&&[STBVersionCheck IsSTBRemindUpgrade])//检查固件
            {
                [weakSelf.aConfirmUtil showConfirmWithTitle:MyLocalizedString(@"Alert")
                                             withMessage:MyLocalizedString(@"Do you want to download the latest firmware")
                                             WithOKBlcok:^{
                                                 [weakSelf initProgress];
                                                 [weakSelf.updateAlert show:YES];
                                                 
                                                 ServerSTBInfo *aServerSTBInfo = info.stbinfo[0];
                                                 
                                                 weakSelf.updateAlert.labelText = MyLocalizedString(@"Downloading...");
                                                 //固件下载
                                                 [weakSelf checkSTBFirmwareDownloadURLWithInfo:aServerSTBInfo];
                                             } withCancelBlock:^{
                                                 
                                             }];
                
                
            }
            
            //app下载
            if (![NSString isEmpty:info.playerversion]) {
                [self checkAppVersion:info.playerversion];
            }
            
        }
        
    }];
}


//固件下载流程控制
- (void)checkSTBFirmwareDownloadURLWithInfo:(ServerSTBInfo*)aInfo
{
    __weak STBVersionCheck *weakSelf = self;
    [self downloadFirmwareWithServerSTBInfo:aInfo WithCallBack:^(id info, FileDownState isSuccess) {
        if (isSuccess==FileDownStateSuccess) {
            weakSelf.updateAlert.labelText = MyLocalizedString(@"Download Completed");
        }
        else
        {
            weakSelf.updateAlert.labelText = MyLocalizedString(@"Download Fail");
        }
        [weakSelf.updateAlert hide:YES afterDelay:2];
    }];
}

//下载固件
- (void)downloadFirmwareWithServerSTBInfo:(ServerSTBInfo*)aInfo   WithCallBack:(FileDownloadCallback)aCallback
{
    NSString *key = [NSString stringWithFormat:@"%@%@",aInfo.key,PrivateKey];
    key = [NSString MD5:key];
    key = [key lowercaseString];
    NSString *url = [aInfo.url stringByAppendingFormat:@"?&key=%@",key];
    NSString *firmwareName = [[UpdateSTBInfo currentUpdateSTBInfo].hwversion stringByAppendingPathExtension:@"bin"];
    
    updateAlert.mode = MBProgressHUDModeDeterminateHorizontalBar;
    __weak STBVersionCheck *weakSelf = self;
    [DownLoadUtil downFirmwareFileWithURL:url withLocFileName:firmwareName withProcessBlock:^(float aProcessValue) {
        weakSelf.updateAlert.progress = aProcessValue;
    } withDownSuccessBlock:^{
        [weakSelf successDownloadFirmwareForName:firmwareName withServerInfo:aInfo];
        aCallback(nil,FileDownStateSuccess);
        
    } withDownFailBlck:^{
        aCallback(nil,FileDownStateFail);
    }];
}

//下载成功
- (void)successDownloadFirmwareForName:(NSString*)firmwareName withServerInfo:(ServerSTBInfo*)aInfo
{
    [self limitDownloadFirmware];//限制手机内下载的固件个数
    NSDictionary *tempArray = [DownLoadFirmwareInfo downLoadFirmwareInfos];
    NSMutableDictionary *downloadVersionArrayInfo = nil;
    if (tempArray) {
        downloadVersionArrayInfo = [[NSMutableDictionary alloc] initWithDictionary:tempArray];
    }
    else
    {
        downloadVersionArrayInfo = [[NSMutableDictionary alloc] init];
    }
    
    DownLoadFirmwareInfo *firmwareInfo = [[DownLoadFirmwareInfo alloc] init];
    firmwareInfo.firmwareName = firmwareName;
    firmwareInfo.firmwareVersion = aInfo.swversion;
    firmwareInfo.stb = [UpdateSTBInfo currentUpdateSTBInfo];
    firmwareInfo.serverFirmwareInfo = aInfo;
    [downloadVersionArrayInfo setObject:firmwareInfo forKey:[UpdateSTBInfo currentUpdateSTBInfo].hwversion];
    
    [DownLoadFirmwareInfo setDownLoadFirmwareInfos:downloadVersionArrayInfo];
}

//限制，最多下载6个固件
- (void)limitDownloadFirmware
{
    NSDictionary *tempArray = [DownLoadFirmwareInfo downLoadFirmwareInfos];
    if (tempArray&&tempArray.allValues.count==5) {
         NSMutableDictionary *dicFirmwares = [[NSMutableDictionary alloc] initWithDictionary:tempArray];
        NSString *firstKey = dicFirmwares.allKeys[0];
        
        
        DownLoadFirmwareInfo *firstValue = [dicFirmwares objectForKey:firstKey];
        NSString *saveFilePath = [NSString cacheFolderPath];
        saveFilePath = [saveFilePath stringByAppendingPathComponent:firstValue.firmwareName];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:saveFilePath])
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:saveFilePath error:&error];
            if (error) {
                ERROR(@"删除手机下载的固件失败：%@",error);
            }
        }
        
        [dicFirmwares removeObjectForKey:firstKey];
        [DownLoadFirmwareInfo setDownLoadFirmwareInfos:dicFirmwares];
    }
}

#pragma mark -------------------更改APP
- (void)checkAppVersion:(NSString*)aVersion
{
    static ConfirmUtil *appUpgradeConfimUtil=nil;
    if (appUpgradeConfimUtil==nil) {
        appUpgradeConfimUtil = [ConfirmUtil createInstance];
    }
    
    NSComparisonResult result =  [[AppInfo AppVersion] compare:aVersion];
    if (result==NSOrderedAscending)
    {
        [appUpgradeConfimUtil showConfirmWithTitle:MyLocalizedString(@"Alert")
                                       withMessage:MyLocalizedString(@"Download the latest APP?")
                                       WithOKBlcok:^{
                                           NSString *storeURLString = @"https://itunes.apple.com/cn/app/msight/id799326403?mt=8";
                                           NSURL *storeURL = [NSURL URLWithString:storeURLString];
                                           [[UIApplication sharedApplication] openURL:storeURL];
                                       }
                                   withCancelBlock:^{
                                       
                                   }];
        
    }
}

@end
