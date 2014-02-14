//
//  STBSystemInfo.h
//  STB
//
//  Created by shulianyong on 14-1-22.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STBSystemInfo : NSObject<NSCoding>

+ (instancetype)defaultSystemInfo;
+ (void)setDefaultSystemInfo:(STBSystemInfo*)defaultSystemInfo;

@property (nonatomic,strong) NSNumber *result             ;
@property (nonatomic,strong) NSString *error              ;
@property (nonatomic,strong) NSString *BOXID              ;
@property (nonatomic,strong) NSString *Software_Version   ;
@property (nonatomic,strong) NSString *Release_Date       ;
@property (nonatomic,strong) NSString *HardWare_Version   ;



@end
