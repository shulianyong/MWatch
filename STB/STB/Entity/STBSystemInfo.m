//
//  STBSystemInfo.m
//  STB
//
//  Created by shulianyong on 14-1-22.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "STBSystemInfo.h"

@implementation STBSystemInfo

static NSString *DefaultSystemInfo=@"DefaultSystemInfo";

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSArray *allKeys = self.propertyKeys;
    id objValue = nil;
    for (NSString *key in allKeys) {
        objValue = [self valueForKey:key];
        [aCoder encodeObject:objValue forKey:key];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if (self) {
        NSArray *allKeys = self.propertyKeys;
        id objValue = nil;
        for (NSString *key in allKeys) {
            objValue = [aDecoder decodeObjectForKey:key];
            [self setValue:objValue forKey:key];
        }
    }
    return self;
}

@end
