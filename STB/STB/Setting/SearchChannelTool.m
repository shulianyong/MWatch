//
//  SearchChannelTool.m
//  STB
//
//  Created by shulianyong on 13-11-23.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "SearchChannelTool.h"
#import "CommandClient.h"
#import "SatInfo.h"
#import "TPInfo.h"

@interface SearchChannelTool ()<MBProgressHUDDelegate>
{
    MBProgressHUD *searchAlert;
}

@property (strong,nonatomic) NSNumber *satId;

@end

@implementation SearchChannelTool


+ (SearchChannelTool*)shareInstance
{
    static SearchChannelTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SearchChannelTool alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(disconnectedSTB:) name:DisconnectedSTBNotification object:nil];
    });
    return instance;
}

//断开机顶盒时的消息处理
- (void)disconnectedSTB:(NSNotification*)obj
{
    [self showAccessFailWithAccessState:HTTPAccessStateFail];
}

#pragma mark ---------- 提示框

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [self.searchAlert removeFromSuperview];
	searchAlert = nil;
}

- (MBProgressHUD*)searchAlert
{
    return searchAlert;
}

- (void)initSearchAlert
{
    if (searchAlert) {
        [self hudWasHidden:searchAlert];
    }
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    searchAlert = [[MBProgressHUD alloc] initWithView:window];
	[window addSubview:self.searchAlert];
	self.searchAlert.delegate = self;
}

#pragma mark 搜索节目

- (void)searchChannel
{
    [self initSearchAlert];
	self.searchAlert.labelText = MyLocalizedString(@"Searching...");
    [self.searchAlert show:YES];
    [self scanOneKey];
}


- (void)showAccessFailWithAccessState:(HTTPAccessState)isSuccess
{
    __weak SearchChannelTool *weakSelf = self;
    NSString *errorMsg = (isSuccess==HTTPAccessStateDisconnection)?MyLocalizedString(@"Network Disconection"):MyLocalizedString(@"Search fail");
    if (weakSelf.searchAlert) {
        weakSelf.searchAlert.labelText = errorMsg;
        [weakSelf.searchAlert hide:YES afterDelay:2];
    }
}


#pragma mark --------一键搜索
- (void)scanOneKey
{
    __weak SearchChannelTool *weakSelf = self;
    __weak MBProgressHUD *alert = self.searchAlert;
    [CommandClient scanOneKeyCommandWithCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sleep(10);
                if (alert) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshChannelListNotification object:nil];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
//                    alert.labelText = MyLocalizedString(@"Completed");
                    [alert hide:YES afterDelay:3];
                    });
                }
            });          
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }
    }];
    
}

@end
