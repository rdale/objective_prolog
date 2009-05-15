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

#import <assert.h>

#import "prolog.h"
#import "Structure.h"

@implementation Structure

- init
{
	return [self initHead: @"," tail: nil];
}

- initHead: (NSString *) aString
{
	return [self initHead: aString tail: nil];
}

- initHead: (NSString *) aString tail: aTerm
{
	return [self initTerm: [[FunctionTerm alloc] initFunction: aString] tail: aTerm];
}

- initTerm: aTerm tail: anotherTerm
{
	return [self initList: [[ListTerm alloc] initTerm: aTerm tail: anotherTerm]];
}

- initList: aListTerm
{
	[super init];
	listTerm = [aListTerm retain];
	
	return self;
}

- (void) dealloc
{
	[listTerm release];
	[super dealloc];
}

- (ListTerm *) listTerm
{
	return listTerm;
}	

- createIterator: environment
{
	return [listTerm createIterator: environment];
}

- (NSString *) functionName
{
	if ([[listTerm head] respondsToSelector: @selector(functionName)]) {
		return [[listTerm head] functionName];
	}
	
	// [self doesNotRecognize: @selector(functionName)];
	return nil;
}

- head
{
	return [listTerm head];
}

- setHead: aTerm
{
	return [listTerm setHead: aTerm];
}

- tail
{
	return [listTerm tail];
}

- setTail: aTerm
{
	return [listTerm setTail: aTerm];
}

- (void) printForDebugger: (NSOutputStream *) stream
{
	[self printValue: nil output: stream];
	return;
}

- printValue: goal output: (NSOutputStream *) stream
{
	id	iterator;
		
	iterator = [listTerm createIterator: goal];
	[iterator first];
	 
	if (![iterator isDone]) {
		[[iterator currentItem] printValue: [iterator currentEnvironment] output: stream];
		[iterator next];
	}
	
	if (![iterator isDone]) {
		[stream printWithFormat: @"("];
		
		if ([iterator currentListTerm] == nil) {
			[stream printWithFormat: @"[]"];
		} else {
			[[iterator currentListTerm] printContentsValue: [iterator currentListEnvironment] output: stream];
		}
		
		[stream printWithFormat: @")"];
	}
	
	[iterator release];
	return self;
}

@end