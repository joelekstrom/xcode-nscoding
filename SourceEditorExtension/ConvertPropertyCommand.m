//
//  SourceEditorCommand.m
//  SourceEditorExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "ConvertPropertyCommand.h"
#import "PropertyDeclaration.h"
#import <AppKit/AppKit.h>

@implementation ConvertPropertyCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
    if (selection == nil) {
        completionHandler(nil);
        return;
    }

    if ([invocation.commandIdentifier hasSuffix:@"copyToPasteboard"]) {
        [self copyNSCodingImplementationsToPasteboardForSelection:selection withInvocation:invocation];
        completionHandler(nil);
        return;
    }

    for (NSInteger i = selection.start.line; i < selection.end.line; i++) {
        NSString *line = invocation.buffer.lines[i];
        PropertyDeclaration *declaration = [[PropertyDeclaration alloc] initWithString:line];
        if (declaration == nil) {
            continue;
        }

        NSString *convertedString = nil;
        if ([invocation.commandIdentifier hasSuffix:@"encodePropertyCommand"]) {
            convertedString = [declaration stringForEncodingWithNSCoder];
        } else {
            convertedString = [declaration stringForInitializingWithNSCoder];
        }

        if (convertedString) {
            NSString *leadingWhitespace = [line substringWithRange:[line rangeOfString:@"^(\\s*)" options:NSRegularExpressionSearch]];
            invocation.buffer.lines[i] = [leadingWhitespace stringByAppendingString:convertedString];
        }
    }

    completionHandler(nil);
}

- (void)copyNSCodingImplementationsToPasteboardForSelection:(XCSourceTextRange *)selection withInvocation:(XCSourceEditorCommandInvocation *)invocation
{
    NSMutableArray *declarations = [NSMutableArray new];
    for (NSInteger i = selection.start.line; i < selection.end.line; i++) {
        NSString *line = invocation.buffer.lines[i];
        PropertyDeclaration *declaration = [[PropertyDeclaration alloc] initWithString:line];
        if (declaration) {
            [declarations addObject:declaration];
        }
    }

    if (declarations.count == 0) {
        return;
    }

    NSMutableString *result = [[NSMutableString alloc] initWithString:@"- (instancetype)initWithCoder:(NSCoder *)aDecoder {\n"];
    NSString *indentation = [self singleIndentationForBuffer:invocation.buffer];

    [result appendFormat:@"%@if (self = [super init]) {\n", indentation];
    for (PropertyDeclaration *declaration in declarations) {
        NSString *line = [declaration stringForInitializingWithNSCoder];
        if (line) {
            [result appendFormat:@"%@%@%@\n", indentation, indentation, line];
        }
    }

    [result appendFormat:@"%@}\n%@return self;\n}\n\n- (void)encodeWithCoder:(NSCoder *)aCoder {\n", indentation, indentation];
    for (PropertyDeclaration *declaration in declarations) {
        NSString *line = [declaration stringForEncodingWithNSCoder];
        if (line) {
            [result appendFormat:@"%@%@%@\n", indentation, indentation, line];
        }
    }
    [result appendString:@"}\n"];

    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[[result copy]]];
}

- (NSString *)singleIndentationForBuffer:(XCSourceTextBuffer *)buffer
{
    if (buffer.usesTabsForIndentation) {
        return @"\t";
    }

    return [@"" stringByPaddingToLength:buffer.indentationWidth withString:@" " startingAtIndex:0];
}

@end
