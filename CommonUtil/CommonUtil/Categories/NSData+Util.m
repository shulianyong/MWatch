//
//  NSData+Util.m
//  VVM
//
//  Created by shulianyong on 12/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSData+Util.h"
#import "NSString+Util.h"

@interface NSData (PrivateDelegateHandling)
+ (NSData*)base64DecodeWithData:(NSData*)data;
+ (NSData*)base64DecodeWithString:(NSString*)text;
@end


@implementation NSData (Util)

#pragma mark - Private Methods

+ (NSData*)base64DecodeWithData:(NSData*)data {
	unsigned long ixtext = 0;
	unsigned long lentext = [data length];
	unsigned char ch = 0;
	unsigned char inbuf[4], outbuf[3];
	short ixinbuf = 0;
	BOOL flignore = NO;
	BOOL flendtext = NO;
	
	const unsigned char *bytes = [data bytes];
	NSMutableData *result = [NSMutableData dataWithCapacity:lentext];
	
	while (1) {
		if(ixtext >= lentext) break;
		ch = bytes[ixtext++];
		flignore = NO;
		
		if((ch >= 'A') && (ch <= 'Z')) ch = ch - 'A';
		else if ((ch >= 'a') && (ch <= 'z')) ch = ch - 'a' + 26;
		else if ((ch >= '0') && (ch <= '9')) ch = ch - '0' + 52;
		else if (ch == '+') ch = 62;
		else if (ch == '=') flendtext = YES;
		else if (ch == '/') ch = 63;
		else flignore = YES;
		
		if(!flignore) {
			short ctcharsinbuf = 3;
			BOOL flbreak = NO;
			
			if (flendtext) {
				if (!ixinbuf) break;
				if ((ixinbuf == 1) || (ixinbuf == 2)) ctcharsinbuf = 1;
				else ctcharsinbuf = 2;
				ixinbuf = 3;
				flbreak = YES;
			}
			
			inbuf [ixinbuf++] = ch;
			
			if(ixinbuf == 4) {
				ixinbuf = 0;
				outbuf [0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
				outbuf [1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
				outbuf [2] = ((inbuf[2] & 0x03) << 6 ) | (inbuf[3] & 0x3F);				
//				for(i = 0; i < ctcharsinbuf; i++)
//					[result appendBytes:&outbuf[i] length:1];
                //modified by zengchao, replace for statment to enhance performance
                [result appendBytes:outbuf length:ctcharsinbuf];
			}

			if(flbreak) break;
		}
	}

	return [NSData dataWithData:result];
}

+ (NSData*)base64DecodeWithString:(NSString*)text {
	NSStringEncoding encoding = [text smallestEncoding];
	NSData* data = [text dataUsingEncoding:encoding];
	return [self base64DecodeWithData:data];
}

#pragma mark - Public Methods

- (BOOL)isEmpty {
	if (self == nil) return YES;
	NSString* string = [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];
	return [string isEmpty];
}

+ (NSData*)base64Encode:(NSString*)aString encoding:(NSStringEncoding)aEncoding {
	return [[NSString base64Encode:aString encoding:aEncoding] dataUsingEncoding:aEncoding];
}

+ (NSData*)base64Encode:(NSData*)aData {
	return [[NSString base64Encode:aData] dataUsingEncoding:NSASCIIStringEncoding];
}

+ (NSData*)base64Decode:(id)aBase64 {
	if (![aBase64 class])
        return nil;
	if ([aBase64 isKindOfClass:[NSData class]])
        return [self base64DecodeWithData:(NSData*)aBase64];
	if ([aBase64 isKindOfClass:[NSString class]])
        return [self base64DecodeWithString:(NSString*)aBase64];
	return nil;
}

@end
