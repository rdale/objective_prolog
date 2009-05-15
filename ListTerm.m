/*
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

#include <assert.h>

#import "prolog.h"
#import "Term.h"
#import "ListTerm.h"
#import "ListIterator.h"
#import "VariableTerm.h"
#import "FunctionTerm.h"
#import "Binding.h"
#import "Goal.h"

@implementation ListTerm

- init
{
	[super init];
	return self;
}

- initTerm: listHead tail: (ListTerm *) listTail
{
	[super init];

	[self setHead: listHead];
	[self setTail: listTail];
	
	return self;
}

- (void) dealloc
{
	[head release];
	[tail release];
	[super dealloc];
}

- createIterator: environment
{
	return [[ListIterator alloc] initList: self in: environment];
}

- head
{
	return head;
}

- setHead: aHead
{
	if (head != nil) {
		[head release];
	}

	head = aHead;
	[head retain];
	return self;
}

- tail
{
	return tail;
}

- setTail: aTail
{
	if (tail != nil) {
		[tail release];
	}
	
	tail = aTail;
	[tail retain];
	return self;
}


- (void) printForDebugger: (NSOutputStream *) stream
{
	[stream printWithFormat: @"["];
	[self printContentsValue: nil output: stream];
	[stream printWithFormat: @"]"];
	
	return;
}

- printContentsForDebugger: (NSOutputStream *) stream
{
	return [self printContentsValue: nil output: stream];
}

- printContentsValue: goal output: (NSOutputStream *) stream
{
	id		iterator;
	
	iterator = [self createIterator: goal];
	[iterator first];
	
	if (![iterator isDone]) {
		if ([iterator currentItem] == nil) {
			[stream printWithFormat: @"[]"];
		} else {
			[[iterator currentItem] printValue: [iterator currentEnvironment] output: stream];
		}
		
		[iterator next];
		
		while (![iterator isDone]) {
			[stream printWithFormat: @", "];
				
			if ([iterator currentItem] == nil) {
				[stream printWithFormat: @"[]"];
			} else {
				[[iterator currentItem] printValue: [iterator currentEnvironment] output: stream];
			}
			
			[iterator next];
		}
		
		if ([iterator currentListTerm] != nil && ![[iterator currentListTerm] isKindOfClass: [ListTerm class]]) {		
				[stream printWithFormat: @" | "];
				[[iterator currentListTerm] printValue: [iterator currentListEnvironment] output: stream];
		}	
	}
	
	[iterator release];
	
	return self;
}

- printValue: goal output: (NSOutputStream *) stream
{
	[stream printWithFormat: @"["];
	[self printContentsValue: goal output: stream];
	[stream printWithFormat: @"]"];
	
	return self;
}

@end
