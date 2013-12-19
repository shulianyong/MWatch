//
//  UPNPTool.m
//  STB
//
//  Created by shulianyong on 13-10-30.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "UPNPTool.h"
#import "UPnPManager.h"

@interface UPNPTool () <UPnPDBObserver>
{
    NSString *newSTBIP;
    BOOL isSearching;
    BOOL hasSearched;
}

@property (nonatomic,strong) NSArray *upnpDevices;
@property (nonatomic,strong) NSTimer *outTime;
@property (nonatomic) UIBackgroundTaskIdentifier taskID;

@end

@implementation UPNPTool

+ (UPNPTool*)shareInstance
{
    static UPNPTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UPNPTool alloc] init];
    });
    
    return instance;
}

#pragma mark －－－－－－－－－－－－－扫描机顶盒

- (void)searchIP
{
    //初始化值
    newSTBIP = nil;
    if (isSearching) {
        return;
    }
    isSearching = YES;
    if (self.taskID!=UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.taskID];
        self.taskID = UIBackgroundTaskInvalid;
    }
    
    
    __weak UPNPTool *weakSelf = self;
    self.taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:weakSelf.taskID];
        weakSelf.taskID = UIBackgroundTaskInvalid;
    }];
    
    UPnPDB *db = [[UPnPManager GetInstance] DB];
    [db stop];
    [UPnPManager shutdown];
    
    db = [[UPnPManager GetInstance] DB];
    [db removeObserver:(UPnPDBObserver*)self];
    [db addObserver:(UPnPDBObserver*)self];
    self.upnpDevices = [db rootDevices];
    
    //超时处理
    if (self.outTime) {
        [self.outTime invalidate];
    }
    self.outTime = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.outTime forMode:NSDefaultRunLoopMode];
    
    //Optional; set User Agent
    [[[UPnPManager GetInstance] SSDP] setUserAgentProduct:@"MWatch/1.0" andOS:@"iOS"];
    //Search for UPnP Devices
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
}


- (BOOL)isSearching
{
    return isSearching;
}

- (void)timeout:(NSTimer*)sender
{
    if ([sender isValid] && newSTBIP==nil) {
        ERROR(@"没有获得机顶盒IP,upnp超时");
        stbIP = nil;
        [self.toolDelegate upnpToolFail:self];
        isSearching = NO;
//        [UPnPManager shutdown];
    }
}


#pragma mark 外部防问属性
- (NSString*)stbIP
{
    return stbIP;
}

- (BOOL)changedIP
{
    return changedIP;
}

#pragma mark protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender{
    NSLog(@"UPnPDBWillUpdate %d", [self.upnpDevices count]);
    isSearching = NO;
    hasSearched = NO;
}

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    NSLog(@"UPnPDBUpdated %d", [self.upnpDevices count]);
    for (BasicUPnPDevice *device in self.upnpDevices) {
        //
        INFO(@"Device:%@  xml:%@  friendlyName:%@",device.baseURL,device.xmlLocation,device.friendlyName);
        if (hasSearched ==NO && [device.friendlyName isEqualToString:@"gbox"]) {
            hasSearched = YES;
            INFO(@"gbox Device:%@   xml:%@",device.baseURL,device.xmlLocation);
            
            newSTBIP = device.baseURL.host;
            changedIP = NO;
            if (stbIP==nil || ![stbIP isEqualToString:newSTBIP]) {
                changedIP = YES;
            }
            stbIP = newSTBIP;
           
//            __weak UPNPTool *weakSelf = self;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [UPnPManager shutdown];
//                if (self.taskID!=UIBackgroundTaskInvalid) {
//                    [[UIApplication sharedApplication] endBackgroundTask:weakSelf.taskID];
//                    weakSelf.taskID = UIBackgroundTaskInvalid;
//                }
//            });
            
            [self.toolDelegate upnpTool:self endSearchIP:stbIP];
            break;
        }
    }
    isSearching = NO;
}

@end
