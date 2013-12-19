//
//  FactoryReset.h
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FactoryReset : NSObject

+ (FactoryReset*)shareInstance;
- (void)factoryReset;

@end
