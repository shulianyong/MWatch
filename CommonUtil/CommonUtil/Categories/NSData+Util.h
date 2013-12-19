//
//  NSData+Util.h
//  VVM
//
//  Created by shulianyong on 12/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (Util)

- (BOOL)isEmpty;

+ (NSData*)base64Encode:(NSString*)aString encoding:(NSStringEncoding)aEncoding;

+ (NSData*)base64Encode:(NSData*)aData;

+ (NSData*)base64Decode:(id)aBase64;

@end
