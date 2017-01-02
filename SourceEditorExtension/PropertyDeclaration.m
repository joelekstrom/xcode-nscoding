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
        NSString *pattern = @"^\\s*@property\\s*(\\([a-z,\\s]*\\)|\\s+)\\s*(\\w+)\\s*(\\s*\\*\\s*|\\s+)\\s*(\\w+)\\s*;";

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
    }
    return self;
}

@end
