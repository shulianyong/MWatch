//
//  STBVersionCheck.h
//  STB
//
//  Created by shulianyong on 14-2-10.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STBVersionCheck : NSObject

+ (instancetype)shareInstance;


#pragma mark --------------------- 上传固件
- (void)autoSTBUpgrade;
- (void)manualSTBUpdate;


#pragma mark －－－－－－－－－－－－－判断是否有最新固件，最下载固件
- (void)checkInternetSTBInfo;

@end
