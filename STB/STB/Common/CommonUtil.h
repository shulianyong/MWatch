//
//  CommonUtil.h
//  STB
//
//  Created by shulianyong on 13-10-14.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

//提示
+ (void)showMessage:(NSString*)aMessgae;
//提示
+ (void)showMessage:(NSString*)aMessgae withCannelBlock:(dispatch_block_t)aBlock;

@end


