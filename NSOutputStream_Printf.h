//
//  NSOutputStream(Printf).h
//  ObjcProlog
//
//  Created by Richard Dale on 5/6/09.
//  Copyright 2009 Foton Sistemas Inteligentes. All rights reserved.
//

#import <Foundation/NSStream.h>
#import <Foundation/NSString.h>


@interface NSOutputStream (Printf)
- printWithFormat: (NSString *) format, ...;
@end
