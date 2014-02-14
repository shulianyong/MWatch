//
//  FactoryReset.h
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FactoryReset : NSObject

+ (FactoryReset*)shareInstance;
- (void)factoryReset;

@end
