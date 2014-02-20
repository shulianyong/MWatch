//
//  BLLChannelIcon.m
//  STB
//
//  Created by shulianyong on 14-2-16.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited. All rights reserved.
//

#import "BLLChannelIcon.h"
#import "Channel.h"
#import "ChannelIcon.h"
#import "DownLoadUtil.h"
#import "CommandClient.h"

@interface BLLChannelIcon ()
{
    RefreshChannelNameIcon RefreshCallback;
}

@end

@implementation BLLChannelIcon

static NSString *ChannelIcons = @"ChannelIcons";

+ (NSDictionary*)channelIcons
{
    NSData *tempData = [[NSUserDefaults standardUserDefaults] objectForKey:ChannelIcons];
    NSDictionary *dicIcon = nil;
    if (tempData) {
        dicIcon= [NSKeyedUnarchiver unarchiveObjectWithData: tempData];
    }
    return dicIcon;
}
+ (void)setChannelIcons:(NSDictionary*)aIcons;
{
    NSData *tempData = [NSKeyedArchiver archivedDataWithRootObject:aIcons];
    [[NSUserDefaults standardUserDefaults] setObject:tempData forKey:ChannelIcons];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (instancetype)shareInstance
{
    static BLLChannelIcon *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BLLChannelIcon alloc] init];
    });
    
    return instance;
}

- (void)boundDefaultChannelIconFromChannels:(NSArray*)aChannels
{
    if (aChannels||(aChannels.count>0)) {
        
        NSDictionary *defaultIcon = [BLLChannelIcon channelIcons];
        NSMutableDictionary *currentIcons = [NSMutableDictionary dictionaryWithDictionary:defaultIcon];
        for (Channel *temp in aChannels)
        {
            ChannelIcon *iconItem = [currentIcons objectForKey:temp.name.uppercaseString];
            if (iconItem==nil)
            {
                iconItem = [[ChannelIcon alloc] init];
                iconItem.name = temp.name;
                iconItem.version = @"1.0.0";
                [currentIcons setObject:iconItem forKey:temp.name.uppercaseString];
            }
        }
        [BLLChannelIcon setChannelIcons:currentIcons];       
    }
}

//外网流程
- (void)checkChannelIconUpgrade:(RefreshChannelNameIcon)aRefreshCallback
{
    RefreshCallback = aRefreshCallback;
    __weak BLLChannelIcon *weakSelf = self;
    NSDictionary *dicIcon = [BLLChannelIcon channelIcons];
    NSArray *localIcons = [dicIcon allValues];
    [CommandClient getChannelIconInfoWithChannelIconList:localIcons withCallback:^(id info, HTTPAccessState isSuccess) {
        
        if (isSuccess==HTTPAccessStateSuccess) {
            [weakSelf downloadIconWithServerIconList:info];
        }
        
    }];
}

- (void)downloadIconWithServerIconList:(NSArray*)iconList
{
    NSString *iconUrl = nil;
    NSString *key = nil;
    for (ServerChannelIcon *iconItem in iconList) {
        key = [NSString stringWithFormat:@"%@%@",iconItem.key,PrivateKey];
        key = [NSString MD5:key];
        key = [key lowercaseString];
        iconUrl = [NSString stringWithFormat:@"%@?&key=%@",iconItem.url,key];
        
        [DownLoadUtil downServerFileWithURL:iconUrl
                               inFolderPath:[ChannelIcon iconFolder]
                            withLocFileName:[iconItem.name.uppercaseString stringByAppendingPathExtension:@"png"]
                           withProcessBlock:^(float aProcessValue) {
                               
                           } withDownSuccessBlock:^{
                               RefreshCallback(iconItem.name);
                               //设置最新icon版本号
                               NSDictionary *dicIcons = [BLLChannelIcon channelIcons];
                               ChannelIcon *localItem = [dicIcons objectForKey:iconItem.name.uppercaseString];
                               if (localItem) {
                                   localItem.version = iconItem.version;
                                   [BLLChannelIcon setChannelIcons:dicIcons];
                               }
                               
                           } withDownFailBlck:^{
                               
                           }];
    }
    
}

@end
