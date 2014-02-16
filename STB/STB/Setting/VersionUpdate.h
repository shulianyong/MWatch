//
//  VersionUpdate.h
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownLoadUtil.h"

static NSString *STB_SOFTWARE_VER = @"STB_APPLICATION_VER";//@"STB_APPLICATION_DEV_VER";
static NSString *STB_RemindUpgrade = @"STB_RemindUpgrade";
static NSString *STB_SOFTWARE_TYPE = @"STB_SOFTWARE_TYPE";


@interface VersionUpdate : NSObject

+ (VersionUpdate*)shareInstance;
+ (NSString*)STBSoftwareVersion;
+ (BOOL)IsSTBRemindUpgrade;

- (void)updateVersionWithAuto:(BOOL)isAuto;
- (void)uploadFile;



@end
