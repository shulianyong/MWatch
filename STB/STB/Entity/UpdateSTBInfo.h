//
//  UpdateSTBInfo.h
//  STB
//
//  Created by shulianyong on 14-2-9.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerUpdateSTBInfo.h"

//机顶盒的信息数据
@interface UpdateSTBInfo : NSObject<NSCoding>

@property (nonatomic,strong) NSString *hwversion;
@property (nonatomic,strong) NSString *swversion;
@property (nonatomic,strong) NSString *stbid;
@property (nonatomic,strong) NSString *caid;
@property (nonatomic,strong) NSString *chipid;
@property (nonatomic,strong) NSString *macid;

+ (instancetype)currentUpdateSTBInfo;
+ (void)setCurrentUpdateSTBInfo:(UpdateSTBInfo*)currentUpdateSTBInfo;

@end

@interface DownLoadFirmwareInfo : NSObject<NSCoding>

@property (nonatomic,strong) UpdateSTBInfo *stb;
@property (nonatomic,strong) ServerSTBInfo *serverFirmwareInfo;
@property (nonatomic,strong) NSString *firmwareName;
@property (nonatomic,strong) NSString *firmwareVersion;

+ (NSDictionary*)downLoadFirmwareInfos;
+ (void)setDownLoadFirmwareInfos:(NSDictionary*)firwares;

@end