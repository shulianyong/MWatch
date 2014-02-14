//
//  SatInfo.h
//  STB
//
//  Created by shulianyong on 13-11-23.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SatInfo : NSObject

@property (nonatomic, retain) NSNumber *  childrenNum;
@property (nonatomic, retain) NSNumber *  commited;
@property (nonatomic, retain) NSNumber *  currentRadio;
@property (nonatomic, retain) NSNumber *  currentTv;
@property (nonatomic, retain) NSNumber *  diseqcVersion;
@property (nonatomic, retain) NSNumber *  lnbOffsetHigh;
@property (nonatomic, retain) NSNumber *  lnbOffsetLow;
@property (nonatomic, retain) NSNumber *  lnbPower;
@property (nonatomic, retain) NSNumber *  longitude;
@property (nonatomic, retain) NSNumber *  motorPosition;
@property (nonatomic, retain) NSString *  name;
@property (nonatomic, retain) NSNumber *  satId;
@property (nonatomic, retain) NSNumber *  tone;
@property (nonatomic, retain) NSNumber *  tuner;
@property (nonatomic, retain) NSNumber *  type;
@property (nonatomic, retain) NSNumber *  uncommited;

@end
