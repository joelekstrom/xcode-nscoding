//
//  PropertyDeclarationTests.m
//  NSCodingExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PropertyDeclaration.h"

@interface PropertyDeclarationTests : XCTestCase

@end

@implementation PropertyDeclarationTests

- (void)testInvalidInput {
    XCTAssertNil([[PropertyDeclaration alloc] initWithString:@"@prprty (nonatomic, strong) Class name;"]);
    XCTAssertNil([[PropertyDeclaration alloc] initWithString:@"NSInteger class;"]);
    XCTAssertNil([[PropertyDeclaration alloc] initWithString:@"@property (nonatomic, strong) NamelessProperty;"]);
    XCTAssertNil([[PropertyDeclaration alloc] initWithString:@"@property (nonatomic, weak) *classlessProperty;"]);
}

- (void)testTypeParsing {
    PropertyDeclaration *property = [[PropertyDeclaration alloc] initWithString:@"@property (nonatomic, strong, getter=myName) NSNumber *name NS_UNAVAILABLE;"];
    XCTAssertEqualObjects(property.type, @"NSNumber");

    property = [[PropertyDeclaration alloc] initWithString:@"@property int name;"];
    XCTAssertEqualObjects(property.type, @"int");
}

- (void)testNameParsing {
    PropertyDeclaration *property = [[PropertyDeclaration alloc] initWithString:@"@property (nonatomic, strong) NSNumber *name;"];
    XCTAssertEqualObjects(property.name, @"name");

    property = [[PropertyDeclaration alloc] initWithString:@"@property int anInt;"];
    XCTAssertEqualObjects(property.name, @"anInt");
}

- (void)testPointerAwareness {
    PropertyDeclaration *property = [[PropertyDeclaration alloc] initWithString:@"@property (nonatomic, strong) NSNumber *name;"];
    XCTAssertTrue(property.isPointer);

    property = [[PropertyDeclaration alloc] initWithString:@"@property (nonatomic, strong) NSNumber*name;"];
    XCTAssertTrue(property.isPointer);

    property = [[PropertyDeclaration alloc] initWithString:@"@property (nonatomic, strong) NSNumber* name;"];
    XCTAssertTrue(property.isPointer);

    property = [[PropertyDeclaration alloc] initWithString:@"@property int anInt;"];
    XCTAssertFalse(property.isPointer);
}

- (void)testCollectionTypeAwareness {
    PropertyDeclaration *property = [[PropertyDeclaration alloc] initWithString:@"@property (nonatomic, strong) NSArray<NSArray<NSNumber *> *> *array;"];
    XCTAssertEqualObjects(property.type, @"NSArray");
    XCTAssertEqualObjects(property.name, @"array");
}

@end
