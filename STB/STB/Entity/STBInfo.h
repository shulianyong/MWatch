//
//  STBInfo.h
//  STB
//
//  Created by shulianyong on 14-1-17.
//  Copyright (c) 2014年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STBInfo : NSObject

@property (nonatomic,readonly) NSString *stbIP;
@property (nonatomic,readonly) NSString *stbCommandURL;
@property (nonatomic,readonly) NSString *stbPlayURL;

@property (nonatomic,assign) BOOL connected;

+ (STBInfo*)shareInstance;

@end
