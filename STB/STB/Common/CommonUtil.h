//
//  CommonUtil.h
//  STB
//
//  Created by shulianyong on 13-10-14.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *CurrentChannel = @"CurrentChannel";

@interface CommonUtil : NSObject

+ (void)setChannelCount:(NSInteger)aCount;
+ (NSInteger)channelCount;

+ (void)changeCurrentChannel:(NSInteger)channelIndex;
+ (NSInteger)currentChannel;

//+ (NSString*)serverIP;

//提示
+ (void)showMessage:(NSString*)aMessgae;
//提示
+ (void)showMessage:(NSString*)aMessgae withCannelBlock:(dispatch_block_t)aBlock;

@end


