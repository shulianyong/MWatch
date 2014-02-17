//
//  SearchChannelTool.h
//  STB
//
//  Created by shulianyong on 13-11-23.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "TPInfo.h"
@interface SearchChannelTool : NSObject

@property (readonly,nonatomic) MBProgressHUD *searchAlert;
@property (nonatomic,strong) TPInfo *defaultTPInfo;

- (void)initSearchAlert;

+ (SearchChannelTool*)shareInstance;

- (void)searchChannel;

@end
