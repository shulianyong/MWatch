//
//  AppInfo.m
//  STB
//
//  Created by shulianyong on 14-2-9.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "AppInfo.h"

@implementation AppInfo

+ (NSString*)AppVersion
{
    static NSString *appVersion = nil;
    if (appVersion==nil) {
        appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    }
    return appVersion;
}

@end
