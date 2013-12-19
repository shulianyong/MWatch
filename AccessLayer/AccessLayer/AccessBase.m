//
//  AccessBase.m
//  AccessLayer
//
//  Created by shulianyong on 13-8-14.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "AccessBase.h"
#import "../../CommonUtil/CommonUtil/Categories/CategoriesUtil.h"
#import "../../CommonUtil/CommonUtil/LogUtility/SimpleLogger.h"

@implementation AccessBase

#pragma mark http access
static NSString *httpUrl=@"http://%@:8085/command";

- (AFHTTPRequestOperationManager*)httpClient
{
    static AFHTTPRequestOperationManager *httpClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:httpUrl,@"192.168.2.1"]]];
        httpClient.requestSerializer = [AFJSONRequestSerializer serializer];
    });    
    return httpClient;
}

@end
