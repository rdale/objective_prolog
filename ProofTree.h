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

#include <setjmp.h>

#import "Clause.h"
#import "Goal.h"
#import "Unify.h"
#import "Prolog.h"

#define STANDARD_FILENAME            @"user"


/*
 *    - database
 *        - a prolog world containing a database of compiled relations.
 */

@interface ProofTree: NSObject

{
    Prolog *            database;
    id                  queryGoal;
    id                  queryPredicate;
    jmp_buf             continuation;
    
    NSInputStream *     currentInput;
    NSString *          currentInputName;
    int                 currentInputFd;
    
    NSOutputStream *    currentOutput;
    NSString *          currentOutputName;
    int                 currentOutputFd;
    
    long                elapsedTime;
    NSInteger           sequence;
    NSInteger           inferenceCount;
    NSInteger           solutionCount;
}

- initQuery: queryClause database: aDatabase tracing: (BOOL) traceOption;
- (BOOL) getSolution;
- (void) continue;

- (Prolog *) database;

- (BOOL) setCurrentInput: (NSString *) filename;
- (NSInputStream *) currentInput;
- (NSString *) currentInputName;
- (BOOL) setCurrentOutput: (NSString *) filename;
- (NSOutputStream *) currentOutput;
- (NSString *) currentOutputName;

- (NSInteger) nextGoalSequence;
- (NSInteger) nextInferenceCount;
- (NSInteger) nextSolutionCount;

- (void) printForDebugger: (NSOutputStream *) stream;
- printStatistics;

- (void) dealloc;

@end