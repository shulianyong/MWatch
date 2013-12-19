//
//  ConfirmUtil.h
//  STB
//
//  Created by shulianyong on 13-12-1.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfirmUtil : NSObject

+ (instancetype)Util;


- (void)showConfirmWithTitle:(NSString*)aTitle
                 withMessage:(NSString*)aMsg
                 WithOKBlcok:(dispatch_block_t)okBlock
             withCancelBlock:(dispatch_block_t)cancelBlock;

@end
