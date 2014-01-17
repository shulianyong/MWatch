//
//  UPNPTool.h
//  STB
//
//  Created by shulianyong on 13-10-30.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UPNPTool;

@protocol UPNPToolProtocol <NSObject>

- (void)upnpTool:(UPNPTool*)aUPNPTool endSearchIP:(NSString*)aSearchIP;
- (void)upnpToolFail:(UPNPTool *)aUPNPTool;

@end

@interface UPNPTool : NSObject
{
    NSString *stbIP;
    BOOL changedIP;
}
//ip
@property (nonatomic,readonly) NSString *stbIP;
//机顶盒ip变化，需要重要刷
@property (nonatomic,readonly) BOOL changedIP;

@property (nonatomic,weak) id<UPNPToolProtocol> toolDelegate;

//+ (UPNPTool*)shareInstance;

- (void)searchIP;
- (BOOL)isSearching;



@end
