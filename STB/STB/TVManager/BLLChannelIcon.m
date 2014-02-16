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

@implementation BLLChannelIcon

static NSString *ChannelIcons = @"ChannelIcons";

+ (NSDictionary*)channelIcons
{
    NSData *tempData = [[NSUserDefaults standardUserDefaults] objectForKey:ChannelIcons];
    NSDictionary *dicIcon= [NSKeyedUnarchiver unarchiveObjectWithData: tempData];
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
            ChannelIcon *iconItem = [currentIcons objectForKey:temp.name];
            if (iconItem==nil)
            {
                iconItem = [[ChannelIcon alloc] init];
                iconItem.name = temp.name;
                iconItem.version = @"1.0.0";
                [currentIcons setObject:iconItem forKey:temp.name];
            }
        }
        [BLLChannelIcon setChannelIcons:currentIcons];
        
    }
}

@end
