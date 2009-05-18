/*
    Goal.m
    
    Author:    Richard Dale
    Date:    Feb 1993
    Copyright (c) 1993-2009 Richard Dale.
    
*/

#import <ctype.h>

#import "prolog.h"
#import "FunctionTerm.h"
#import "VariableTerm.h"
#import "NamedVariable.h"
#import "ListTerm.h"
#import "NestedStructureIterator.h"
#import "Structure.h"
#import "Clause.h"
#import "ProofTree.h"
#import "Prolog.h"
#import "Goal.h"
#import "Unify.h"

#define TRACE_PROOF(PORT, TERM, ENVIRONMENT)            if ([[proofTree database] traceOption] && TERM != nil) { \
                                                            [[proofTree currentOutput] printWithFormat: @"(%d) %@: ", [ENVIRONMENT goalSequence], PORT]; \
                                                            [TERM printValue: ENVIRONMENT output: [proofTree currentOutput]]; \
                                                            [[proofTree currentOutput] printWithFormat: @"\n"]; \
                                                        }

@implementation Goal
 
- initGoal: aRelation proofTree: aProofTree parent: aGoal goalDepth: (int) depth;
{
    [super init];
    
    proofTree = aProofTree;
    goalSequence = [proofTree nextGoalSequence];
    parentGoal = aGoal;
    relation = aRelation;
    proofState = START_PROOF;
    currentClause = -1;
    subGoals = [[NSMutableArray alloc] init];
    variableTable = [[NSMutableDictionary alloc] init];
    trail = [[NSMutableArray alloc] init];
    currentDepth = depth;
    
    return self;
}

- (void) reset
{
    [subGoals makeObjectsPerformSelector: @selector(reset)];
    [self fail];
    parentTermIterator = nil;
    relation = nil;
    proofState = START_PROOF;
    currentClause = -1;
    
    return;
}

- (void) fail
{
    unsigned int    index;
    unsigned int    count;
    
    for (index = 0, count = [trail count]; index < count; index++) {
#ifdef    DEBUG
        [[trail objectAtIndex: index] unBind: parentGoal output: [proofTree currentOutput]];
#else
        [[trail objectAtIndex: index] unBind: parentGoal];
#endif
    }
    
    [trail removeAllObjects];
    [variableTable removeAllObjects];
    
#ifdef    DEBUG
    if ([localStorage count] > 0) {
        [[proofTree currentOutput] printWithFormat: @"freeing store:\n"];
        [localStorage makeObjectsPerformSelector: @selector(printForDebugger:) with: (id) [proofTree currentOutput]];
        [[proofTree currentOutput] printWithFormat: @"\n"];
    }
#endif
    
    [localStorage removeAllObjects];
    
    if (argIterator != nil) {
        [argIterator release];
        argIterator = nil;
    }
    
    if (termIterator != nil) {
        [termIterator release];
        termIterator = nil;
    }
                    
    return;
}

- store: localObject
{
    if (localStorage == nil) {
        localStorage = [[NSMutableArray alloc] init];
    }
    
    [localStorage addObject: localObject];
    [localObject retain];
    
#ifdef    DEBUG
    [[proofTree currentOutput] printWithFormat: @"store:\n"];
    [localObject printForDebugger: [proofTree currentOutput]];
    [[proofTree currentOutput] printWithFormat: @"\n"];
#endif

    return localObject;
}

- (void) dealloc
{
    [self fail];
    
    [subGoals removeAllObjects];
    [subGoals release];
    [variableTable release];
    [localStorage release];
    [trail release];
    [super dealloc];
}

- (BOOL) prove: anIterator lastGoal: (BOOL) isLastGoal
{
    parentTermIterator = anIterator;
    
    if (proofState == START_PROOF) {
        TRACE_PROOF("CALL", [parentTermIterator currentItem], [parentTermIterator currentEnvironment]);
    } else {
        TRACE_PROOF("REDO", [parentTermIterator currentItem], [parentTermIterator currentEnvironment]);
    }
    
    for (;;) {
        switch (proofState) {
        case (int) START_PROOF:
            if ([[parentTermIterator currentItem] isKindOfClass: [VariableTerm class]]) {
                return NO;
            } else if ([[parentTermIterator currentItem] isKindOfClass: [FunctionTerm class]]) {
                systemPredicate = [[parentTermIterator currentItem] selectorForPredicate];
                if ([self respondsToSelector: systemPredicate]) {
                    [proofTree nextInferenceCount];
                    
                    if ([self performSelector: systemPredicate] != nil) {
                        if (isLastGoal) {
                            [self continue];
                        } else {
                            return YES;
                        }
                    } else {
                        return NO;
                    }
                }
            } else if ([[parentTermIterator currentItem] isKindOfClass: [Structure class]]) {
                argIterator = [[[parentTermIterator currentItem] listTerm] createIterator: [parentTermIterator currentEnvironment]];
                systemPredicate = [[[argIterator first] currentItem] selectorForPredicate];
                
                if ([self respondsToSelector: systemPredicate]) {
                    [proofTree nextInferenceCount];
                    
                    if ([self performSelector: systemPredicate] != nil) {
                        if (isLastGoal) {
                            [self continue];
                        } else {
                            return YES;
                        }
                    } else {
                        return NO;
                    }
                }
            }

            if (relation == nil) {
                relation = [[proofTree database] findRelation: [[parentTermIterator currentItem] functionName]];
            }
            
            if (relation == nil) {
                return NO;
            }
            
            proofState = TRY_CLAUSE;
            break;

        case CALL_SYSTEM_PREDICATE:
            [proofTree nextInferenceCount];
            
            if ([self performSelector: systemPredicate] != nil) {
                if (isLastGoal) {
                    [self continue];
                } else {
                    return YES;
                }
            } else {
                return NO;
            }
            break;

        case (int) TRY_CLAUSE:
            {
                id                variableTerm;
                
                [self fail];
                
                currentClause++;
                if (currentClause < [relation count]) {
                    clause = [relation objectAtIndex: currentClause];
                } else {
                    return NO;
                }
                
                [proofTree nextInferenceCount];
                
                for (id key in [clause variableTable]) {
                    variableTerm = [[clause variableTable] objectForKey: key];
                    [self getBinding: variableTerm];
                }
                    
                if ([clause body] != nil) {
                    termIterator = [clause createIterator: self];
                    [termIterator first];
                    currentTerm = [termIterator index];
                }
                
                if ([clause headTerm] != nil) {
                    proofState = PROVE_HEAD;
                } else {
                    proofState = PROVE_BODY;
                }
            }
            break;
            
        case (int) PROVE_HEAD:
            if (![self unify: [clause headTerm] in: self with: [parentTermIterator currentItem] in: [parentTermIterator currentEnvironment]]) {
                proofState = TRY_CLAUSE;
            } else {
                if (termIterator == nil || [termIterator isDone]) {
                    proofState = TRY_CLAUSE;
                    
                    if (isLastGoal) {
                        [self continue];
                    } else {
                        return YES;
                    }
                } else {
                    proofState = PROVE_BODY;
                }
            }
            break;
            
        case (int) PROVE_BODY:
            {
                id        subGoal;
                (void) [termIterator objectAtIndex: currentTerm];
                if (currentTerm < [subGoals count]) {
                    subGoal = [subGoals objectAtIndex: currentTerm];
                } else {
                    subGoal = nil;
                }
                
                if (subGoal == nil) {
                    subGoal = [[Goal alloc] initGoal: nil proofTree: proofTree parent: self goalDepth: currentDepth + 1];
                    [subGoals addObject: subGoal];
                }
                
                if ([subGoal prove: termIterator lastGoal: isLastGoal && [termIterator isLast]]) {
                    TRACE_PROOF("EXIT", [termIterator currentItem], [termIterator currentEnvironment]);
                    if ([termIterator isLast]) {
                        return YES;
                    } else {
                        currentTerm++;
                    }
                } else {
                    [subGoal reset];
                    TRACE_PROOF("FAIL", [termIterator currentItem], [termIterator currentEnvironment]);
                    
                    if (proofState == ALWAYS_FAIL && [parentGoal proofState] == PROVE_BODY) {
                            // An attempt has just been made to backtrack through a �cut� subgoal.
//                        [parentGoal setProofState: ALWAYS_FAIL];
                    } else if (currentTerm == 0) {
                        proofState = TRY_CLAUSE;
                    } else {
                        currentTerm--;
                    }
                }
            }
            break;
            
        case (int) ALWAYS_FAIL:
            return NO;
        }
    }
}

- (void) continue
{
    if ([[proofTree database] traceOption]) {
        id    goal;
        
        for (goal = self; goal != nil; goal = [goal parentGoal]) {
            TRACE_PROOF("EXIT", [[goal parentTermIterator] currentItem], [[goal parentTermIterator] currentEnvironment]);
        }
    }
    
    [proofTree continue];
}

- (int) printResults
{
    [proofTree nextSolutionCount];
    return [self printVariables];
}

- indent: (NSOutputStream *) stream
{
    int    depth;
    
    for (depth = currentDepth; depth > 0; depth--) {
        [stream printWithFormat: @"    "];
    }
    
    return self;
}

- (void) printForDebugger: (NSOutputStream *) stream
{
    Binding *        binding;
    
    [stream printWithFormat: @"\n"];
    [self indent: stream];
    [stream printWithFormat: @"GOAL #%d:\n", goalSequence];
    
    [self indent: stream];
    [stream printWithFormat: @"parent goalSequence: %d\n", [parentGoal goalSequence]];
    
    [self indent: stream];
    [stream printWithFormat: @"proofState: %@\n", [self proofStateToString]];
    
    [self indent: stream];
    [stream printWithFormat: @"relation:\n\n"];
    
    for (NSUInteger i = 0; i <  [relation count]; i++) {
        [[relation objectAtIndex: i] printForDebugger: stream];
    }
    
    [stream printWithFormat: @"\n"];
    
    [self indent: stream];
    [stream printWithFormat: @"[parentTermIterator currentItem]:\n\t", currentClause];
    [parentTermIterator printForDebugger: stream];
    [stream printWithFormat: @"\n\n"];
    
    [self indent: stream];
    [stream printWithFormat: @"currentClause: \n[%d]\t", currentClause];
    [[relation objectAtIndex: currentClause] printForDebugger: stream];
    [stream printWithFormat: @"\n"];
    
    [self indent: stream];
    [stream printWithFormat: @"currentTerm:\n"];
    [termIterator printForDebugger: stream];
    [stream printWithFormat: @"\n\n"];
    
    [self indent: stream];
    [stream printWithFormat: @"variableTable:\n"];
    
    for (id variableTerm in variableTable) {
        binding = [variableTable objectForKey: variableTerm];
        if ([variableTerm isKindOfClass: [NamedVariable class]]) {
            [self indent: stream];
            [stream printWithFormat: @"    "];
            [binding printForDebugger: stream];
            [stream printWithFormat: @"\n"];
        }
    }
    
    return;
}

- (NSString *) proofStateToString
{
    switch (proofState) {
    case START_PROOF:
        return @"START_PROOF";

    case CALL_SYSTEM_PREDICATE:
        return @"CALL_SYSTEM_PREDICATE";
        
    case TRY_CLAUSE:
        return @"TRY_CLAUSE";
        
    case PROVE_HEAD:
        return @"PROVE_HEAD";
        
    case PROVE_BODY:
        return @"PROVE_BODY";
        
    case ALWAYS_FAIL:
        return @"ALWAYS_FAIL";
        
    default:
        return @"<undefined>";
    }
}

- setProofState: (ProofState) aState
{
    proofState = aState;
    return self;
}

- (ProofState) proofState
{
    return proofState;
}

- (int) goalSequence
{
    return goalSequence;
}

- dereference
{
    if (parentGoal == nil) {
        return self;
    } else {
        return [parentGoal dereference];
    }
}

- parentGoal
{
    return parentGoal;
}

- parentTermIterator
{
    return parentTermIterator;
}

@end