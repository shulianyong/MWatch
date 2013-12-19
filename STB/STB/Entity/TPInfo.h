//
//  TPInfo.h
//  STB
//
//  Created by shulianyong on 13-11-23.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPInfo : NSObject

@property (nonatomic, retain) NSNumber *command      ;
@property (nonatomic, retain) NSNumber *command_id   ;
@property (nonatomic, retain) NSNumber *result       ;
@property (nonatomic, retain) NSNumber *tpId         ;
@property (nonatomic, retain) NSNumber *satId        ;
@property (nonatomic, retain) NSNumber *frequency    ;
@property (nonatomic, retain) NSNumber *type         ;
@property (nonatomic, retain) NSNumber *symbolRate   ;
@property (nonatomic, retain) NSNumber *polarization ;//H=0 V=1
@property (nonatomic, retain) NSNumber *modulation   ;
@property (nonatomic, retain) NSNumber *bandwidth    ;
@property (nonatomic, retain) NSString *error        ;

@end
