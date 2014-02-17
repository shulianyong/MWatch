//
//  STBVersionCheck.h
//  STB
//
//  Created by shulianyong on 14-2-10.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *STB_SOFTWARE_VER = @"STB_APPLICATION_VER";//@"STB_APPLICATION_DEV_VER";
static NSString *STB_RemindUpgrade = @"STB_RemindUpgrade";
static NSString *STB_SOFTWARE_TYPE = @"STB_SOFTWARE_TYPE";
@interface STBVersionCheck : NSObject

+ (instancetype)shareInstance;

+ (BOOL)IsSTBRemindUpgrade;
#pragma mark --------------------- 上传固件
- (void)autoSTBUpgrade;
- (void)manualSTBUpdate;


#pragma mark －－－－－－－－－－－－－判断是否有最新固件，最下载固件
- (void)checkInternetSTBInfo;

@end
