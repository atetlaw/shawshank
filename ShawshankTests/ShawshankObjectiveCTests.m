//
//  ShawshankObjectiveCTests.m
//  Shawshank
//
//  Created by Andrew Tetlaw on 1/1/17.
//  Copyright © 2017 SafetyCulture. All rights reserved.
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
    SHKResponse *response = [SHKResponse new];

    [[SHKShawshank takeWithRequestPredicate:^BOOL(NSURLRequest *_Nonnull request ) {
        return YES;
    }] respond:response];
}


@end
