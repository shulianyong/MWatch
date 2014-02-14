//
//  SingleAlert.h
//  STB
//
//  Created by shulianyong on 13-12-16.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleAlert : NSObject

@property (nonatomic,strong) UIAlertView *alertView;

+ (SingleAlert*)shareInstance;

+ (void)showMessage:(NSString*)aMessgae;

@end
