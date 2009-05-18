//
//  NSOutputStream(Printf).m
//  ObjcProlog
//
//  Created by Richard Dale on 5/6/09.
//  Copyright 2009 Foton Sistemas Inteligentes. All rights reserved.
//

#import "NSOutputStream(Printf).h"


@implementation NSOutputStream (Printf)

- printWithFormat: (NSString *) format, ...
{
    va_list args;
    va_start(args, format);
    NSString * temp = [[NSString alloc] initWithFormat: format arguments: args];
    const char * buffer = [temp cStringUsingEncoding: NSASCIIStringEncoding];
    va_end(args);
    [self write: (const uint8_t *) buffer maxLength: strlen(buffer)];
    [temp release];
    return self;
}

@end
