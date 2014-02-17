//
//  CommandClient.m
//  STB
//
//  Created by shulianyong on 13-10-12.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "CommandClient.h"

#import "CommonUtil.h"

#import "LockInfo.h"
#import "WifiInfo.h"
#import "Channel.h"
#import "SignalInfo.h"
#import "SatInfo.h"
#import "TPInfo.h"

#import "UpdateSTBInfo.h"
#import "AppInfo.h"
#import "ServerUpdateSTBInfo.h"

#import "UPNPTool.h"

#import "../../../CommonUtil/CommonUtil/Categories/CategoriesUtil.h"

@implementation CommandClient

static NSString *STBInternetServer = @"http://rbei.aiwlan.com";

+ (NSString*)stbServer
{
    NSString *stbServer = [NSString stringWithFormat:@"http://%@:8085",[STBInfo shareInstance].stbIP];
    return stbServer;
}

+ (AFHTTPRequestOperationManager*)httpClient
{
    static AFHTTPRequestOperationManager *httpClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpClient = [AFHTTPRequestOperationManager manager] ;
        httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        httpClient.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    return httpClient;
}

//设置URL地址
+ (NSString*)commandURL
{
    NSString *commandUrl = [[self stbServer] stringByAppendingString:@"/command"];
    return commandUrl;
}

+ (void)command:(NSDictionary *)parameters withCallback:(HttpCallback)aCallback
{
    id tempParameters = parameters;
#ifdef DEBUG
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    tempParameters = jsonStr;
#endif
    INFO(@"请求parameters：%@",parameters);
    
    [self.httpClient POST:[self commandURL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSError *error = nil;
         if (responseObject!=nil) {
             
             NSDictionary *dicValue = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                      options:kNilOptions
                                                                        error:&error];
             INFO(@"Parameters:%@ \n Data: %@",tempParameters, operation.responseString);
             aCallback(dicValue,HTTPAccessStateSuccess);
         }
         
//         INFO(@"Parameters:%@ \n JSON: %@",parameters, operation.responseString);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         ERROR(@"Parameters:%@ \n Error: %@",tempParameters, error);
         aCallback(nil,HTTPAccessStateDisconnection);
     }];
    
}

+ (void)command:(NSDictionary *)parameters withTimeoutInterval:(NSTimeInterval)seconds withCallback:(HttpCallback)aCallback
{
    id tempParameters = parameters;
#ifdef DEBUG
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    tempParameters = jsonStr;
#endif
    INFO(@"请求parameters：%@",parameters);
    
    [self.httpClient POST:[self commandURL] parameters:parameters withTimeoutInterval:seconds success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSError *error = nil;
         if (responseObject!=nil) {
             
             NSDictionary *dicValue = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                      options:kNilOptions
                                                                        error:&error];
             INFO(@"Parameters:%@ \n Data: %@",tempParameters, operation.responseString);
             aCallback(dicValue,HTTPAccessStateSuccess);
         }
         
         //         INFO(@"Parameters:%@ \n JSON: %@",parameters, operation.responseString);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         ERROR(@"Parameters:%@ \n Error: %@",tempParameters, error);
         aCallback(nil,HTTPAccessStateDisconnection);
     }];
}


#pragma mark ---------------请求节目单

+ (void)commandChannelListWithCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *filter = [NSMutableDictionary dictionary];
    filter[@"satId"]=@123213;
    filter[@"tpId"]= @4567;
    filter[@"serviceType"]=@1;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"channel_list";
    parameters[@"commandId"] = @4;
    [parameters setObject:@"" forKey:@"filter"];
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        aCallback(info,isSuccess);
    }];
}

+ (void)monitorSTB:(HttpCallback)aCallback
{
    
    NSDictionary *parameters = @{@"command": @"bs_check_stb_exist",@"commandId":@3};
    
    __block NSString *tempParameters;
#ifdef DEBUG
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    tempParameters = jsonStr;
#endif
    INFO(@"请求parameters：%@",parameters);
    
    [[self httpClient] POST:[self commandURL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        aCallback(nil,HTTPAccessStateSuccess);
        INFO(@"Parameters:%@ \n Data: %@",tempParameters, operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        aCallback(nil,HTTPAccessStateFail);
        ERROR(@"Parameters:%@ \n Error: %@",tempParameters, error);
    }];
}


#pragma mark -------------------------------------
#pragma mark ------------------------------------- 设置

#pragma mark --------------------- WIFI设置
//wifi信息
+ (void)commandGetWifiInfo:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_get_wifi_ap_infor";
    parameters[@"commandId"] = @111;
    
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        id resultData = info;
        if (info) {
            WifiInfo *wifiData = [[WifiInfo alloc] init];
            [wifiData reflectDataFromOtherObject:info];
            resultData = wifiData;
        }
        aCallback(resultData,isSuccess);
    }];
}

//wifi 设置
+ (void)configWifiName:(NSString*)aName withPassword:(NSString*)aPassword withNeedPwd:(BOOL)isNeed withResult:(HttpCallback)aCallback
{
    aPassword = isNeed?aPassword:@"12345678";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_set_wifi_ap_infor";
    parameters[@"commandId"] = @3005;
    parameters[@"wifi_ap_passwd"] = aPassword;
    parameters[@"free_status"] = isNeed?@(1):@(0);
//    parameters[@"wifi_ap_name"] = aName;
    
    
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            NSNumber *result = [info objectForKey:@"result"];
            if (result.integerValue==0) {
                aCallback(nil,HTTPAccessStateSuccess);
            }
            else
            {
                aCallback(nil,HTTPAccessStateFail);
            }
        }
        else
        {
            aCallback(nil,HTTPAccessStateDisconnection);
        }
    }];
}

#pragma mark ---------------------/获取密码，机顶盒父母锁信息
+ (void)commandGetLockControl:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_get_lock_control";
    parameters[@"commandId"] = @111;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            LockInfo *aLockValue = [LockInfo shareInstance];
            [aLockValue reflectDataFromOtherObject:info];
            aCallback(aLockValue,isSuccess);
        }
        else
        {
            [CommandClient commandGetLockControl:aCallback];
        }
    }];
}

+ (void)commandParentLockWithChannels:(NSArray*)aChannels
                             withLock:(NSNumber*)isLock
                         withCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *filter = [NSMutableDictionary dictionary];
    filter[@"channelId"]=aChannels;
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"channel_lock";
    parameters[@"commandId"] = @111;
    parameters[@"filter"]=filter;
    parameters[@"state"] = isLock;
    
    
#ifdef DEBUG
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    INFO(@"json string:%@",jsonStr);
#endif
    
    
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
//        LockInfo *aLockValue = [LockInfo shareInstance];
//        [aLockValue reflectDataFromOtherObject:info];
        aCallback(nil,isSuccess);
    }];
}

#pragma mark --------------------- 主机密码更新
+ (void)commandMenuPass:(NSString*)aNewPassword
    withChannelPassword:(NSString*)aChannelPwd
           withCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_set_lock_control";
    parameters[@"commandId"] = @111;
    parameters[@"passwd"]=aNewPassword;
    parameters[@"passwd_old"]=[LockInfo shareInstance].passwd;
//    parameters[@"passwd_channel"]=aChannelPwd;
    
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        aCallback(info,isSuccess);
    }];
}

#pragma mark --------------------- Signal
+ (void)commandGetSignal:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"frontend_get_info";
    parameters[@"commandId"] = @2001;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        SignalInfo *aSignal = nil;
        if (isSuccess == HTTPAccessStateSuccess) {            
            aSignal = [[SignalInfo alloc] init];
            [aSignal reflectDataFromOtherObject:info];
        }
        aCallback(aSignal,isSuccess);
    }];
}



#pragma mark ---------------------获取ＣＡ信息
+ (void)commandGetCAInfo:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_get_ca_infor";
    parameters[@"commandId"] = @111;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
//        "Authenticate Date" = "Oct 31 2013";
//        "Valid Date" = "12 01 2020";
//        command = "bs_get_ca_infor";
//        commandId = 111;
//        error = "";
//        result = 0;        
        aCallback(info,isSuccess);
    }];
}

#pragma mark ---------------------恢复出厂设置
+ (void)commandFactoryReset:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_factory_default";
    parameters[@"commandId"] = @111;

    [self command:parameters withTimeoutInterval:15 withCallback:^(id info, HTTPAccessState isSuccess) {
        HTTPAccessState retStatus = isSuccess;
        if (isSuccess==HTTPAccessStateSuccess) {
            NSNumber *result = [info objectForKey:@"result"];
            if (result.integerValue==0) {
                retStatus = HTTPAccessStateSuccess;
            }
            else
            {
                retStatus = HTTPAccessStateFail;
            }
        }
        else
        {
            retStatus = HTTPAccessStateDisconnection;
        }
        aCallback(info,retStatus);
    }];
}

#pragma mark ---------------------信息系统

+ (void)commandSystemInfo:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_version_get";
    parameters[@"commandId"] = @111;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
//        Application = 0;
//        "Default DB" = "V1.0.0.0";
//        Lib = "V1.9-RC1";
//        Loader = "V1.9.0.0";
//        command = "bs_version_get";
//        commandId = 111;
//        error = "";
//        "release date" = 20131120;
//        result = 0;
//        "software version" = "V1.0.0";
        aCallback(info,isSuccess);
    }];
}

#pragma mark --------一键搜索
+ (void)scanOneKeyCommandWithCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_one_key_search";
    parameters[@"commandId"] = @3005;
    
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess)
    {
        aCallback(info,isSuccess);
    }];
}

#pragma mark ----------- 更新列表的监听请求
+ (void)postRefreshChannelEvent
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_notify_frush_channel";
    parameters[@"commandId"] = @3005;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
    }];
}

#pragma mark -----------更新机顶盒
+ (void)getUpdateSTBInfo:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_request_stb_info";
    parameters[@"commandId"] = @1;
    
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess)
     {
         UpdateSTBInfo *stbInfo = nil;
         if (isSuccess==HTTPAccessStateSuccess)
         {
             stbInfo = [[UpdateSTBInfo alloc] init];
             [stbInfo reflectDataFromOtherObject:info];
         }
         aCallback(stbInfo,isSuccess);
     }];
}

#pragma mark ---------------外网处理
+ (AFHTTPRequestOperationManager*)internetHTTPClient
{
    static AFHTTPRequestOperationManager *internetHTTPClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        internetHTTPClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:STBInternetServer]] ;
        internetHTTPClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        internetHTTPClient.requestSerializer = [AFHTTPRequestSerializer serializer];
    });
    INFO(@"internetHTTPClient");
    return internetHTTPClient;
}

+ (void)getInternetSTBInfo:(HttpCallback)aCallback
{
    UpdateSTBInfo *stbInfo = [UpdateSTBInfo currentUpdateSTBInfo];
    NSString *parmeters = @"type=%d&playerversion=%@&stbid[0]=%@&hwversion[0]=%@&swversion[0]=%@&caid[0]=%@&chipid[0]=%@&macid[0]=%@";
    parmeters = [NSString stringWithFormat:parmeters
                 ,2
                 ,[AppInfo AppVersion]
                 ,stbInfo.stbid
                 ,stbInfo.hwversion
                 ,stbInfo.swversion
                 ,stbInfo.caid
                 ,stbInfo.chipid
                 ,stbInfo.macid
                 ];
    
    NSString *urlString = @"download.html";
    urlString = [urlString stringByAppendingFormat:@"?%@",parmeters];
    
    INFO(@"request:%@",urlString);
    [[self internetHTTPClient] GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSError *error = nil;
        INFO(@"getInternetSTBInfo Data: %@",operation.responseString);
        NSDictionary *dicValue = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                 options:kNilOptions
                                                                   error:&error];
        INFO(@"getInternetSTBInfo Data: %@",operation.responseString);
        if (dicValue) {
            ServerUpdateSTBInfo *serverInfo = [[ServerUpdateSTBInfo alloc] init];
            NSDictionary *playerinfo = [dicValue objectForKey:@"playerinfo"];
            NSArray *stbinfo = [dicValue objectForKey:@"stbinfo"];
            serverInfo.playerversion = [playerinfo objectForKey:@"playerversion"];
            for (NSDictionary *dicTemp in stbinfo) {
                ServerSTBInfo *versionInfo = [[ServerSTBInfo alloc] init];
                [versionInfo reflectDataFromOtherObject:dicTemp];
                [serverInfo.stbinfo addObject:versionInfo];
            }
            aCallback(serverInfo,HTTPAccessStateSuccess);
        }
        else
        {
            aCallback(nil,HTTPAccessStateFail);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        ERROR(@"getInternetSTBInfo Error: %@",error);
        aCallback(nil,HTTPAccessStateDisconnection);
    }];
}

@end
