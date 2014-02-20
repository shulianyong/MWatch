//
//  VerifySTBConnected.m
//  STB
//
//  Created by shulianyong on 14-1-17.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "VerifySTBConnected.h"
#import "CommandClient.h"

@implementation VerifySTBConnected

+ (void)verifyConnectedWithBackDelegate:(id<VerifySTBConnectedDelegate>)aDelegate;
{
    static BOOL startVerify;
    static BOOL needSecondRequest;
    if (startVerify) {
        return;
    }
    
    startVerify = YES;
    [CommandClient monitorSTB:^(id info, HTTPAccessState isSuccess)
    {
        BOOL ret = NO;
        if (isSuccess==HTTPAccessStateSuccess) {
            ret = YES;
        }
        else
        {
            ret = NO;
        }
        
        //两次请求
        if (!ret&&!needSecondRequest) {
            needSecondRequest = YES;
            startVerify = NO;
            [self verifyConnectedWithBackDelegate:aDelegate];
            return;
        }
        
        
        BOOL oldConnected = [STBInfo shareInstance].connected;
        [STBInfo shareInstance].connected = ret;
        
        //判断是否有更改
        if (oldConnected != ret &&ret)
        {
            [aDelegate ConnectedSTBSuccess];
        }
        else if(!ret)
        {
            [aDelegate ConnectedSTBFail];
        }
        needSecondRequest = NO;
        startVerify = NO;
    }];
}

@end
