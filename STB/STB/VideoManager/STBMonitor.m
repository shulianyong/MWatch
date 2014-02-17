//
//  STBMonitor.m
//  STB
//
//  Created by shulianyong on 13-10-23.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "STBMonitor.h"
#import "CommonUtil.h"
#import "GCDAsyncSocket.h"
#import "UPNPTool.h"
#import "LockInfo.h"

#import "ScanStatusInfo.h"
#import "SearchChannelTool.h"
#import "CommandClient.h"


//事件注册
#import "SignalTool.h"

@interface STBMonitor ()<GCDAsyncSocketDelegate>

@property (nonatomic,strong) GCDAsyncSocket *eventMonitorSocket;

@end

@implementation STBMonitor

+ (STBMonitor*)shareInstance
{
    static STBMonitor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STBMonitor alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.eventMonitorSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

#pragma mark ------搜索监听事件

- (void)searchChannelProgress:(NSNumber*)aProgress
{
    INFO(@"搜索进度:%@",aProgress);
    MBProgressHUD *searchAlert = [SearchChannelTool shareInstance].searchAlert;
    if (searchAlert==nil) {
        [[SearchChannelTool shareInstance] initSearchAlert];
        searchAlert = [SearchChannelTool shareInstance].searchAlert;
    }
    searchAlert.mode = MBProgressHUDModeDeterminateHorizontalBar;
    searchAlert.progress = aProgress.floatValue/100.f;
}

- (void)searchChannelProgress
{
    MBProgressHUD *searchAlert = [SearchChannelTool shareInstance].searchAlert;
    if (searchAlert==nil) {
        [[SearchChannelTool shareInstance] initSearchAlert];
        searchAlert = [SearchChannelTool shareInstance].searchAlert;
        searchAlert.labelText = MyLocalizedString(@"Searching...");
    }
}

//收到搜索结果的监听
- (void)searchChannelCompleted
{
    
    if ([SearchChannelTool shareInstance].searchAlert) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(3);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [SearchChannelTool shareInstance].searchAlert.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                [SearchChannelTool shareInstance].searchAlert.mode = MBProgressHUDModeCustomView;
                [SearchChannelTool shareInstance].searchAlert.labelText = MyLocalizedString(@"Completed");
                [[SearchChannelTool shareInstance].searchAlert hide:YES];
            });
        });
        
    }
}

- (void)searchChannelEvent:(ScanStatusInfo*)aStatusInfo
{
    switch (aStatusInfo.status.integerValue) {
        case 0://正常
            INFO(@"正常");
            break;
        case 1://搜索完成
            INFO(@"搜索完成");
            [self searchChannelCompleted];
            break;
        case 2://下在搜索，提示进度
            INFO(@"进度条");
            [self searchChannelProgress];
            break;
        default:
            break;
    }
}

#pragma mark 事件注册

- (void)eventMonitor
{
    if (self.eventMonitorSocket) {
        [self.eventMonitorSocket disconnect];
    }
    
    NSString *host = [STBInfo shareInstance].stbIP;

    NSError *error = nil;
    [self.eventMonitorSocket connectToHost:host onPort:8100 error:&error];
    [self.eventMonitorSocket readDataWithTimeout:-1 tag:0];
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"register_event";
    parameters[@"commandId"] = @0;
    parameters[@"event"] =  @[@"SCAN_STATUS",@"BS_POST_SIGNAL_STATE",@"BS_UPDATE_CHANNEL_LSIT",@"BS_UPDATE_LOCK_CONTROL"];
    
    NSData *commandData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];    
    [self.eventMonitorSocket writeData:commandData withTimeout:2 tag:1];
    [self.eventMonitorSocket enableBackgroundingOnSocket];
    
    if (error) {
        ERROR(@"监听联接失败:%@",error);
    }
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self.eventMonitorSocket readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.eventMonitorSocket readDataWithTimeout:-1 tag:0];
    NSString *reviceDatas = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    INFO(@"接收到的数据:%@",reviceDatas);
    
    NSArray *reviceDataArray = [reviceDatas componentsSeparatedByString:@"\n"];
    
    for (NSString *reviceData in reviceDataArray) {
        NSError *error = nil;
        if (![NSString isEmpty:reviceData]) {
            NSData *jsonData = [reviceData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dicValue = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            NSString *event = [dicValue objectForKey:@"event"];
            if ([event isEqualToString:@"BS_POST_SIGNAL_STATE"])//信息质量FRONTEND_LOCK_STATE
            {
                NSString *state = [dicValue objectForKey:@"state"];
                
                static BOOL hadProcessNoSignal = NO;//去除重复提示没信号
                if ([state isEqualToString:@"unlock"]) {
                    if (!hadProcessNoSignal) {
                        [[SignalTool shareInstance] noSignal];
//                        hadProcessNoSignal = YES;
                    }
                }
                else
                {
                    [[SignalTool shareInstance] hasSignal];
                    hadProcessNoSignal = NO;
                }
            }
            else if ([event isEqualToString:@"BS_UPDATE_LOCK_CONTROL"])//锁信息
            {
                [[LockInfo shareInstance] reflectDataFromOtherObject:dicValue];
            }
            else if ([event isEqualToString:@"SCAN_STATUS"])
            {
                ScanStatusInfo *aStatusInfo = [[ScanStatusInfo alloc] init];
                [aStatusInfo reflectDataFromOtherObject:dicValue];
                INFO(@"SCAN_STATUS event");
                [self searchChannelEvent:aStatusInfo];
            }
            else if ([event isEqualToString:@"BS_UPDATE_CHANNEL_LSIT"])//刷新列表监听
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RefreshChannelListNotification object:nil];
            }
        }
    }
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    INFO(@"发送成功:%ld",tag);
}

@end
