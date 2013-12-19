//
//  SearchChannelTool.m
//  STB
//
//  Created by shulianyong on 13-11-23.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
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
    });
    return instance;
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

- (void)searchChannel
{
    [self initSearchAlert];
	self.searchAlert.labelText = MyLocalizedString(@"Searching...");
    [self.searchAlert show:YES];
    
//    [self requestDeleteSat];
    [self scanOneKey];
}

#pragma mark 搜索节目
- (void)showAccessFailWithAccessState:(HTTPAccessState)isSuccess
{
    __weak SearchChannelTool *weakSelf = self;
    NSString *errorMsg = (isSuccess==HTTPAccessStateDisconnection)?MyLocalizedString(@"Network Disconection"):MyLocalizedString(@"Search fail");
    if (weakSelf.searchAlert) {
        weakSelf.searchAlert.labelText = errorMsg;
        [weakSelf.searchAlert hide:YES afterDelay:2];
    }
}

- (void)requestDeleteSat
{
    __weak SearchChannelTool *weakSelf = self;
    [CommandClient deleteSatWithCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess == HTTPAccessStateSuccess) {
            INFO(@"添加Mwatch_sat");
            [weakSelf requestSatAdd];
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }
        
        
    }];
}

//请求卫星列表
- (void)requestSatList
{
    __weak SearchChannelTool *weakSelf = self;
    [CommandClient commandSatList:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            BOOL hasMwatch = NO;
            for (SatInfo *satTemp in (NSArray*)info) {
                if ([satTemp.name isEqualToString:@"Mwatch_sat"]) {
                    hasMwatch = YES;
                    weakSelf.satId = satTemp.satId;
                    break;
                }
            }
            //如何存在Mwatch_sat，直接请求频点列表
            if (hasMwatch) {
                INFO(@"请求频点列表");
                [weakSelf requestTPlistWithSatId:weakSelf.satId];
            }
            else//不存在Mwatch_sat，则添加Mwatch_sat
            {
                INFO(@"添加Mwatch_sat");
                [weakSelf requestSatAdd];
            }
            
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }
    }];
}
//请求添加默认卫星
- (void)requestSatAdd
{
    __weak SearchChannelTool *weakSelf = self;
    [CommandClient commandSatAdd:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            SatInfo *aSatInfo = info;
            if (aSatInfo) {
                weakSelf.satId = aSatInfo.satId;
//                INFO(@"请求卫星的频点列表 satId:%@",weakSelf.satId);
//                [weakSelf requestTPlistWithSatId:weakSelf.satId];
                INFO(@"添加默认频点信息");
                [weakSelf requestAddTP];
            }
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }
    }];
}
//获取频点列表
- (void)requestTPlistWithSatId:(NSNumber*)aSatId
{
    __weak SearchChannelTool *weakSelf = self;
    [CommandClient commandTpListWithSatId:aSatId withCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            BOOL hasTP = NO;
            TPInfo *defaultTPInfo = nil;//默认频点
            
            for (TPInfo *tempTP in (NSArray*)info) {
                if (tempTP.frequency.integerValue==self.defaultTPInfo.frequency.integerValue
                    && tempTP.symbolRate.integerValue==self.defaultTPInfo.symbolRate.integerValue
                    && tempTP.polarization.integerValue==self.defaultTPInfo.polarization.integerValue)
                {
                    hasTP=YES;
                    defaultTPInfo = tempTP;
                    break;
                }
            }
            if (hasTP)//存在默认频点，删除该频点的所有节目
            {
                INFO(@"开始搜索命令请求");
                [weakSelf scanSatellite];
//                INFO(@"删除该频点 tpID:%@",defaultTPInfo.tpId);
//                [weakSelf requestDeleteTPWithTPId:defaultTPInfo.tpId];
            }
            else//不存在默认频，则添加默认频点信息
            {
                INFO(@"添加默认频点信息");
                [weakSelf requestAddTP];
            }
            
            
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }
    }];
}

//添加默认频点
- (void)requestAddTP
{
    __weak SearchChannelTool *weakSelf = self;
    [CommandClient commandTPAddWithSatId:self.satId withDefaultTPInfo:self.defaultTPInfo withCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            INFO(@"开始搜索命令请求");
            [weakSelf scanSatellite];
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }
    }];
}

//删除频点
- (void)requestDeleteTPWithTPId:(NSNumber*)aTPId
{
    __weak SearchChannelTool *weakSelf = self;
    [CommandClient commandDeleteTPWithSatId:self.satId withTPId:aTPId withCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            INFO(@"添加默认频点信息");
            [weakSelf requestAddTP];
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }

    }];
};

//删除该频点的所有节目
- (void)requestDeleteChannelWithTPId:(NSNumber*)aTPId
{
//    [self scanSatellite];
//    return;
    __weak SearchChannelTool *weakSelf = self;
    if (aTPId.integerValue>0) {
        [CommandClient commandDeleteChannelWithSatId:self.satId withTPId:aTPId withCallback:^(id info, HTTPAccessState isSuccess) {
            if (isSuccess==HTTPAccessStateSuccess) {
                INFO(@"开始搜索命令请求");
                [weakSelf scanSatellite];
            }
            else
            {
                [weakSelf showAccessFailWithAccessState:isSuccess];
            }
        }];
    }
}

//开始卫星搜索
- (void)scanSatellite
{
    __weak SearchChannelTool *weakSelf = self;
    [CommandClient commandScanSatelliteWithSatId:self.satId withCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            INFO(@"开始搜索");
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }
    }];
}

//完成搜索
- (void)scanSave
{
    __weak SearchChannelTool *weakSelf = self;
    [CommandClient commandScanSaveWithCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            INFO(@"完成搜索");
        }
        else
        {
            [weakSelf showAccessFailWithAccessState:isSuccess];
        }
    }];
}

#pragma mark --------一键搜索
- (void)scanOneKey
{
    __weak SearchChannelTool *weakSelf = self;
    __weak MBProgressHUD *alert = self.searchAlert;
    [CommandClient scanOneKeyCommandWithTPInfo:self.defaultTPInfo withCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sleep(5);
                if (alert) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshChannelListNotification object:nil];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                    alert.labelText = MyLocalizedString(@"Completed");
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
