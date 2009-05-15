//
//  NSOutputStream(Printf).h
//  ObjcProlog
//
//  Created by Richard Dale on 5/6/09.
//  Copyright 2009 Foton Sistemas Inteligentes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSOutputStream (Printf)
- printWithFormat: (NSString *) format, ...;
@end
