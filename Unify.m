/*
    Unify.m
    
    Author:    Richard Dale
    Date:    July 1997
    Copyright (c) 1993-2009 Richard Dale.
    
*/

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

#import "Binding.h"
#import "VariableTerm.h"
#import "ListTerm.h"
#import "NamedVariable.h"
#import "Structure.h"
#import "Clause.h"
#import "Prolog.h"
#import "Goal.h"
#import "Unify.h"
#import "NSOutputStream_Printf.h"

#define TRACE_UNIFY(TERM, GOAL, OTHERTERM, OTHERGOAL)    [self indent: [proofTree currentOutput]]; \
                                        [[proofTree currentOutput] printWithFormat: @"UNIFY: "]; \
                                        [term printForDebugger: [proofTree currentOutput]]; \
                                        [[proofTree currentOutput] printWithFormat: @" in GOAL #%d", [GOAL goalSequence]]; \
                                        [[proofTree currentOutput] printWithFormat: @" with "]; \
                                        [otherTerm printForDebugger: [proofTree currentOutput]]; \
                                        [[proofTree currentOutput] printWithFormat: @" in GOAL #%d", [OTHERGOAL goalSequence]]; \
                                        [[proofTree currentOutput] printWithFormat: @"\n"];
                                        
#define PRINT_BINDING_VALUE(BINDING)    [self indent: [proofTree currentOutput]]; \
                                        [[proofTree currentOutput] printWithFormat: @"%@ = ", variableTerm]; \
                                        [BINDING printValue: [BINDING environment] output: [proofTree currentOutput]]; \
                                        [[proofTree currentOutput] printWithFormat: @"\n"];
                                        
#define TRACE_TRAIL(BINDING)            [self indent: [proofTree currentOutput]]; \
                                        [[proofTree currentOutput] printWithFormat: @"TRAIL: "]; \
                                        [BINDING printForDebugger: [proofTree currentOutput]]; \
                                        [[proofTree currentOutput] printWithFormat: @"\n"];

@implementation Goal(Unify)

- (BOOL) isEqual: term in: (Goal *) goal with: otherTerm in: (Goal *) otherGoal
{
    Binding *        binding;
    Binding *        otherBinding;
        
    if ([term isKindOfClass: [VariableTerm class]]) {
        binding = [goal getBinding: term];
        
        if ([binding isBound]) {
            return [self isEqual: [binding reference] in: [binding environment] with: otherTerm in: otherGoal];
        } else {
            if ([otherTerm isKindOfClass: [VariableTerm class]]) {
                otherBinding = [otherGoal getBinding: otherTerm];
                
                if ([otherBinding isBound]) {
                    return [self isEqual: term in: goal with: [otherBinding reference] in: [otherBinding environment]];
                } else {
                    return [binding isEqual: otherBinding];
                }
            } else {
                return NO;
            }
        }
    } else if ([otherTerm isKindOfClass: [VariableTerm class]]) {
        otherBinding = [otherGoal getBinding: otherTerm];
                
        if ([otherBinding isBound]) {
            return [self isEqual: term in: goal with: [otherBinding reference] in: [otherBinding environment]];
        } else {
            return NO;
        }
    } else if ([term isKindOfClass: [Structure class]] && [otherTerm isKindOfClass: [Structure class]]) {
        return [    self 
                        isEqual: [term listTerm] 
                        in: goal 
                        with: [otherTerm listTerm] 
                        in: otherGoal ];
    } else if (    (term == nil || [term isKindOfClass: [ListTerm class]])
                && (otherTerm == nil || [otherTerm isKindOfClass: [ListTerm class]]) )
    {
        if (    (term == nil || [term head] == nil)
                || (otherTerm == nil || [otherTerm head] == nil) )
        {
            /*
             * If one term is nil, then the other term must also be nil
             */
            return     (term == nil || [term head] == nil)
                    && (otherTerm == nil || [otherTerm head] == nil);
        } else if (![self isEqual: [term head] in: goal with: [otherTerm head] in: otherGoal]) {
            return NO;
        } else {
            return [self isEqual: [term tail] in: goal with: [otherTerm tail] in: otherGoal];
        }
    } else {
        return [term isEqual: otherTerm];
    }
    
    return NO;
}

- (BOOL) unify: term in: (Goal *) goal with: otherTerm in: (Goal *) otherGoal
{
    Binding *        binding;
    Binding *        otherBinding;
    
#ifdef    DEBUG
    TRACE_UNIFY(term, goal, otherTerm, otherGoal);
#endif
        
    if ([term isKindOfClass: [VariableTerm class]]) {
        binding = [goal getBinding: term];
        
        if ([binding isBound]) {
            return [self unify: [binding reference] in: [binding environment] with: otherTerm in: otherGoal];
        } else {
            if ([otherTerm isKindOfClass: [VariableTerm class]]) {
                otherBinding = [otherGoal getBinding: otherTerm];
                
                if ([otherBinding isBound]) {
                    [self bind: binding to: [otherBinding reference] in: [otherBinding environment]];
                    return YES;
                } else {
                    [self bind: otherBinding to: binding in: goal];
                    return YES;
                }
            } else {
                [self bind: binding to: otherTerm in: otherGoal];
                return YES;
            }
        }
    } else if ([otherTerm isKindOfClass: [VariableTerm class]]) {
        otherBinding = [otherGoal getBinding: otherTerm];
                
        if ([otherBinding isBound]) {
            return [self unify: term in: goal with: [otherBinding reference] in: [otherBinding environment]];
        } else {
            [self bind: otherBinding to: term in: goal];
            return YES;
        }
    } else if ([term isKindOfClass: [Structure class]] && [otherTerm isKindOfClass: [Structure class]]) {
        return [    self 
                        unify: [term listTerm] 
                        in: goal 
                        with: [otherTerm listTerm] 
                        in: otherGoal ];
    } else if (    (term == nil || [term isKindOfClass: [ListTerm class]])
                && (otherTerm == nil || [otherTerm isKindOfClass: [ListTerm class]]) )
    {
        if (    (term == nil || [term head] == nil)
                || (otherTerm == nil || [otherTerm head] == nil) )
        {
            /*
             * If one term is nil, then the other term must also be nil
             */
            return     (term == nil || [term head] == nil)
                    && (otherTerm == nil || [otherTerm head] == nil);
        } else if (![self unify: [term head] in: goal with: [otherTerm head] in: otherGoal]) {
            return NO;
        } else {
            return [self unify: [term tail] in: goal with: [otherTerm tail] in: otherGoal];
        }
    } else {
        return [term isEqual: otherTerm];
    }
    
    return NO;
}

- bind: (Binding *) binding to: aReference in: (Goal *) anEnvironment
{
    
#ifdef    DEBUG
    if ([binding environment] != parentGoal && [binding environment] != self) {
        [self indent: [proofTree currentOutput]];
        [[proofTree currentOutput] printWithFormat: @"ERROR: "];
        [binding printForDebugger: [proofTree currentOutput]];
        [[proofTree currentOutput] printWithFormat: @"\n"];
    }
#endif
    
    if (binding == aReference) {
        return self;
    }
    
    if ([binding environment] != self) {
#ifdef    DEBUG
        TRACE_TRAIL(binding);
#endif
        [trail addObject: binding];
    }
    
    [binding setReference: aReference];
    [binding setEnvironment: anEnvironment];
    
#ifdef    DEBUG
    [self indent: [proofTree currentOutput]];
    [binding printForDebugger: [proofTree currentOutput]];
    [[proofTree currentOutput] printWithFormat: @"\n"];
#endif

    return self;
}

- getVariable: variableTerm
{
    id        binding;

    binding = [variableTable objectForKey: variableTerm];
    return [binding dereference];
}

- (Binding *) getBinding: variableTerm
{
    Binding *    binding;
    
    binding = [variableTable objectForKey: variableTerm];
    
    if (binding == nil) {
#ifdef    DEBUG
        [self indent: [proofTree currentOutput]];
        [[proofTree currentOutput] printWithFormat: @"GOAL #%d: Binding allocated for: %@\n", [self goalSequence], [variableTerm variableName]];
#endif
        binding = [[Binding alloc] initBinding: variableTerm environment: self];
        [variableTable setObject: binding forKey: variableTerm];
    }
    
    return [binding dereference];
}

- printVariable: variableTerm output: (NSOutputStream *) stream
{
    [[self getVariable: variableTerm] printValue: self output: stream];
    return self;
}

- (int) printVariables
{
    Binding *        binding;
    NSInteger        count;
    
    count = 0;
    for (id variableTerm in variableTable) {
        binding = [variableTable objectForKey: variableTerm];
        if ([variableTerm isKindOfClass: [NamedVariable class]]) {
            count++;            
            PRINT_BINDING_VALUE(binding);
        }
    }
        
    return count;
}

@end
