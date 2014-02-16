//
//  BLLChannelIcon.h
//  STB
//
//  Created by shulianyong on 14-2-16.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLLChannelIcon : NSObject

+ (NSDictionary*)channelIcons;
+ (void)setChannelIcons:(NSDictionary*)aIcons;

+ (instancetype)shareInstance;

//将机顶盒的节目图，放到手机中
- (void)boundDefaultChannelIconFromChannels:(NSArray*)aChannels;

//从服务器中获取

@end
