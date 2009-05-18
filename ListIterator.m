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
#import "ListIterator.h"
#import "ListTerm.h"
#import "VariableTerm.h"
#import "FunctionTerm.h"
#import "Binding.h"
#import "Goal.h"
#import "Unify.h"

@implementation ListIterator

- initList: aList in: anEnvironment
{
    [super init];
    
    listTerm = [aList retain];
    initialEnvironment = [anEnvironment retain];
    
    currentListTerm = nil;
    currentListEnvironment = nil;
    
    currentItem = nil;
    currentEnvironment = nil;
    
    return self;
}


- (void) dealloc
{
    [listTerm release];
    [initialEnvironment release];
    [super dealloc];
}

- first
{
    currentListTerm = listTerm;
    currentListEnvironment = initialEnvironment;
    currentEnvironment = initialEnvironment;
    index = 0;
    
    return self;
}

- next
{
    Binding *    binding;

    currentListTerm = [currentListTerm tail];
    
    if ([currentListTerm isKindOfClass: [VariableTerm class]]) {
        binding = [currentListEnvironment getBinding: currentListTerm];
                
        if ([binding isBound]) {
            currentListTerm = [binding reference];
            currentListEnvironment = [binding environment];
            currentEnvironment = currentListEnvironment;
        }
    }
    
    index++;
    return self;
}

- objectAtIndex: (NSUInteger) anIndex
{
    if (index > anIndex) {
        [self first];
    }
    
    while (index < anIndex) {
        [self next];
        if ([self isDone]) {
            return nil;
        }
    }
    
    return [self currentItem];
}

- (BOOL) isLast
{
    id    binding;
    id    nextListTerm;
    
    if ([currentListTerm tail] == nil) {
        return YES;
    }
    
    if ([[currentListTerm tail] isKindOfClass: [VariableTerm class]]) {
        binding = [currentListEnvironment getBinding: [currentListTerm tail]];
        
        if ([binding isBound]) {
            nextListTerm = [binding reference];
            return (    ![nextListTerm isKindOfClass: [ListTerm class]]
                        || ([nextListTerm head] == nil && [nextListTerm tail] == nil) );
        } else {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) isDone
{
    return (    currentListTerm == nil
                || ![currentListTerm isKindOfClass: [ListTerm class]]
                || ([currentListTerm head] == nil && [currentListTerm tail] == nil) );
}

- currentItem
{
    Binding *    binding;

    if ([self isDone]) {
        return nil;
    }

    currentItem = [currentListTerm head];
    currentEnvironment = currentListEnvironment;
    
    if ([currentItem isKindOfClass: [VariableTerm class]]) {
        binding = [currentListEnvironment getBinding: currentItem];
                
        if ([binding isBound]) {
            currentItem = [binding reference];
            currentEnvironment = [binding environment];
        } 
    }
    
    return currentItem;
}

- (Goal *) currentEnvironment
{
    return currentEnvironment;
}

- currentListTerm
{
    return currentListTerm;
}

- currentListEnvironment
{
    return currentListEnvironment;
}

- (NSUInteger) index
{
    return index;
}

- (void) printForDebugger: (NSOutputStream *) stream;
{
    if ([self isDone]) {
        [stream printWithFormat: @"<undefined>"];
    } else {
        [stream printWithFormat: @"[%d]\t", index];
        [[self currentItem] printValue: [self currentEnvironment] output: stream];
    }
    
    return;
}

@end
