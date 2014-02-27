//
//  UpdateSTBInfo.m
//  STB
//
//  Created by shulianyong on 14-2-9.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "UpdateSTBInfo.h"

@implementation UpdateSTBInfo

static NSString *CurrentUpdateSTBInfo=@"CurrentUpdateSTBInfo";

+ (instancetype)currentUpdateSTBInfo
{
    NSData *tempData =  [[NSUserDefaults standardUserDefaults] objectForKey:CurrentUpdateSTBInfo];
    UpdateSTBInfo *currentUpdateSTBInfo = nil;
    if (tempData) {
        currentUpdateSTBInfo = [NSKeyedUnarchiver unarchiveObjectWithData: tempData];
    }
    return currentUpdateSTBInfo;
}

+ (void)setCurrentUpdateSTBInfo:(UpdateSTBInfo*)currentUpdateSTBInfo
{
    NSData *archiveCarPriceData = [NSKeyedArchiver archivedDataWithRootObject:currentUpdateSTBInfo];
    [[NSUserDefaults standardUserDefaults] setObject:archiveCarPriceData forKey:CurrentUpdateSTBInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSArray *allKeys = self.propertyKeys;
    id objValue = nil;
    for (NSString *key in allKeys) {
        objValue = [self valueForKey:key];
        [aCoder encodeObject:objValue forKey:key];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if (self) {
        NSArray *allKeys = self.propertyKeys;
        id objValue = nil;
        for (NSString *key in allKeys) {
            objValue = [aDecoder decodeObjectForKey:key];
            [self setValue:objValue forKey:key];
        }
    }
    return self;
}


@end

@implementation DownLoadFirmwareInfo
static NSString *DownLoadFirmwareInfos = @"FirmwaresInfos";

+ (NSDictionary*)downLoadFirmwareInfos
{
    NSData *tempData =  [[NSUserDefaults standardUserDefaults] objectForKey:DownLoadFirmwareInfos];
    NSDictionary *firwareInfos = nil;
    if (tempData) {
        firwareInfos = [NSKeyedUnarchiver unarchiveObjectWithData:tempData];
    }
    return firwareInfos;
}
+ (void)setDownLoadFirmwareInfos:(NSDictionary*)firmwares
{
    NSData *archiveCarPriceData = [NSKeyedArchiver archivedDataWithRootObject:firmwares];
    [[NSUserDefaults standardUserDefaults] setObject:archiveCarPriceData forKey:DownLoadFirmwareInfos];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *values = [self downLoadFirmwareInfos];
    INFO(@"value:%@",values);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSArray *allKeys = self.propertyKeys;
    id objValue = nil;
    for (NSString *key in allKeys) {
        objValue = [self valueForKey:key];
        [aCoder encodeObject:objValue forKey:key];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if (self) {
        NSArray *allKeys = self.propertyKeys;
        id objValue = nil;
        for (NSString *key in allKeys) {
            objValue = [aDecoder decodeObjectForKey:key];
            [self setValue:objValue forKey:key];
        }
    }
    return self;
}


@end
