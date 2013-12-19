//
//  CommonUtilTests.m
//  CommonUtilTests
//
//  Created by shulianyong on 13-10-8.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CommonUtil.h"

@interface CommonUtilTests : XCTestCase

@end

@implementation CommonUtilTests

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

- (void)testExample
{
    CommonUtil *net = [[CommonUtil alloc] init];
    NSLog(@"address:%@",[net teValue]);
}

@end
