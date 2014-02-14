//
//  STBVersionCheck.m
//  STB
//
//  Created by shulianyong on 14-2-10.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "STBVersionCheck.h"
#import "CommandClient.h"
#import "UpdateSTBInfo.h"

@implementation STBVersionCheck

- (void)checkSTBUPdateVersion
{
    [CommandClient getUpdateSTBInfo:^(id info, HTTPAccessState isSuccess) {
        [UpdateSTBInfo setCurrentUpdateSTBInfo:info];
    }];
}

@end
