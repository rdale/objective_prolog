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

#import "prolog.h"
#import "Term.h"
#import "Goal.h"
#import "ListTerm.h"
#import "FunctionTerm.h"

@implementation  FunctionTerm

- initFunction: (NSString *) name
{
	NSString *		methodName;
	
	[super init];
	functionName = [name retain];
	
	methodName = [NSString stringWithFormat: @"_%@", name];
	selectorForPredicate = NSSelectorFromString(methodName);
	[methodName release];
	
	return self;
}

- (NSString *) functionName
{
	return functionName;
}

- (SEL) selectorForPredicate
{
	return selectorForPredicate;
}

- (BOOL) isEqual: value
{
	if ([value respondsToSelector: @selector(functionName)]) {
		return [[self functionName] isEqualToString: [value functionName]];
	} else {
		return NO;
	}
}

- printValue: goal output: (NSOutputStream *) stream;
{
	[self printForDebugger: stream];
	return self;
}

- (void) printForDebugger: (NSOutputStream *) stream;
{
	if (	[[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember: [functionName characterAtIndex: 0]]
			|| [functionName isEqualToString: LIST_FUNCTOR] ) 
	{
		[stream printWithFormat: @"'%@'", functionName];
	} else {
		[stream printWithFormat: @"%@", functionName];
	}

	return;
}

- (void) dealloc
{
	[functionName release];
	[super dealloc];
}

@end
