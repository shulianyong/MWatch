//
//  ASICloudFilesRequestTests.m
//
//  Created by Michael Mayo on 1/6/10.
//

#import "ASICloudFilesRequestTests.h"

// models
#import "ASICloudFilesContainer.h"
#import "ASICloudFilesObject.h"

// requests
#import "ASICloudFilesRequest.h"
#import "ASICloudFilesContainerRequest.h"
#import "ASICloudFilesObjectRequest.h"
#import "ASICloudFilesCDNRequest.h"

// Fill in these to run the tests that actually connect and manipulate objects on Cloud Files
static NSString *username = @"";
static NSString *apiKey = @"";

@implementation ASICloudFilesRequestTests

@synthesize networkQueue;

// Authenticate before any test if there's no auth token present
- (void)authenticate {
	if (![ASICloudFilesRequest authToken]) {
		[ASICloudFilesRequest setUsername:username];
		[ASICloudFilesRequest setApiKey:apiKey];
		[ASICloudFilesRequest authenticate];		
	}
}

// ASICloudFilesRequest
- (void)testAuthentication {
	[self authenticate];
	XCTAssertNotNil([ASICloudFilesRequest authToken], @"Failed to authenticate and obtain authentication token");
	XCTAssertNotNil([ASICloudFilesRequest storageURL], @"Failed to authenticate and obtain storage URL");
	XCTAssertNotNil([ASICloudFilesRequest cdnManagementURL], @"Failed to authenticate and obtain CDN URL");
}

- (void)testDateParser {
	ASICloudFilesRequest *request = [[[ASICloudFilesRequest alloc] init] autorelease];
	
	NSDate *date = [request dateFromString:@"invalid date string"];
	XCTAssertNil(date, @"Should have failed to parse an invalid date string");
	
	date = [request dateFromString:@"2009-11-04T19:46:20.192723"];
	XCTAssertNotNil(date, @"Failed to parse date string");		
	
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	[components setYear:2009];
	[components setMonth:11];
	[components setDay:4];
	[components setHour:19];
	[components setMinute:46];
	[components setSecond:20];
	NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDate *referenceDate = [calendar dateFromComponents:components];
	
	// NSDateComponents has seconds as the smallest value, so we'll just check the created date is less than 1 second different from what we expect
	NSTimeInterval timeDifference = [date timeIntervalSinceDate:referenceDate];
	BOOL success = (timeDifference < 1.0);
	XCTAssertTrue(success, @"Parsed date incorrectly");	
}

// ASICloudFilesContainerRequest
- (void)testAccountInfo {
	[self authenticate];
	
	ASICloudFilesContainerRequest *request = [ASICloudFilesContainerRequest accountInfoRequest];
	[request startSynchronous];
	
	XCTAssertTrue([request containerCount] > 0, @"Failed to retrieve account info");
	XCTAssertTrue([request bytesUsed] > 0, @"Failed to retrieve account info");
}

- (void)testContainerList {
	[self authenticate];
	
	NSArray *containers = nil;
	
	ASICloudFilesContainerRequest *containerListRequest = [ASICloudFilesContainerRequest listRequest];
	[containerListRequest startSynchronous];
	
	containers = [containerListRequest containers];
	XCTAssertTrue([containers count] > 0, @"Failed to list containers");
	NSUInteger i;
	for (i = 0; i < [containers count]; i++) {
		ASICloudFilesContainer *container = [containers objectAtIndex:i];
		XCTAssertNotNil(container.name, @"Failed to parse container");
	}
	
	ASICloudFilesContainerRequest *limitContainerListRequest = [ASICloudFilesContainerRequest listRequestWithLimit:2 marker:nil];
	[limitContainerListRequest startSynchronous];	
	containers = [limitContainerListRequest containers];
	XCTAssertTrue([containers count] == 2, @"Failed to limit container list");
}

- (void)testContainerCreate {
	[self authenticate];
	
	ASICloudFilesContainerRequest *createContainerRequest = [ASICloudFilesContainerRequest createContainerRequest:@"ASICloudFilesContainerTest"];
	[createContainerRequest startSynchronous];
	XCTAssertTrue([createContainerRequest error] == nil, @"Failed to create container");
}

- (void)testContainerDelete {
	[self authenticate];

	ASICloudFilesContainerRequest *deleteContainerRequest = [ASICloudFilesContainerRequest deleteContainerRequest:@"ASICloudFilesContainerTest"];
	[deleteContainerRequest startSynchronous];
	XCTAssertTrue([deleteContainerRequest error] == nil, @"Failed to delete container");	
}

// ASICloudFilesObjectRequest
- (void)testContainerInfo {
	[self authenticate];

	// create a file first
	ASICloudFilesContainerRequest *createContainerRequest = [ASICloudFilesContainerRequest createContainerRequest:@"ASICloudFilesTest"];
	[createContainerRequest startSynchronous];
	NSData *data = [@"this is a test" dataUsingEncoding:NSUTF8StringEncoding];
	ASICloudFilesObjectRequest *putRequest 
		= [ASICloudFilesObjectRequest putObjectRequestWithContainer:@"ASICloudFilesTest" 
													 objectPath:@"infotestfile.txt" contentType:@"text/plain" 
													 objectData:data metadata:nil etag:nil];
	
	[putRequest startSynchronous];
	
	ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest containerInfoRequest:@"ASICloudFilesTest"];
	[request startSynchronous];	
	XCTAssertTrue([request containerObjectCount] > 0, @"Failed to retrieve container info");
	XCTAssertTrue([request containerBytesUsed] > 0, @"Failed to retrieve container info");
}

- (void)testObjectInfo {
	[self authenticate];
	
	ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest objectInfoRequest:@"ASICloudFilesTest" objectPath:@"infotestfile.txt"];
	[request startSynchronous];
	
	ASICloudFilesObject *object = [request object];
	XCTAssertNotNil(object, @"Failed to retrieve object");
	XCTAssertTrue([object.metadata count] > 0, @"Failed to parse metadata");
	
	XCTAssertTrue([object.metadata objectForKey:@"Test"] != nil, @"Failed to parse metadata");
	
}

- (void)testObjectList {
	[self authenticate];
	
	ASICloudFilesObjectRequest *objectListRequest = [ASICloudFilesObjectRequest listRequestWithContainer:@"ASICloudFilesTest"];
	[objectListRequest startSynchronous];
	
	NSArray *containers = [objectListRequest objects];
	XCTAssertTrue([containers count] > 0, @"Failed to list objects");
	NSUInteger i;
	for (i = 0; i < [containers count]; i++) {
		ASICloudFilesObject *object = [containers objectAtIndex:i];
		XCTAssertNotNil(object.name, @"Failed to parse object");
	}
	
}

- (void)testGetObject {
	[self authenticate];
	
	ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest getObjectRequestWithContainer:@"ASICloudFilesTest" objectPath:@"infotestfile.txt"];
	[request startSynchronous];
	
	ASICloudFilesObject *object = [request object];
	XCTAssertNotNil(object, @"Failed to retrieve object");
	
	XCTAssertNotNil(object.name, @"Failed to parse object name");
	XCTAssertTrue(object.bytes > 0, @"Failed to parse object bytes");
	XCTAssertNotNil(object.contentType, @"Failed to parse object content type");
	XCTAssertNotNil(object.lastModified, @"Failed to parse object last modified");
	XCTAssertNotNil(object.data, @"Failed to parse object data");
}

- (void)testPutObject {
	[self authenticate];
	
	ASICloudFilesContainerRequest *createContainerRequest 
			= [ASICloudFilesContainerRequest createContainerRequest:@"ASICloudFilesTest"];
	[createContainerRequest startSynchronous];

	NSData *data = [@"this is a test" dataUsingEncoding:NSUTF8StringEncoding];
	
	ASICloudFilesObjectRequest *putRequest 
			= [ASICloudFilesObjectRequest putObjectRequestWithContainer:@"ASICloudFilesTest" 
											objectPath:@"puttestfile.txt" contentType:@"text/plain" 
											objectData:data metadata:nil etag:nil];
	
	[putRequest startSynchronous];
	
	XCTAssertNil([putRequest error], @"Failed to PUT object");

	ASICloudFilesObjectRequest *getRequest = [ASICloudFilesObjectRequest getObjectRequestWithContainer:@"ASICloudFilesTest" objectPath:@"puttestfile.txt"];
	[getRequest startSynchronous];
	
	ASICloudFilesObject *object = [getRequest object];
	NSString *string = [[NSString alloc] initWithData:object.data encoding:NSASCIIStringEncoding];

	XCTAssertNotNil(object, @"Failed to retrieve new object");
	XCTAssertNotNil(object.name, @"Failed to parse object name");
	XCTAssertEqualStrings(object.name, @"puttestfile.txt", @"Failed to parse object name", @"Failed to parse object name");
	XCTAssertNotNil(object.data, @"Failed to parse object data");
	XCTAssertEqualStrings(string, @"this is a test", @"Failed to parse object data", @"Failed to parse object data");

	
	ASICloudFilesContainerRequest *deleteContainerRequest = [ASICloudFilesContainerRequest deleteContainerRequest:@"ASICloudFilesTest"];
	[deleteContainerRequest startSynchronous];
	
	// Now put the object from a file

	createContainerRequest = [ASICloudFilesContainerRequest createContainerRequest:@"ASICloudFilesTest"];
	[createContainerRequest startSynchronous];
	
	NSString *filePath = [[self filePathForTemporaryTestFiles] stringByAppendingPathComponent:@"cloudfile"];
	[data writeToFile:filePath atomically:NO];
	
	putRequest = [ASICloudFilesObjectRequest putObjectRequestWithContainer:@"ASICloudFilesTest" objectPath:@"puttestfile.txt" contentType:@"text/plain" file:filePath metadata:nil etag:nil];
	
	[putRequest startSynchronous];
	
	XCTAssertNil([putRequest error], @"Failed to PUT object");
	
	getRequest = [ASICloudFilesObjectRequest getObjectRequestWithContainer:@"ASICloudFilesTest" objectPath:@"puttestfile.txt"];
	[getRequest startSynchronous];
	
	object = [getRequest object];
	
	XCTAssertNotNil(object, @"Failed to retrieve new object");
	XCTAssertNotNil(object.name, @"Failed to parse object name");
	XCTAssertEqualStrings(object.name, @"puttestfile.txt", @"Failed to parse object name", @"Failed to parse object name");
	XCTAssertNotNil(object.data, @"Failed to parse object data");
	XCTAssertEqualStrings(string, @"this is a test", @"Failed to parse object data", @"Failed to parse object data");
	
	[string release];
	
	deleteContainerRequest = [ASICloudFilesContainerRequest deleteContainerRequest:@"ASICloudFilesTest"];
	[deleteContainerRequest startSynchronous];
}

- (void)testPostObject {
	[self authenticate];
	
	NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithCapacity:2];
	[metadata setObject:@"test" forKey:@"Test"];
	[metadata setObject:@"test" forKey:@"ASITest"];
	
	ASICloudFilesObject *object = [ASICloudFilesObject object];
	object.name = @"infotestfile.txt";
	object.metadata = metadata;
	
	ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest postObjectRequestWithContainer:@"ASICloudFilesTest" object:object];
	[request startSynchronous];
	
	XCTAssertTrue([request responseStatusCode] == 202, @"Failed to post object metadata");
	
	[metadata release];
	
}

- (void)testDeleteObject {
	[self authenticate];
	
	ASICloudFilesObjectRequest *deleteRequest = [ASICloudFilesObjectRequest deleteObjectRequestWithContainer:@"ASICloudFilesTest" objectPath:@"puttestfile.txt"];
	[deleteRequest startSynchronous];
	XCTAssertTrue([deleteRequest responseStatusCode] == 204, @"Failed to delete object");
}

#pragma mark -
#pragma mark CDN Tests

- (void)testCDNContainerInfo {
	[self authenticate];
	
	ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest containerInfoRequest:@"ASICloudFilesTest"];
	[request startSynchronous];
	
	XCTAssertTrue([request responseStatusCode] == 204, @"Failed to retrieve CDN container info");
	XCTAssertTrue([request cdnEnabled], @"Failed to retrieve CDN container info");
	XCTAssertNotNil([request cdnURI], @"Failed to retrieve CDN container info");
	XCTAssertTrue([request cdnTTL] > 0, @"Failed to retrieve CDN container info");	
}

- (void)testCDNContainerList {
	[self authenticate];
	
	ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest listRequest];
	[request startSynchronous];
	
	XCTAssertNotNil([request containers], @"Failed to retrieve CDN container list");
}

- (void)testCDNContainerListWithParams {
	[self authenticate];
	
	ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest listRequestWithLimit:2 marker:nil enabledOnly:YES];
	[request startSynchronous];
	
	XCTAssertNotNil([request containers], @"Failed to retrieve CDN container list");
	XCTAssertTrue([[request containers] count] == 2, @"Failed to retrieve limited CDN container list");
}

- (void)testCDNPut {
	[self authenticate];
	
	ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest putRequestWithContainer:@"ASICloudFilesTest"];
	[request startSynchronous];
	
	XCTAssertNotNil([request cdnURI], @"Failed to PUT to CDN container");
}

- (void)testCDNPost {
	[self authenticate];
	
	ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest postRequestWithContainer:@"ASICloudFilesTest" cdnEnabled:YES ttl:86600];
	[request startSynchronous];
	
	XCTAssertNotNil([request cdnURI], @"Failed to POST to CDN container");
}

#pragma mark -
#pragma mark Memory Management

-(void)dealloc {
	[networkQueue release];
	[super dealloc];
}

@end
