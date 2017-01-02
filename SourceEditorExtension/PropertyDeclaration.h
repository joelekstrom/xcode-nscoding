//
//  PropertyDeclaration.h
//  NSCodingExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PropertyDeclaration : NSObject

- (nullable instancetype)initWithString:(NSString *)string;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *attributes;
@property (nonatomic, copy, nullable) Class propertyClass;
@property (nonatomic, assign) BOOL isPointer;

@end

@interface PropertyDeclaration (NSCodingUtilities)

- (nullable NSString *)stringForEncodingWithNSCoder;
- (nullable NSString *)stringForInitializingWithNSCoder;

@end

NS_ASSUME_NONNULL_END
