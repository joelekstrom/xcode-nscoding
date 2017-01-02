//
//  PropertyDeclaration.m
//  NSCodingExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "PropertyDeclaration.h"

@implementation PropertyDeclaration

- (instancetype)initWithString:(NSString *)string
{
    if (self = [super init]) {
        // This regular expression matches the following:
        // 1. Attributes, for example (nonatomic,strong)
        // 2. Type/class name
        // 3. Pointer star (*), or whitespace if non-pointer type
        // 4. Property name
        NSString * const pattern = @"^\\s*@property\\s*(\\([a-z,\\s]*\\)|\\s+)\\s*(\\w+)\\s*(\\s*\\*\\s*|\\s+)\\s*(\\w+)\\s*;";

        NSError *error = nil;
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:pattern options:kNilOptions error:&error];
        if (error) {
            NSLog(@"Error when parsing pattern: %@", pattern);
        }

        NSArray<NSTextCheckingResult *> *matches = [regularExpression matchesInString:string options:kNilOptions range:NSMakeRange(0, string.length)];
        if (matches.count == 0) {
            return nil;
        }

        // We're only interested in the first result of a line. It's up to the consuming program to separate multiple properties on a single line.
        NSTextCheckingResult *result = [matches firstObject];
        self.attributes = [string substringWithRange:[result rangeAtIndex:1]];
        self.type = [string substringWithRange:[result rangeAtIndex:2]];
        self.isPointer = [[string substringWithRange:[result rangeAtIndex:3]] containsString:@"*"];
        self.name = [string substringWithRange:[result rangeAtIndex:4]];
        self.propertyClass = NSClassFromString(self.type);
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
    return nil;
}

- (NSString *)stringForInitializingWithNSCoder
{
    if ([self classSupportsSecureCoding]) {
        NSString * const secureDecodeFormat = @"self.%@ = [aDecoder decodeObjectOfClass:[%@ class] forKey:NSStringFromSelector(@selector(%@))];";
        return [NSString stringWithFormat:secureDecodeFormat, self.name, NSStringFromClass(self.propertyClass), self.name];
    } else {
        NSString *decodingType = [self typeForNSCoder];
        if (decodingType) {
            NSString * const decodeFormat = @"self.%@ = [aDecoder decode%@ForKey:NSStringFromSelector(@selector(%@))];";
            return [NSString stringWithFormat:decodeFormat, self.name, decodingType, self.name];
        }
    }
    return nil;
}

- (BOOL)classSupportsNSCoding
{
    return self.isPointer && [self.propertyClass conformsToProtocol:@protocol(NSCoding)];
}

- (BOOL)classSupportsSecureCoding
{
    return [self classSupportsNSCoding]
    && [self.propertyClass conformsToProtocol:@protocol(NSSecureCoding)]
    && [(Class<NSSecureCoding>)self.propertyClass supportsSecureCoding];
}

- (nullable NSString *)typeForNSCoder
{
    if ([self classSupportsNSCoding]) {
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
