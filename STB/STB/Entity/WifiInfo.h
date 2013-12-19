//
//  WifiInfo.h
//  STB
//
//  Created by shulianyong on 13-11-12.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WifiInfo : NSObject

@property (nonatomic,strong) NSNumber *result;
@property (nonatomic,strong) NSString *command;
@property (nonatomic,strong) NSNumber *commandId;
@property (nonatomic,strong) NSString *wifi_ap_passwd;
@property (nonatomic,strong) NSNumber *free_status;
@property (nonatomic,strong) NSString *error;
@property (nonatomic,strong) NSString *wifi_ap_name;

@end
