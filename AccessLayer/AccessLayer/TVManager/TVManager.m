//
//  TVManager.m
//  AccessLayer
//
//  Created by shulianyong on 13-10-8.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "TVManager.h"

@implementation TVManager

- (void)commandSatellite
{
    NSDictionary *filter = @{@"satId":@123213,@"serviceType":@1,@"pageSize":@160,@"pageNo":@0};
    
    NSDictionary *parameters = @{@"command"   : @"channel_num",
                                 @"commandId" : @3,
                                 @"filter" : filter};
    [self.httpClient POST:@"" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)commandChannel
{
    NSDictionary *filter = @{@"satId":@123213,@"serviceType":@1};
    
    NSDictionary *parameters = @{@"command"   : @"channel_num",
                                 @"commandId" : @3,
                                 @"filter" : filter};
    [self.httpClient POST:@"" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

@end
