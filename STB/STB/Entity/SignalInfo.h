//
//  SignalInfo.h
//  STB
//
//  Created by shulianyong on 13-11-20.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignalInfo : NSObject

@property (nonatomic,strong) NSString *command;
@property (nonatomic,strong) NSNumber *commandId;
@property (nonatomic,strong) NSNumber *result;
@property (nonatomic,strong) NSString *error;
@property (nonatomic,strong) NSNumber *strength;
@property (nonatomic,strong) NSNumber *noiseRatio;
@property (nonatomic,strong) NSNumber *bitErrorRate;
@property (nonatomic,strong) NSString *lock_status;

@end
