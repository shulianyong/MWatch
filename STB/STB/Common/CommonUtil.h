//
//  CommonUtil.h
//  STB
//
//  Created by shulianyong on 13-10-14.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

typedef enum
{
	FileDownStateDefault = 0, /**<默认 */
	FileDownStateSuccess = 1, /**< 成功 */
	FileDownStateFail = 2, /**< 失败 */
	FileDownStateDisconnection = 3 /**< 网络联接失败 */
}
FileDownState;

typedef void(^FileDownloadCallback)(id info,FileDownState isSuccess);

+ (NSString*)serverIP;

//提示
+ (void)showMessage:(NSString*)aMessgae;
//提示
+ (void)showMessage:(NSString*)aMessgae withCannelBlock:(dispatch_block_t)aBlock;

@end


