//
//  ServerUpdateSTBInfo.h
//  STB
//
//  Created by shulianyong on 14-2-10.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerUpdateSTBInfo : NSObject
{
    NSMutableArray *stbinfo;
}

@property (nonatomic,strong)NSString *playerversion;
@property (nonatomic,readonly)NSMutableArray *stbinfo;

@end

@interface ServerSTBInfo : NSObject

@property (nonatomic,strong)NSString *hwversion;
@property (nonatomic,strong)NSString *swversion;
@property (nonatomic,strong)NSString *stbidstart;
@property (nonatomic,strong)NSString *stbidend;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *filesize;
@property (nonatomic,strong)NSString *sign;
@property (nonatomic,strong)NSString *key;

@end



