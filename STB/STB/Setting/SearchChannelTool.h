//
//  SearchChannelTool.h
//  STB
//
//  Created by shulianyong on 13-11-23.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
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
//完成搜索
- (void)scanSave;

@end
