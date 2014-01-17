//
//  STBInfo.m
//  STB
//
//  Created by shulianyong on 14-1-17.
//  Copyright (c) 2014年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "STBInfo.h"

@implementation STBInfo

+ (STBInfo*)shareInstance
{
    static STBInfo *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STBInfo alloc] init];
    });
    return instance;
}

- (NSString*)stbIP
{
    static NSString *stbIP = @"192.168.0.1";
    return stbIP;
}

- (NSString*)stbCommandURL
{
    static NSString *commandURL =  nil;
    static dispatch_once_t onceToken;
    __block STBInfo *weakSelf = self;
    dispatch_once(&onceToken, ^{
        commandURL = [NSString stringWithFormat:@"http://%@:8085",weakSelf.stbIP];
    });
    return commandURL;
}

- (NSString*)stbPlayURL
{
    static NSString *stbPlayURL =  nil;
    static dispatch_once_t onceToken;
    __block STBInfo *weakSelf = self;
    dispatch_once(&onceToken, ^{
        stbPlayURL = [NSString stringWithFormat:@"http://%@:8085/player.",weakSelf.stbIP];
    });
    return stbPlayURL;
}

@end
