//
//  NSString+Util.h
//  VVM
//
//  Created by shulianyong on 12/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DCM_DOCUMENT_NAME
#define DCM_DOCUMENT_NAME @"DCMDATADOCUMENT"
#endif

@interface NSString (Util)

- (BOOL)isEmpty;
+ (BOOL)isEmpty:(NSString*)aString;

+ (NSString*)urlEncode:(NSString*)aSource;

+ (NSString*)urlDecode:(NSString*)aSource;

+ (unsigned int)convertHexString:(NSString*)aHex;

+ (NSString*)base64Encode:(NSData*)aData;

+ (NSString*)base64Encode:(NSString*)aString encoding:(NSStringEncoding)aEncoding;

+ (NSString*)base64Decode:(NSString*)aBase64 encoding:(NSStringEncoding)aEncoding;

+ (NSString*)base64Decode:(NSString*)aBase64;

+ (NSUInteger)length:(NSString*)aString;

+ (BOOL)isAsciiOnly:(NSString*)aString;

+ (BOOL) regexWithFormat:(NSString*)aFormat ValueString:(NSString*)aValueString;

+ (NSString*) MD5:(NSString*)aValue;

+ (NSString*)UUID;

+ (NSString *) phoneNumFormat:(NSString*)aValue;

+ (NSArray*)emails:(NSString*)aText;

+ (NSString *) valueNotNull:(NSString*)aValue;

+ (BOOL) marchStringForSearch:(NSString*)aBaseString withMarch:(NSString*)aMarchString;

+ (NSString *) firstLetter:(NSString*)aString;


#pragma mark 文件路径管理
+ (NSString*)documentFolderPath;

+ (NSString*)pathInDocument:(NSString*)aPath;

//cache文件夹路径
+ (NSString*)cacheFolderPath;
//图片文件夹
+ (NSString*)imageFolderInCache;

//获取文件名
+ (NSString*)fileNameInPath:(NSString*)aPath;

- (NSString*)trim;

+ (BOOL)isNumberString:(NSString*)aString;

@end
