//
//  CommandClient.m
//  STB
//
//  Created by shulianyong on 13-10-12.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "CommandClient.h"

#import "CommonUtil.h"

#import "LockInfo.h"
#import "WifiInfo.h"
#import "Channel.h"
#import "SignalInfo.h"
#import "SatInfo.h"
#import "TPInfo.h"

#import "UPNPTool.h"

#import "../../../CommonUtil/CommonUtil/Categories/CategoriesUtil.h"

@implementation CommandClient

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
    
    AFHTTPRequestOperation *requestOperaion = [self.httpClient POST:[self commandURL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
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
    [(NSMutableURLRequest*)requestOperaion.request setTimeoutInterval:5];
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
    NSDictionary *parameters = @{@"command": @"channel_num",@"commandId":@3};
    AFHTTPRequestOperation *operatioin = [[self httpClient] POST:[self commandURL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        aCallback(nil,HTTPAccessStateSuccess);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        aCallback(nil,HTTPAccessStateFail);
    }];
    NSMutableURLRequest* requestValue = (NSMutableURLRequest*)operatioin.request;
    [requestValue setTimeoutInterval:5];
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
    parameters[@"wifi_ap_name"] = aName;
    
    
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
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
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

#pragma mark -------------------- 搜索节目
//获取卫星列表
+ (void)commandSatList:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"sat_list";
    parameters[@"commandId"] = @1000;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        NSMutableArray *satInfoList = nil;
        HTTPAccessState accessResult = HTTPAccessStateDefault;
        if (isSuccess==HTTPAccessStateSuccess) {
            NSNumber *result = [info objectForKey:@"result"];
            if (result.integerValue==0) {
                accessResult = HTTPAccessStateSuccess;
                NSArray *satellite = [(NSDictionary*)info objectForKey:@"satellite"];
                if (satellite.count>0) {
                    satInfoList = [[NSMutableArray alloc] initWithCapacity:satellite.count];
                }
                for (NSDictionary *dicSat in satellite) {
                    SatInfo *aSatInfo = [[SatInfo alloc] init];
                    [aSatInfo reflectDataFromOtherObject:dicSat];
                    [satInfoList addObject:aSatInfo];
                }
            }
            else
            {
                accessResult = HTTPAccessStateFail;
            }
        }
        else
        {
            accessResult = HTTPAccessStateDisconnection;
        }
        aCallback(satInfoList,accessResult);
    }];
}
//添加默认卫星
+ (void)commandSatAdd:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"sat_add";
    parameters[@"commandId"] = @1001;
    parameters[@"type"]=@0;
    parameters[@"lnbOffsetLow"]=@5150;
    parameters[@"lnbOffsetHigh"]=@5750;
    parameters[@"lnbPower"]=@1;
    parameters[@"tone"]=@1;
    parameters[@"longitude"]=@10550;
    parameters[@"diseqcVersion"]=@0;
    parameters[@"commited"]=@5;
    parameters[@"uncommited"]=@0;
    parameters[@"motorPosition"]=@0;
    parameters[@"name"]=@"Mwatch_sat";
    parameters[@"tuner"]=@0;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        SatInfo *aSatInfo = nil;
        if (isSuccess==HTTPAccessStateSuccess) {
            aSatInfo = [[SatInfo alloc] init];
            [aSatInfo reflectDataFromOtherObject:info];
        }
        aCallback(aSatInfo,isSuccess);
    }];
}

//删除所有卫星
+ (void)deleteSatWithCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"sat_delete";
    parameters[@"commandId"] = @100;
    parameters[@"deleteAll"] = @1;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        aCallback(info,isSuccess);
    }];
    
}

//获取频点列表
+ (void)commandTpListWithSatId:(NSNumber*)aSatId  withCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"tp_list";
    parameters[@"commandId"] = @111;
    NSDictionary *filter = @{@"type": @0,@"satId":aSatId};
    parameters[@"filter"] = filter;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        NSMutableArray *tpList = nil;
        HTTPAccessState accessResult = HTTPAccessStateDefault;
        
        if (isSuccess==HTTPAccessStateSuccess) {
            NSArray *transponder = [info objectForKey:@"transponder"];
            NSNumber *result = [info objectForKey:@"result"];
            
            if (result.integerValue==0) {
                accessResult = HTTPAccessStateSuccess;
                if (transponder.count>0) {
                    tpList = [[NSMutableArray alloc] initWithCapacity:transponder.count];
                    for (NSDictionary *dicTP in transponder) {
                        TPInfo *aTPInfo = [[TPInfo alloc] init];
                        [aTPInfo reflectDataFromOtherObject:dicTP];
                        [tpList addObject:aTPInfo];
                    }
                }
            }
            else
            {
                accessResult = HTTPAccessStateFail;
            }
        }
        else
        {
            accessResult = HTTPAccessStateDisconnection;
        }
        aCallback(tpList,accessResult);
    }];
}
//添加频点
+ (void)commandTPAddWithSatId:(NSNumber*)aSatId withDefaultTPInfo:(TPInfo*)aTPInfo withCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"tp_add";
    parameters[@"commandId"] = @1111;
    parameters[@"type"]=@0;
    parameters[@"satId"]=aSatId;
    parameters[@"frequency"]=aTPInfo.frequency;
    parameters[@"symbolRate"]=aTPInfo.symbolRate;
    parameters[@"polarization"]=aTPInfo.polarization;
    parameters[@"modulation"]=@0;
    parameters[@"bandwidth"]=@0;
    
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        TPInfo *aTPInfo = nil;
        if (isSuccess==HTTPAccessStateSuccess) {
            if (info) {
                aTPInfo = [[TPInfo alloc] init];
                [aTPInfo reflectDataFromOtherObject:info];
            }
        }
        aCallback(aTPInfo,isSuccess);
    }];
}
//删除频点的所有的节目
+ (void)commandDeleteChannelWithSatId:(NSNumber*)aSatId withTPId:(NSNumber*)aTPId withCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"channel_delete";
    parameters[@"commandId"] = @111;
    parameters[@"deleteAll"] = @1;
//    parameters[@"filter"]=@{@"satId": aSatId,@"tpId":aTPId};
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        HTTPAccessState accessResult = HTTPAccessStateDefault;
        if (isSuccess==HTTPAccessStateSuccess) {
            NSNumber *result = [info objectForKey:@"result"];
            if (result.integerValue==0) {
                accessResult = HTTPAccessStateSuccess;
            }
            else
            {
                ERROR(@"删除频点的所有的节目失败:%@",[info objectForKey:@"error"]);
                accessResult = HTTPAccessStateFail;
            }
        }
        else
        accessResult = HTTPAccessStateDisconnection;
        aCallback(nil,accessResult);
    }];
}

//删除频点
+ (void)commandDeleteTPWithSatId:(NSNumber*)aSatId withTPId:(NSNumber*)aTPId withCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"tp_delete";
    parameters[@"commandId"] = @111;
    parameters[@"deleteAll"] = @1;
//    parameters[@"filter"]=@{@"satId": aSatId,@"tpId":@[aTPId]};
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        HTTPAccessState accessResult = HTTPAccessStateDefault;
        if (isSuccess==HTTPAccessStateSuccess) {
            NSNumber *result = [info objectForKey:@"result"];
            if (result.integerValue==0) {
                accessResult = HTTPAccessStateSuccess;
            }
            else
            {
                ERROR(@"删除频点失败:%@",[info objectForKey:@"error"]);
                accessResult = HTTPAccessStateFail;
            }
        }
        else
            accessResult = HTTPAccessStateDisconnection;
        aCallback(nil,accessResult);
    }];
}

//卫星搜索
+ (void)commandScanSatelliteWithSatId:(NSNumber*)aSatId withCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"scan_satellite";
    parameters[@"commandId"] = @3001;
    parameters[@"satId"]=@[aSatId];
    parameters[@"scanMode"]=@0;
    parameters[@"nitEnable"]=@0;
    parameters[@"scanType"]=@0;
    parameters[@"ftaOnly"]=@0;
    parameters[@"saveMode"]=@0;
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
            aCallback(nil,HTTPAccessStateDisconnection);
    }];
}

//同步机顶盒节目到机顶盒前台进行播放
+ (void)syncProgramWithCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_syn_prog_from_db";
    parameters[@"commandId"] = @3005;
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        aCallback(info,isSuccess);
    }];
}

//完成搜索
+ (void)commandScanSaveWithCallback:(HttpCallback)aCallback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"scan_save";
    parameters[@"commandId"] = @3005;
    parameters[@"options"] = @"save";
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
        aCallback(info,isSuccess);
    }];
}


#pragma mark --------一键搜索
+ (void)scanOneKeyCommandWithTPInfo:(TPInfo*)aTPInfo   withCallback:(HttpCallback)aCallback
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"command"] = @"bs_one_key_search";
    parameters[@"commandId"] = @3005;
    parameters[@"freq"] = aTPInfo.frequency;
    parameters[@"symb"] = aTPInfo.symbolRate;
    parameters[@"polar"]=aTPInfo.polarization;
    
    [self command:parameters withCallback:^(id info, HTTPAccessState isSuccess) {
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

@end
