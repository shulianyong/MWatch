//
//  DefaultChannelTool.m
//  STB
//
//  Created by shulianyong on 14-1-17.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "DefaultChannelTool.h"

static NSString *CurrentChannelName = @"CurrentChannelName";
static NSString *CurrentChannelId = @"CurrentChannelId";

@implementation DefaultChannelTool

@dynamic defaultChannelName;
@dynamic defaultChannelId;

+ (instancetype)shareInstance
{
    static DefaultChannelTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DefaultChannelTool alloc] init];
    });
    
    return instance;
}

- (void)setDefaultChannelName:(NSString *)defaultChannelName
{
    [[NSUserDefaults standardUserDefaults] setObject:defaultChannelName forKey:CurrentChannelName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)defaultChannelName
{
    NSString *defaultChannelName = [[NSUserDefaults standardUserDefaults] objectForKey:CurrentChannelName];
    return defaultChannelName;
}

- (void)setDefaultChannelId:(NSInteger)defaultChannelId
{
    [[NSUserDefaults standardUserDefaults] setInteger:defaultChannelId forKey:CurrentChannelId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)defaultChannelId
{
    NSInteger defaultChannelId = [[NSUserDefaults standardUserDefaults] integerForKey:CurrentChannelId];
    return defaultChannelId;
}


- (void)configDefaultChannel:(Channel*)aChannel
{
    self.defaultChannelId = aChannel.channelId.integerValue;
    self.defaultChannelName = aChannel.name;
}

@end
