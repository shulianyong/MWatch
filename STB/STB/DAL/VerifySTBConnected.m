//
//  VerifySTBConnected.m
//  STB
//
//  Created by shulianyong on 14-1-17.
//  Copyright (c) 2014年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "VerifySTBConnected.h"
#import "CommandClient.h"

@implementation VerifySTBConnected

+ (void)verifyConnectedWithBackDelegate:(id<VerifySTBConnectedDelegate>)aDelegate;
{
    static BOOL startVerify;
    if (startVerify) {
        return;
    }
    
    startVerify = YES;
    [CommandClient monitorSTB:^(id info, HTTPAccessState isSuccess) {
        BOOL ret = NO;
        if (isSuccess==HTTPAccessStateSuccess) {
            ret = YES;
        }
        else
        {
            ret = NO;
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
        
        startVerify = NO;
    }];
}

@end