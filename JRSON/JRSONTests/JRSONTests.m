//
//  JRSONTests.m
//  JRSONTests
//
//  Created by J on 2016/12/22.
//  Copyright © 2016年 J. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JRSON.h"
#import "Animal.h"


@interface JRSONTests : XCTestCase

@end

@implementation JRSONTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    Person *p = [Person new];
    NSString *json = [JRSON parseObjToJSON:p];
    NSLog(@"%@", json);
    p.json = json;
    json = [JRSON parseObjToJSON:p];

    NSLog(@"==========");
    NSLog(@"%@", json);
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
