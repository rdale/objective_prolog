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
#import "Goal.h"
#import "Term.h"
#import "Binding.h"

@implementation Binding

- initBinding: aVariable environment: (Goal *) anEnvironment
{
    variableTerm = [aVariable retain];
    reference = self;
    environment = [anEnvironment retain];

    return self;
}

- (void) dealloc
{
    [variableTerm release];
    [environment release];
    [super dealloc];
}

- (NSString *) variableName
{
    return [variableTerm variableName];
}

- reference
{
    return reference;
}

- (Goal *) environment
{
    return environment;
}

- setReference: aReference
{
    assert(reference == self);

    reference = [aReference retain];
    return self;
}

- setEnvironment: (Goal *) anEnvironment;
{
    Goal * temp = environment;
    environment = [anEnvironment retain];
    [temp release];
    return self;
}

- dereference
{
    if (reference == self) {
        return self;
    } else if ([reference respondsToSelector: @selector(dereference)]) {
        return [reference dereference];
    } else {
        return self;
    }
}

- (BOOL) isBound
{
    return reference != self;
}

#ifdef    DEBUG
- unBind: (Goal *) anEnvironment output: (NSOutputStream *) stream
{
    [anEnvironment indent: stream];
    [stream printWithFormat: @"GOAL #%d: %@ restore -> _%ld\n", [anEnvironment goalSequence], [self variableName], (long) self];
#else
- unBind: (Goal *) anEnvironment
{
#endif

    environment = anEnvironment;
    reference = self;
    return self;
}

- printValue: (Goal *) anEnvironment output: (NSOutputStream *) stream
{
    if (reference == self) {
        [stream printWithFormat: @"_%ld", (long) self];
    } else if (reference == nil) {
        [stream printWithFormat: @"[]"];
    } else {
        [reference printValue: environment output: stream];
    }
    
    return self;
}

- (void) printForDebugger: (NSOutputStream *) stream
{
#ifdef    DEBUG
    if (reference == self) {
        [stream printWithFormat: @"GOAL #%d: %@ -> _%ld", [environment goalSequence], [self variableName], (long) self];
    } else if (reference == nil) {
        [stream printWithFormat: @"GOAL #%d: %@ -> []", [environment goalSequence]];
    } else {
        [stream printWithFormat: @"GOAL #%d: %@ -> ", [environment goalSequence], [self variableName]];
        [reference printValue: environment output: stream];
    }
#endif
    
    return;
}

@end