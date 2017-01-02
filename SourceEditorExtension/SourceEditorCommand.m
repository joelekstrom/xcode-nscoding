//
//  SourceEditorCommand.m
//  SourceEditorExtension
//
//  Created by Joel Ekström on 2017-01-02.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    NSMutableArray *encodingLines = [NSMutableArray new];
    NSMutableArray *decodingLines = [NSMutableArray new];

    for (NSString *line in invocation.buffer.lines) {
        NSLog(@"%@", line);
    }
    
    completionHandler(nil);
}

@end
