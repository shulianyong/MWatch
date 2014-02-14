//
//  ConfirmUtil.h
//  STB
//
//  Created by shulianyong on 13-12-1.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfirmUtil : NSObject

+ (instancetype)Util;


- (void)showConfirmWithTitle:(NSString*)aTitle
                 withMessage:(NSString*)aMsg
                 WithOKBlcok:(dispatch_block_t)okBlock
             withCancelBlock:(dispatch_block_t)cancelBlock;

@end
