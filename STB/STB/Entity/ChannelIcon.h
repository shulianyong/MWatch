//
//  ChannelIcon.h
//  STB
//
//  Created by shulianyong on 14-2-16.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelIcon : NSObject<NSCoding>

+ (NSString*)iconFolder;

@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *version;
- (UIImage*)icon;

@end

@interface ServerChannelIcon : NSObject

@property (nonatomic,strong)NSString *version;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *sign;
@property (nonatomic,strong)NSString *key;

@end