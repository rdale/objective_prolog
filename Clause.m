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
#import "ListTerm.h"
#import "FunctionTerm.h"
#import "VariableTerm.h"
#import "NamedVariable.h"
#import "NumericTerm.h"
#import "Structure.h"
#import "NestedStructureIterator.h"
#import "Clause.h"

@implementation Clause

- initTerm: aTerm tail: anotherTerm
{
	[super initTerm: aTerm tail: anotherTerm];
	
	return self;
}

- (void) dealloc
{	
	[variableTable removeAllObjects];
	[variableTable release];
	[super dealloc];
}

- createIterator: environment
{
	return [[NestedStructureIterator alloc] initList: [self body] in: environment functor: @","];
}

- headTerm
{
	if (	[[[listTerm head] functionName] isEqualToString: @":-"]
			|| [[[listTerm head] functionName] isEqualToString: @"?-"] ) 
	{
		return [[listTerm tail] head];
	} else {
		return [listTerm head];
	}
}

- body
{
	if (	[[[listTerm head] functionName] isEqualToString: @":-"]
		|| [[[listTerm head] functionName] isEqualToString: @"?-"] ) 
	{
		return [[listTerm tail] tail];
	} else {
		return [listTerm tail];
	}
}

- variableTable
{
	return variableTable;
}

- addNamedVariable: (NSString *) name
{
	if ([variableTable objectForKey: name] == nil) {
		[variableTable setValue: [[[NamedVariable alloc] initVariable: name] retain] forKey: name];
	}
	
	return [[variableTable objectForKey: name] retain];
}

- setVariableTable: (NSMutableDictionary *) variables;
{
	variableTable = variables;
	return self;
}

- (void) printForDebugger: (NSOutputStream *) stream;
{
	if ([self headTerm] != nil) {
		[[self headTerm] printForDebugger: stream];
		[stream printWithFormat: @" "];
	}
	
	[[listTerm head] printForDebugger: stream];
	
	if ([self body] != nil) {
		[stream printWithFormat: @" "];
		[[self body] printContentsValue: nil output: stream];
	}
	
	[stream printWithFormat: @".\n"];

	return;
}

@end
