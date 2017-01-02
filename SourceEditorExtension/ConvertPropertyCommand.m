//
//  SourceEditorCommand.m
//  SourceEditorExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "ConvertPropertyCommand.h"
#import "PropertyDeclaration.h"

NSString * const NSCodingEncodeFormat = @"%@[aCoder encode%@:self.%@ forKey:NSStringFromSelector(@selector(%@))];";
NSString * const NSSecureCodingDecodeFormat = @"%@self.%@ = [aDecoder decodeObjectOfClass:[%@ class] forKey:NSStringFromSelector(@selector(%@))];";
NSString * const NSCodingDecodeFormat = @"%@self.%@ = [aDecoder decode%@ForKey:NSStringFromSelector(@selector(%@))];";

@implementation ConvertPropertyCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
    if (selection == nil) {
        completionHandler(nil);
        return;
    }

    NSString *indentationString = [self indentationStringForBuffer:invocation.buffer];

    for (NSInteger i = selection.start.line; i < selection.end.line; i++) {
        PropertyDeclaration *declaration = [[PropertyDeclaration alloc] initWithString:invocation.buffer.lines[i]];
        if (declaration == nil) {
            continue;
        }

        NSString *mappedType = [self NSCoderTypeNameForProperty:declaration];
        if ([invocation.commandIdentifier hasSuffix:@"encodePropertyCommand"] && mappedType) {
            invocation.buffer.lines[i] = [NSString stringWithFormat:NSCodingEncodeFormat, indentationString, mappedType, declaration.name, declaration.name];
        } else {
            // Use NSSecureCoding if a class exists for this pointer type
            if (declaration.isPointer && NSClassFromString(declaration.type)) {
                invocation.buffer.lines[i] = [NSString stringWithFormat:NSSecureCodingDecodeFormat, indentationString, declaration.name, declaration.type, declaration.name];
            } else if (mappedType) {
                invocation.buffer.lines[i] = [NSString stringWithFormat:NSCodingDecodeFormat, indentationString, declaration.name, mappedType, declaration.name];
            }
        }
    }

    completionHandler(nil);
}

- (NSString *)indentationStringForBuffer:(XCSourceTextBuffer *)buffer
{
    NSMutableString *string = [NSMutableString new];
    for (NSInteger i = 0; i < buffer.indentationWidth; i++) {
        [string appendString:buffer.usesTabsForIndentation ? @"\t" : @" "];
    }
    return string;
}

// Returns a mapping to NSCoder types for PropertyDeclarations. For example, an NSInteger-property
// should be encoded using encodeInteger:, while id and pointers should use encodeObject:
- (NSString *)NSCoderTypeNameForProperty:(PropertyDeclaration *)declaration
{
    // If the property declaration is a pointer, do encodeObject: if a class exists for that type. Also do
    // encodeObject: if the type is "id" since that is also a pointer.
    if ((declaration.isPointer && NSClassFromString(declaration.type)) || [declaration.type isEqualToString:@"id"]) {
        return @"Object";
    } else if ([declaration.type isEqualToString:@"NSInteger"]) {
        return @"Integer";
    } else if ([declaration.type isEqualToString:@"BOOL"]) {
        return @"Bool";
    }
    return nil;
}

@end
