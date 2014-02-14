//
//  DefaultChannelTool.h
//  STB
//
//  Created by shulianyong on 14-1-17.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"

@interface DefaultChannelTool : NSObject

@property (nonatomic,strong) NSString *defaultChannelName;
@property (nonatomic,assign) NSInteger defaultChannelId;

+ (instancetype)shareInstance;
- (void)configDefaultChannel:(Channel*)aChannel;

@end
