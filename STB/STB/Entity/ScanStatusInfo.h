//
//  ScanStatusInfo.h
//  STB
//
//  Created by shulianyong on 13-11-24.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScanStatusInfo : NSObject

@property (nonatomic,strong) NSString *event;
@property (nonatomic,strong) NSNumber *status;
@property (nonatomic,strong) NSNumber *progress;

@end
