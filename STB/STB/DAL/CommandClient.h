//
//  CommandClient.h
//  STB
//
//  Created by shulianyong on 13-10-12.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@class TPInfo;

typedef enum
{
	HTTPAccessStateDefault = 0, /**<默认 */
	HTTPAccessStateSuccess = 1, /**< 成功 */
	HTTPAccessStateFail = 2, /**< 失败 */
	HTTPAccessStateDisconnection = 3 /**< 网络联接失败 */
}
HTTPAccessState;

typedef void(^HttpCallback)(id info,HTTPAccessState isSuccess);

@interface CommandClient : NSObject

+ (NSString*)stbServer;

+ (AFHTTPRequestOperationManager*)httpClient;

+ (void)command:(NSDictionary *)parameters withCallback:(HttpCallback)aCallback;

//获取节目列表
+ (void)commandChannelListWithCallback:(HttpCallback)aCallback;

//监听
+ (void)monitorSTB:(HttpCallback)aCallback;

//wifi信息
+ (void)commandGetWifiInfo:(HttpCallback)aCallback;
//wifi 设置
+ (void)configWifiName:(NSString*)aName withPassword:(NSString*)aPassword withNeedPwd:(BOOL)isNeed withResult:(HttpCallback)aCallback;


//获取密码，机顶盒父母锁信息
+ (void)commandGetLockControl:(HttpCallback)aCallback;
+ (void)commandParentLockWithChannels:(NSArray*)aChannels  withLock:(NSNumber*)isLock withCallback:(HttpCallback)aCallback;

//主机密码更新
+ (void)commandMenuPass:(NSString*)aNewPassword withChannelPassword:(NSString*)aChannelPwd  withCallback:(HttpCallback)aCallback;
//Signal 信息质量
+ (void)commandGetSignal:(HttpCallback)aCallback;
//获取ＣＡ信息
+ (void)commandGetCAInfo:(HttpCallback)aCallback;
//恢复出厂设置
+ (void)commandFactoryReset:(HttpCallback)aCallback;
//信息系统
+ (void)commandSystemInfo:(HttpCallback)aCallback;

//搜索节目
//获取卫星列表
+ (void)commandSatList:(HttpCallback)aCallback;
//删除所有卫星
+ (void)deleteSatWithCallback:(HttpCallback)aCallback;
//添加默认卫星
+ (void)commandSatAdd:(HttpCallback)aCallback;
//获取频点列表
+ (void)commandTpListWithSatId:(NSNumber*)aSatId  withCallback:(HttpCallback)aCallback;
//添加频点
+ (void)commandTPAddWithSatId:(NSNumber*)aSatId withDefaultTPInfo:(TPInfo*)aTPInfo withCallback:(HttpCallback)aCallback;
//删除频点的所有的节目
+ (void)commandDeleteChannelWithSatId:(NSNumber*)aSatId withTPId:(NSNumber*)aTPId withCallback:(HttpCallback)aCallback;
//删除频点
+ (void)commandDeleteTPWithSatId:(NSNumber*)aSatId withTPId:(NSNumber*)aTPId withCallback:(HttpCallback)aCallback;

//卫星搜索
+ (void)commandScanSatelliteWithSatId:(NSNumber*)aSatId withCallback:(HttpCallback)aCallback;
//完成搜索
+ (void)commandScanSaveWithCallback:(HttpCallback)aCallback;
//同步机顶盒节目到机顶盒前台进行播放
+ (void)syncProgramWithCallback:(HttpCallback)aCallback;
#pragma mark --------一键搜索
+ (void)scanOneKeyCommandWithTPInfo:(TPInfo*)aTPInfo   withCallback:(HttpCallback)aCallback;
+ (void)scanOneKeyCommandWithCallback:(HttpCallback)aCallback;
#pragma mark ----------- 更新列表的监听请求
+ (void)postRefreshChannelEvent;

//更新机顶盒
+ (void)getUpdateSTBInfo:(HttpCallback)aCallback;
+ (void)getInternetSTBInfo:(HttpCallback)aCallback;

@end
