//
//  AccessBase.h
//  AccessLayer
//
//  Created by shulianyong on 13-8-14.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetWorking/AFNetworking.h"

typedef enum
{
	HTTPAccessStateDefault = 0, /**<默认 */
	HTTPAccessStateSuccess = 1, /**< 成功 */
	HTTPAccessStateFail = 2, /**< 失败 */
	HTTPAccessStateDisconnection = 3 /**< 网络联接失败 */
}
HTTPAccessState;

typedef void(^httpCallback)(id info,HTTPAccessState isSuccess);



@interface AccessBase : NSObject

- (AFHTTPRequestOperationManager*)httpClient;

@end
