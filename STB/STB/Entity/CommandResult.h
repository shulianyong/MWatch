//
//  CommandResult.h
//  STB
//
//  Created by shulianyong on 13-10-14.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandResult : NSObject

@property (nonatomic,strong) NSString *command   ;
@property (nonatomic,strong) NSNumber *commandId ;
@property (nonatomic,strong) NSNumber *count     ;
@property (nonatomic,strong) NSString *error     ;
@property (nonatomic,strong) NSNumber *result    ;


@end
