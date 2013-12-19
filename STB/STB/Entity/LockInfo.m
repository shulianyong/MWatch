//
//  LockInfo.m
//  STB
//
//  Created by shulianyong on 13-11-1.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "LockInfo.h"

@implementation LockInfo

+ (LockInfo*)shareInstance
{
    static LockInfo *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LockInfo alloc] init];
    });
    
    return instance;
}

@end
