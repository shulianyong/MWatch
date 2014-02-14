//
//  ASIHTTPTests.m
//  ASIHTTPTests
//
//  Created by shulianyong on 13-11-19.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ASITestCase.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequestConfig.h"

@interface ASIHTTPTests : ASITestCase

@end

@implementation ASIHTTPTests

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

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

-(void)testDefaultMethod
{
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://wedontcare.com"]] autorelease];
  
    XCTAssertTrue([[request requestMethod] isEqualToString:@"POST"], @"Default request method should be POST");
}

- (void)testBody
{
    ASIFormDataRequest *request = [ASIFormDataRequest jsonRequestWithURL:[NSURL URLWithString:@"http://192.198.0.1:8085/command"]];
//	[request setPostValue:nil forKey:@"key1"];
	[request setPostValue:@"channel_list" forKey:@"command"];
	[request setPostValue:@4 forKey:@"commandId"];
    
    request.useHTTPVersionOne = YES;
//	[request setData:nil forKey:@"file1"];
//	[request setData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"file2"];
    [request buildPostBody];
    
    [request setCompletionBlock:^{
        
    }];
    
    [request setFailedBlock:^{
        
        NSError *error = request.error;
        NSLog(@"error:%@",error);
        
    }];
    
	[request startSynchronous];
    
    NSString *resultString = [request responseString];
    
	BOOL success = resultString!=nil;
    
    
    
	XCTAssertTrue(success, @"Sent wrong data");
    
    NSString *postBody = [[[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"body:%@   header:%@",postBody,request.requestHeaders);
    
//	// Test nil key (no key or value should be sent to the server)
	request = [ASIFormDataRequest jsonRequestWithURL:[NSURL URLWithString:@"http://allseeing-i.com"]];
	[request addPostValue:@"value1" forKey:nil];
	[request addPostValue:@"value2" forKey:@"key2"];
	[request buildPostBody];
	postBody = [[[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding] autorelease];
	success = ([postBody isEqualToString:@"key2=value2"]);
	XCTAssertTrue(success, @"Sent wrong data");
}

@end
