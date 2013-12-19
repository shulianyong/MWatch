//
//  NSDate+Util.h
//  VVM
//
//  Created by shulianyong on 12/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//  Originated by Alberto García Hierro(on dateFromRFC2822). 
//  See http://fi.am/entry/parsing-rfc2822-dates-with-nsdate/
//

#import <Foundation/Foundation.h>


@interface NSDate (Util)
//rfc2822 date example Fri, 09 Sep 2005 13:51:39 -0700
+ (NSDate*)dateFromRFC2822:(NSString *)aRFC2822;
+ (NSString*)dateToRFC2822:(NSDate*)aDate;

+ (NSDate*)dateFromString:(NSString*)aDateString withFormat:(NSString*)aFormat;
#pragma mark
#pragma mark ---------------日期格式显示
- (NSString*)descriptionAsFormat:(NSString*)aFormat;
- (NSString*)descriptionAsFormat:(NSString *)aFormat withTimeZone:(NSTimeZone*)aZone;

// HH:mm:ss
// yyyy-MM-dd
// MM/dd/yyyy
- (NSString*)descriptionLocalAsFormat:(NSString *)aFormat;

//时间间隔 month and day
+ (NSDateComponents*)fromDate:(NSTimeInterval)aFromDate toDate:(NSTimeInterval)aToDate;

+ (NSDateComponents*)dateComponentsFromDate:(NSTimeInterval)aFromDate;

+ (NSString*)timeIntervalToLocalString:(NSTimeInterval)aTime WithFormat:(NSString*)aFormat;
@end
