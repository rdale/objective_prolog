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
#import "ListIterator.h"
#import "ListTerm.h"
#import "InfixExpression.h"
#import "VariableTerm.h"
#import "FunctionTerm.h"
#import "Binding.h"
#import "Goal.h"
#import "Unify.h"
#import "NestedStructureIterator.h"

@implementation NestedStructureIterator

- initList: aTerm in: anEnvironment functor: (NSString *) aName
{
	[super initList: aTerm in: anEnvironment];
	functionName = [aName retain];
	
	return self;
}

- first
{
	[super first];
	
	if (![self isDone]) {
		if ([self isNestedStructure: [self currentItem]]) {
			currentListTerm = [[self currentItem] listTerm];
			currentListEnvironment = currentEnvironment;
			index--;
			[super next];
		}
	}
	
	return self;
}

- next
{
	if ([currentListTerm tail] == nil) { 
		if ([self isNestedStructure: [self currentItem]]) {
			currentListTerm = [[self currentItem] listTerm];
			currentListEnvironment = currentEnvironment;
			index--;
		}
	}
	
	[super next];
		
	if ([currentListTerm tail] == nil) {
		if ([self isNestedStructure: [self currentItem]]) {
			currentListTerm = [[self currentItem] listTerm];
			currentListEnvironment = currentEnvironment;
			index--;
			[super next];
		}
	}
	
	return self;
}

- (BOOL) isLast
{
	id	binding;
	
	if ([[currentListTerm tail] isKindOfClass: [VariableTerm class]]) {
		binding = [currentListEnvironment getBinding: [currentListTerm tail]];
		
		return (	[super isLast]
					&& [binding isBound]
					&& ![self isNestedStructure: [binding reference]] );
	} else {
		return (	[super isLast]
					&& ![self isNestedStructure: [[currentListTerm tail] head]] );
	}
}

- (BOOL) isNestedStructure: anItem
{
	id	term;
	
	if ([anItem isKindOfClass: [Structure class]] ) {
		term = [anItem head];
		
		if ([term isKindOfClass: [VariableTerm class]]) {
			term = [[currentEnvironment getBinding: term] reference];
		}

		if (	[term respondsToSelector: @selector(functionName)]
			&& [[term functionName] isEqualToString: functionName] ) 
		{
			return YES;
		}
	}
	
	return NO;
}

- (void) dealloc
{
	[functionName release];
	return [super dealloc];
}

@end
