//
//  SourceEditorExtension.m
//  SourceEditorExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "SourceEditorExtension.h"

@implementation SourceEditorExtension


- (void)extensionDidFinishLaunching
{
    NSLog(@"Extension did load");
}

/*
- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions
{
    // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
    return @[@{XCSourceEditorCommandNameKey: @"helur?", XCSourceEditorCommandIdentifierKey: @"derp", XCSourceEditorCommandClassNameKey: @"SourceEditorCommand"}];
}
*/

@end
