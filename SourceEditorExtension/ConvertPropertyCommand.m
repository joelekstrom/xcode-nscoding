//
//  SourceEditorCommand.m
//  SourceEditorExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "ConvertPropertyCommand.h"
#import "PropertyDeclaration.h"

@implementation ConvertPropertyCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
    if (selection == nil) {
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

@end
