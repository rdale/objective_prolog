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

#import "ProofTree.h"

#include <sys/types.h>
#include <sys/timeb.h>

extern int    ftime(struct timeb * tp);

@implementation ProofTree

- initQuery: queryClause database: aDatabase tracing: (BOOL) traceOption
{
    database = [aDatabase retain];
    sequence = 0;
    inferenceCount = 0;
    solutionCount = 0;
    elapsedTime = 0;
    currentInputName = [NSString stringWithString: STANDARD_FILENAME];
    currentOutputName = [NSString stringWithString: STANDARD_FILENAME];
    currentInput = (NSInputStream *) nil;
    currentOutput = (NSOutputStream *) nil;

    // [queryClause printForDebugger: [self currentOutput]];
    queryPredicate = [[NSMutableArray alloc] init];
    [queryPredicate addObject: queryClause];

    if (queryGoal != nil) {
        [queryGoal release];
    }

    queryGoal = [[Goal alloc] initGoal: queryPredicate proofTree: self parent: nil goalDepth: 0 ];

    return self;
}

- (BOOL) getSolution
{
    struct timeb    startTime;
    struct timeb    endTime;
    BOOL            solutionFound;

    (void) ftime(&startTime);

    if (setjmp(continuation) == 0) {
        [queryGoal prove: nil lastGoal: YES];
        (void) ftime(&endTime);
        solutionFound = NO;

        if ([database traceOption]) {
            [[self currentOutput] printWithFormat: @"\n"];
        }

        [[self currentOutput] printWithFormat: @"NO\n\n"];
    } else {
        (void) ftime(&endTime);
        solutionFound = YES;

        if ([database traceOption]) {
            [[self currentOutput] printWithFormat: @"\n"];
        }

        if ([queryGoal printResults] == 0) {
            [[self currentOutput] printWithFormat: @"YES\n\n"];
        } else {
            [[self currentOutput] printWithFormat: @"\n"];
        }
    }

    elapsedTime +=    ((endTime.time * 1000) + endTime.millitm)
                    - ((startTime.time * 1000) + startTime.millitm);

    return solutionFound;
}

- (void) continue
{
    longjmp(continuation, 1);
}

- (Prolog *) database
{
    return database;
}

- (BOOL) setCurrentInput: (NSString *) filename
{
    if (currentInput != (NSInputStream *) nil) {
        [currentInput close];
        currentInput = (NSInputStream *) nil;
    }

    currentInputName = [filename retain];
    if (![currentInputName isEqualToString: STANDARD_FILENAME]) {
        currentInput = [NSInputStream inputStreamWithFileAtPath: currentInputName];
        [currentInput open];
    }


    return YES;
}

- (NSInputStream *) currentInput
{
    if ([currentInputName isEqualToString: STANDARD_FILENAME]) {
        return [database consoleIn];
    } else {
        return currentInput;
    }
}

- (NSString *) currentInputName
{
    return currentInputName;
}

- (BOOL) setCurrentOutput: (NSString *) filename
{
    if (currentOutput != (NSOutputStream *) nil) {
        [currentOutput close];
        currentOutput = (NSOutputStream *) nil;
    }

    currentOutputName = [filename retain];
    if (![currentOutputName isEqualToString: STANDARD_FILENAME]) {
        currentOutput = [NSOutputStream outputStreamToFileAtPath: currentOutputName append: NO];
        [currentOutput open];
    }

    return YES;
}


- (NSOutputStream *) currentOutput
{
    if ([currentOutputName isEqualToString: STANDARD_FILENAME]) {
        return [database consoleOut];
    } else {
        return currentOutput;
    }
}

- (NSString *) currentOutputName
{
    return currentOutputName;
}

- (NSInteger) nextGoalSequence
{
    return sequence++;
}

- (NSInteger) nextInferenceCount
{
    return inferenceCount++;
}

- (NSInteger) nextSolutionCount
{
    return solutionCount++;
}

- (void) printForDebugger: (NSOutputStream *) stream
{
    [stream printWithFormat: @"%d", sequence];
    return;
}

- printStatistics
{
    [[self currentOutput] printWithFormat: @"Solutions: %d, TotalGoals: %d, InferenceCount: %d (%d lips)\n\n",
                solutionCount,
                sequence,
                inferenceCount,
                elapsedTime == 0 ? 0 : (inferenceCount * 1000) / elapsedTime ];

    return self;
}

- (void) dealloc
{
    [queryGoal release];
    [queryPredicate removeAllObjects];
    [queryPredicate release];
    [database release];
    [super dealloc];
}

@end
