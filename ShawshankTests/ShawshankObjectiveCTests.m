//
//  ShawshankObjectiveCTests.m
//  Shawshank
//
//  Created by Andrew Tetlaw on 1/1/17.
//  Copyright © 2017 Andrew Tetlaw. All rights reserved.
//

@import XCTest;
#import <Shawshank/Shawshank-Swift.h>

@interface ShawshankObjectiveCTests : XCTestCase
@property (nonatomic) NSURLRequest *testRequest;
@end

@implementation ShawshankObjectiveCTests

- (void)setUp {
    [super setUp];
    self.testRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com/path/to"]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testObjectiveCAPI
{
    SHKResponse *testResponse = [SHKResponse new];
    testResponse.httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.testRequest.URL statusCode:101 HTTPVersion:nil headerFields:nil];

    [[SHKShawshank takeWithRequestPredicate:^BOOL(NSURLRequest *_Nonnull request ) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
        return [components.host isEqualToString:@"www.example.com"] && [components.path isEqualToString:@"/path/to"];
    }] withResponse:testResponse];

    XCTestExpectation *expectation = [self expectationWithDescription:@"response successful"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:self.testRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        XCTAssertEqual(httpResponse.statusCode, testResponse.httpResponse.statusCode);
        [expectation fulfill];
    }];

    [task resume];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
