//
//  DSTBSystemInfo.m
//  STB
//
//  Created by shulianyong on 14-1-22.
//  Copyright (c) 2014年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "DSTBSystemInfo.h"
#import "CommandClient.h"
#import "STBSystemInfo.h"

@implementation DSTBSystemInfo

+ (void)InitSTBSystemInfoFromSTB
{
    [CommandClient commandSystemInfo:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            STBSystemInfo *currentSystemInfo = [[STBSystemInfo alloc] init];
            [currentSystemInfo reflectDataFromOtherObject:info];
            [STBSystemInfo setDefaultSystemInfo:currentSystemInfo];
        }
        else
        {
            [self InitSTBSystemInfoFromSTB];
        }
        
    }];
}

@end
