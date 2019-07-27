/*
    Goal.h
    
    Author:    Richard Dale
    Date:    Feb 1993
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

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>

#import "NSOutputStream_Printf.h"

enum ProofState {
    START_PROOF,
    CALL_SYSTEM_PREDICATE,
    TRY_CLAUSE,
    PROVE_HEAD,
    PROVE_BODY,
    ALWAYS_FAIL,
};

typedef enum ProofState    ProofState;

@class    Clause;
@class    ListIterator;
@class    NestedStructureIterator;
@class    Prolog;
@class    ProofTree;

@interface Goal : NSObject
/*----------------------------------------------------------
 *    Goal Instance Variables
 *
 *    - goalSequence
 *        - each goal is given a unique sequence number. It is used to check if
 *            a goal is more recent than another, and consequently whether or not
 *            a binding instantiation should be trailed. 
 *    - proofTree
 *        This object contains global state infomation about the proof tree. It is
 *            used to return the next goal sequence number.
 *    - parentGoal
 *        - the goal immediately above in the proof tree
 *    - parentTermIterator
 *        - contains the goal whose variables are to be bound against,
 *            and the term containing the variables.
 *    - systemPredicate, argIterator
 *        - a builtin predicate to call and a list iterator for convenient
 *            access to the arguments
 *    - proofState
 *        - START_PROOF
 *            - retrieve the clauses for a relation from the database
 *        - CALL_SYSTEM_PREDICATE
 *            - call a built-in predicate
 *        - TRY_CLAUSE
 *            - get the next clause for the relation.
 *        - PROVE_HEAD
 *            - unify the head of the current clause with the current term in the
 *                parent goal.
 *        - PROVE_BODY
 *            - try prove the subgoals in a clause, return all solutions until the
 *                clause fails.
 *        - ALWAYS_FAIL
 *            - used for goals which can only succeed once. They succeed and then set the
 *                proofState to ALWAYS_FAIL.
 *    - relation
 *        - the list of alternative clauses in the database to match against.
 *    - currentClause, clause
 *        - the index within the list of alternatives for the current clause,
 *            and the clause itself
 *    - currentTerm, termIterator
 *        - the index of the current term within the body of the clause, and
 *            an iterator to access it.
 *    - subGoals
 *        - a list of sub-goals tried.
 *    - variableTable
 *        - a hash table of variable names against current variable bindings.
 *    - localStorage
 *        - storage allocated by the built in predicates
 *    - trail
 *        - a hash table of variable names against former variable bindings.
 *----------------------------------------------------------*/
 {
    int                         goalSequence;
    ProofTree *                 proofTree;
    Goal *                      parentGoal;
    NestedStructureIterator *   parentTermIterator;
    SEL                         systemPredicate;
    ListIterator *              argIterator;
    ProofState                  proofState;
    NSMutableArray *            relation;
    int                         currentClause;
    Clause *                    clause;
    int                         currentTerm;
    NestedStructureIterator *   termIterator;
    NSMutableArray *            subGoals;
    NSMutableDictionary *       variableTable;
    NSMutableArray *            localStorage;
    NSMutableArray *            trail;
    int                         currentDepth;
}

- initGoal: aRelation proofTree: aProofTree parent: aGoal goalDepth: (int) depth;
- (void) reset;
- (void) fail;
- store: localObject;
- (void) dealloc;

- (BOOL) prove: anIterator    lastGoal: (BOOL) isLastGoal;
- (void) continue;

- (int) printResults;
- indent: (NSOutputStream *) stream;
- (void) printForDebugger: (NSOutputStream *) stream;

- (NSString *) proofStateToString;
- setProofState: (ProofState) aState;
- (ProofState) proofState;

- (int) goalSequence;
- dereference;
- parentGoal;
- parentTermIterator;

@end
