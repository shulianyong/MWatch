//
//  AccessLayerTests.m
//  AccessLayerTests
//
//  Created by shulianyong on 13-10-8.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NetworkManager.h"

#import "../../CommonUtil/CommonUtil/Expecta-iOS/Expecta.h"
#import "../../CommonUtil/CommonUtil/CommonUtil.h"

#import "AccessLayer.h"
#import "TVManager.h"

@interface AccessLayerTests : XCTestCase

@end

@implementation AccessLayerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTVManager
{
    TVManager *manager = [[TVManager alloc] init];
    [manager commandSatellite];
}

- (void)testExample
{
    NetworkManager *net = [[NetworkManager alloc] init];
    AccessLayer *util = [[AccessLayer alloc] init];
    NSLog(@"util:%@",[util sly]);
//    expect([net whatismyipdotcom]).will.beNil();
    
    NSString *address = [net whatismyipdotcom];
    NSLog(@"address:%@",address);
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
