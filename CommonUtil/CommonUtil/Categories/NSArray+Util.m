//
//  NSArray+Util.m
//  VVM
//
//  Created by shulianyong on 12/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Util.h"


@implementation NSArray (Util)

- (BOOL)isEmpty{
	if (self == nil) return YES;
	return (BOOL)(self.count == 0);
}

- (NSString*) stringWithCharacter:(NSString*)aCharacter
{
    [self componentsJoinedByString:aCharacter];
    NSMutableString *value = nil;
    if (self.count>0) 
    {
        if ([self[0] isKindOfClass:[NSString class]]) {            
            value = [[NSMutableString alloc] initWithString:[self objectAtIndex:0]];
            for (int i=1; i<self.count; i++) {
                [value appendString:aCharacter];
                [value appendString:[self objectAtIndex:i]];
            }
        }       
    }
    return (value)?value:@"";
}

@end
