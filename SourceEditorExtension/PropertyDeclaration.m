//
//  PropertyDeclaration.m
//  NSCodingExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "PropertyDeclaration.h"

typedef NS_ENUM(NSInteger, PropertyTokenType) {
    PropertyTokenTypePropertyDeclaration,
    PropertyTokenTypeAttributes,
    PropertyTokenTypeName,
    PropertyTokenTypePointer,
    PropertyTokenTypeExtra
};

@implementation PropertyDeclaration

- (instancetype)initWithString:(NSString *)string
{
    if (self = [super init]) {
        NSMutableString *mutableString = [string mutableCopy];

        // Remove @property, we only need it to verify that it is indeed a property
        NSRange propertyRange = [mutableString rangeOfString:@"@property"];
        if (propertyRange.location == NSNotFound) {
            return nil;
        } else {
            [mutableString deleteCharactersInRange:propertyRange];
        }

        // Parse and remove attributes if they exist
        NSRange attributesRange = [mutableString rangeOfString:@"\\(.*\\)" options:NSRegularExpressionSearch];
        if (attributesRange.location != NSNotFound) {
            NSMutableCharacterSet *charactersToTrim = [NSMutableCharacterSet whitespaceCharacterSet];
            [charactersToTrim addCharactersInString:@"()"];
            self.attributes = [[mutableString substringWithRange:attributesRange] stringByTrimmingCharactersInSet:charactersToTrim];
            [mutableString deleteCharactersInRange:attributesRange];
        }

        // Remove typed collections. For example, if the type is NSArray<NSArray<NSString *> *> *,
        // we're only interested in knowing that the type is NSArray *
        NSRange collectionTypesRange = [mutableString rangeOfString:@"<.*>" options:NSRegularExpressionSearch];
        if (collectionTypesRange.location != NSNotFound) {
            [mutableString deleteCharactersInRange:collectionTypesRange];
        }

        // Check if this property is a pointer (by simply checking if the string contains a '*')
        self.isPointer = [mutableString rangeOfString:@"*"].location != NSNotFound;

        // Tokenize the string and filter away whitespace. The remaining tokens should be:
        // 1. type, 2. name, 3+. any extras like NS_UNAVAILABLE.
        NSMutableCharacterSet *separators = [NSMutableCharacterSet whitespaceCharacterSet];
        [separators addCharactersInString:@"*;"];
        NSMutableArray *tokens = [[mutableString componentsSeparatedByCharactersInSet:separators] mutableCopy];
        [tokens removeObjectsAtIndexes:[tokens indexesOfObjectsPassingTest:^BOOL(NSString *token, NSUInteger idx, BOOL *stop) {
            return token.length == 0;
        }]];

        // Exit if we have less than two tokens. We must have at least a type and a name
        if (tokens.count < 2) {
            return nil;
        }

        self.type = tokens[0];
        self.name = tokens[1];
    }
    return self;
}

@end

@implementation PropertyDeclaration (NSCodingUtilities)

- (NSString *)stringForEncodingWithNSCoder
{
    NSString *encodingType = [self typeForNSCoder];
    if (encodingType) {
        NSString * const encodeFormat = @"[aCoder encode%@:self.%@ forKey:NSStringFromSelector(@selector(%@))];";
        return [NSString stringWithFormat:encodeFormat, encodingType, self.name, self.name];
    }
    return [NSString stringWithFormat:@"#warning Could not determine type for NSCoding of property: %@", self.name];;
}

- (NSString *)stringForInitializingWithNSCoder
{
    if (self.isPointer) {
        NSString * const secureDecodeFormat = @"self.%@ = [aDecoder decodeObjectOfClass:[%@ class] forKey:NSStringFromSelector(@selector(%@))];";
        return [NSString stringWithFormat:secureDecodeFormat, self.name, self.type, self.name];
    } else {
        NSString *decodingType = [self typeForNSCoder];
        if (decodingType) {
            NSString * const decodeFormat = @"self.%@ = [aDecoder decode%@ForKey:NSStringFromSelector(@selector(%@))];";
            return [NSString stringWithFormat:decodeFormat, self.name, decodingType, self.name];
        }
    }
    return [NSString stringWithFormat:@"#warning Could not determine type for NSCoding of property: %@ with type: %@", self.name, self.type];;
}

- (nullable NSString *)typeForNSCoder
{
    if (self.isPointer || [self.type isEqualToString:@"id"]) {
        return @"Object";
    } else {
        return [self primitiveTypeForNSCoder];
    }
}

/**
 If the type of self is not a pointer/NSCoding-enabled class, checks the type against
 known supported types for NSCoder, and returns one of those. For example, maps
 NSInteger to Integer, which it is called by NSCoder-subclasses.
 */
- (nullable NSString *)primitiveTypeForNSCoder
{
    // These types have perfect mappings for NSCoding and can be used directly
    NSSet *perfectMappings = [NSSet setWithObjects:@"CGPoint", @"CGRect", @"CGSize", @"CGAffineTransform", @"UIEdgeInsets", @"UIOffset", @"CGVector", @"CMTime", @"CMTimeRange", @"CMTimeMapping", nil];
    if ([perfectMappings containsObject:self.type]) {
        return self.type;
    } else if ([self.type isEqualToString:@"NSInteger"]) {
        return @"Integer";
    } else if ([self.type isEqualToString:@"BOOL"]) {
        return @"Bool";
    } else if ([self.type isEqualToString:@"int"]) {
        return @"Int";
    } else if ([self.type isEqualToString:@"int32_t"]) {
        return @"Int32";
    } else if ([self.type isEqualToString:@"int64_t"]) {
        return @"Int64";
    } else if ([self.type isEqualToString:@"double"]) {
        return @"Double";
    } else if ([self.type isEqualToString:@"float"]) {
        return @"Float";
    } else if ([self.type isEqualToString:@"NSPoint"]) {
        return @"Point";
    } else if ([self.type isEqualToString:@"NSRect"]) {
        return @"Rect";
    } else if ([self.type isEqualToString:@"NSSize"]) {
        return @"Size";
    }
    return nil;
}

@end
