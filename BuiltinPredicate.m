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

#import "Term.h"
#import "FunctionTerm.h"
#import "VariableTerm.h"
#import "NumericTerm.h"
#import "ListTerm.h"
#import "ListIterator.h"
#import "Structure.h"
#import "Binding.h"
#import "Prolog.h"
#import "Goal.h"
#import "Unify.h"
#import "BuiltinPredicate.h"

#define SUCCEED_ONCE    proofState = ALWAYS_FAIL;

extern id    CurrentTerm();

@implementation Goal(BuiltinPredicate)

- __cut
{
    if (proofState == START_PROOF) {
        proofState = CALL_SYSTEM_PREDICATE;
        return self;
    } else {
        [parentGoal setProofState: ALWAYS_FAIL];
        return nil;
    }
}

- __eq
{
    id    value1;
    id    environment1;
    id    value2;
    id    environment2;
    
    SUCCEED_ONCE;
    
    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentEnvironment];
    
    value2 = [[argIterator next] currentItem];
    environment2 = [argIterator currentEnvironment];
    
    if ([self unify: value1 in: environment1 with: value2 in: environment2]) {
        return self;
    } else {
        return nil;
    }
}

- __ge
{
    id    value1;
    id    value2;
    
    SUCCEED_ONCE;
    
    value1 = [[argIterator next] currentItem];
    value2 = [[argIterator next] currentItem];

    if (    ![value1 isKindOfClass: [NumericTerm class]]
            || ![value2 isKindOfClass: [NumericTerm class]] )
    {
        return nil;
    }
    
    if ([value1 intValue] >= [value2 intValue]) {
        return self;
    } else {
        return nil;
    }
}

- __gt
{
    id    value1;
    id    value2;
    
    SUCCEED_ONCE;
    
    value1 = [[argIterator next] currentItem];
    value2 = [[argIterator next] currentItem];

    if (    ![value1 isKindOfClass: [NumericTerm class]]
            || ![value2 isKindOfClass: [NumericTerm class]] )
    {
        return nil;
    }
    
    if ([value1 intValue] > [value2 intValue]) {
        return self;
    } else {
        return nil;
    }
}

- __le
{
    id    value1;
    id    value2;
    
    SUCCEED_ONCE;

    value1 = [[argIterator next] currentItem];
    value2 = [[argIterator next] currentItem];

    if (    ![value1 isKindOfClass: [NumericTerm class]]
            || ![value2 isKindOfClass: [NumericTerm class]] )
    {
        return nil;
    }
    
    if ([value1 intValue] <= [value2 intValue]) {
        return self;
    } else {
        return nil;
    }
}

- __lt
{
    id    value1;
    id    value2;
        
    SUCCEED_ONCE;

    value1 = [[argIterator next] currentItem];
    value2 = [[argIterator next] currentItem];

    if (    ![value1 isKindOfClass: [NumericTerm class]]
            || ![value2 isKindOfClass: [NumericTerm class]] )
    {
        return nil;
    }
    
    if ([value1 intValue] < [value2 intValue]) {
        return self;
    } else {
        return nil;
    }
}

- __ne
{
    id    value1;
    id    environment1;
    id    value2;
    id    environment2;
        
    SUCCEED_ONCE;

    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentEnvironment];
    value2 = [[argIterator next] currentItem];
    environment2 = [argIterator currentEnvironment];
        
    if (![self unify: value1  in: environment1 with: value2 in: environment2]) {
        [self fail];
        return self;
    } else {
        return nil;
    }
}

- __notstricteq
{
    id    value1;
    id    environment1;
    id    value2;
    id    environment2;
        
    SUCCEED_ONCE;

    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentItem];
    value2 = [[argIterator next] currentItem];
    environment2 = [argIterator currentItem];
    
    if (![self isEqual: value1 in: environment1 with: value2 in: environment2]) {
        return self;
    } else {
        return nil;
    }
}

- __stricteq
{
    id    value1;
    id    value2;
        
    SUCCEED_ONCE;

    value1 = [[argIterator next] currentItem];
    value2 = [[argIterator next] currentItem];
    
    if ([self isEqual: value1 in: parentGoal with: value2 in: parentGoal]) {
        return self;
    } else {
        return nil;
    }
}

- __univ
{
    id    value1;
    id    environment1;
    id    value2;
    id    environment2;
    id    structure;
    id    functionTerm;
    id    listItem1;
    id    listItem2;
    id    listItem3;
    
    SUCCEED_ONCE;
    
    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentEnvironment];
    
    value2 = [[argIterator next] currentItem];
    environment2 = [argIterator currentEnvironment];
    
#ifdef    DEBUG
    NXLogError("Univ, parentGoal: %d, environment1: %d, environment2: %d\n",
                [parentGoal goalSequence],
                [environment1 goalSequence],
                [environment2 goalSequence] );
#endif

    if ([value1 isKindOfClass: [FunctionTerm class]]) {
        listItem1 = [self store: [[ListTerm alloc] initTerm: value1 tail: nil]];
        
        if ([self unify: listItem1 in: environment1 with: value2 in: environment2]) {
            return self;
        } else {
            return nil;
        }
    } else if ([value1 isKindOfClass: [Structure class]]) {
        if ([self unify: [value1 listTerm] in: environment1 with: value2 in: environment2]) {
            return self;
        } else {
            return nil;
        }
    } else if ([value1 isKindOfClass: [ListTerm class]]) {
        functionTerm = [self store: [[FunctionTerm alloc] initFunction: @"."]];
        listItem1 = [self store: [[ListTerm alloc] initTerm: [value1 tail] tail: nil]];
        listItem2 = [self store: [[ListTerm alloc] initTerm: [value1 head] tail: listItem1]];
        listItem3 = [self store: [[ListTerm alloc] initTerm: functionTerm tail: listItem2]];
        
        if ([self unify: listItem3 in: environment1 with: value2 in: environment2]) {
            return self;
        } else {
            return nil;
        }
    } else if ([value2 isKindOfClass: [ListTerm class]]) {
        structure = [self store: [[Structure alloc] initList: value2]];
        
        if ([self unify: value1 in: environment1 with: structure in: environment2]) {
            return self;
        } else {
            return nil;
        }
    }
    
    return nil;
}

- _arg
{
    id    value1;
    id    environment1;
    id    value2;
    id    environment2;
    id    value3;
    id    iterator;
    
    SUCCEED_ONCE;
    
    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentEnvironment];
    
    value2 = [[argIterator next] currentItem];
    environment2 = [argIterator currentEnvironment];
    
    value3 = [[argIterator next] currentItem];
    
    if ([value1 isKindOfClass: [NumericTerm class]]) {
        if ([value2 isKindOfClass: [Structure class]]) {
            iterator = [value2 createIterator: environment2];
            
            for (    [iterator first]; 
                    ![iterator isDone] && [iterator index] < [value1 intValue]; 
                    [iterator next] ) 
            {
                ;
            }
            
            if ([iterator isDone]) {
                return nil;
            }
        
            if ([    self 
                        unify: [iterator currentItem] in: [iterator currentEnvironment] 
                        with: value3 in: [argIterator currentEnvironment] ] ) 
            {
                return self;
            } else {
                return nil;
            }
        } else if ([value2 isKindOfClass: [ListTerm class]]) {
            iterator = [value2 createIterator: environment2];
        
            for (    [iterator first]; 
                    ![iterator isDone] && ([iterator index] + 1) < [value1 intValue]; 
                    [iterator next] ) 
            {
                ;
            }
            
            if ([iterator isDone]) {
                return nil;
            }
        
            if ([    self 
                        unify: [iterator currentListTerm] in: [iterator currentListEnvironment] 
                        with: value3 in: [argIterator currentEnvironment] ] ) 
            {
                return self;
            } else {
                return nil;
            }
        }
    }
    
    return nil;
}

- _assert
{
    return self;
}

- _asserta
{
    return self;
}

- _assertz
{
    return self;
}

- _atom
{
    id    value1;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if (    [value1 isKindOfClass: [FunctionTerm class]]
            || value1 == nil
            || (    [value1 isKindOfClass: [ListTerm class]]
                    && [value1 head] == nil ) ) 
    {
        return self;
    } else {
        return nil;
    }
}

- _atomic
{
    id    value1;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if (    [value1 isKindOfClass: [NumericTerm class]]
            || [value1 isKindOfClass: [FunctionTerm class]]
            || value1 == nil
            || (    [value1 isKindOfClass: [ListTerm class]]
                    && [value1 head] == nil ) ) 
    {
        return self;
    } else {
        return nil;
    }
}

- _chdir
{
    id    value1;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if ([value1 isKindOfClass: [FunctionTerm class]]){
        chdir([[value1 functionName] UTF8String]);
        return self;
    }
    
    return nil;
}

- _clause
{
    SUCCEED_ONCE;
    return self;
}

- _consult
{
    id            value1;
    NSInputStream *    consultStream;

    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    if (![value1 isKindOfClass: [FunctionTerm class]]) {
        return nil;
    }
    
    consultStream = [NSInputStream inputStreamWithFileAtPath: [value1 functionName]];
    if (consultStream == nil) {
        return nil;
    }
        
    [consultStream open];
    [[proofTree database] consult: consultStream output: [proofTree currentOutput]];
    [consultStream close];
    
    return self;
}

- _debugging
{
    return self;
}

- _display
{
    SUCCEED_ONCE;
    [[[argIterator next] currentItem] printValue: parentGoal output: [proofTree currentOutput]];
    
    return self;
}

- _functor
{
    id    value1;
    id    environment1;
    id    value2;
    id    environment2;
    id    value3;
    id    environment3;
    id    numberOfArgs;
    int    count;
    id    functionTerm;
    id    iterator;
    
    SUCCEED_ONCE;
    
    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentEnvironment];
    
    value2 = [[argIterator next] currentItem];
    environment2 = [argIterator currentEnvironment];
    
    value3 = [[argIterator next] currentItem];
    environment3 = [argIterator currentEnvironment];
    
    if (    [value1 isKindOfClass: [VariableTerm class]]
            && [value2 isKindOfClass: [FunctionTerm class]]
            && [value3 isKindOfClass: [NumericTerm class]] ) 
    {
        id    listTerm;
        id    structure;
        id    variableTerm;
        
        listTerm = [self store: [[ListTerm alloc] initTerm: value2 tail: nil]]; 
        structure = [self store: [[Structure alloc] initTerm: listTerm tail: nil]];

        for (count = 0; count < [value3 intValue]; count++) {
            variableTerm = [self store: [[VariableTerm alloc] init]];
            [parentGoal getBinding: variableTerm];
            [listTerm setTail: [self store: [[ListTerm alloc] initTerm: variableTerm tail: nil]]]; 
            listTerm = [listTerm tail];
        }
        
        if ([self unify: structure in: parentGoal with: value1 in: parentGoal]) {
            return self;
        } else {
            return nil;
        }
    } else if ([value1 isKindOfClass: [Structure class]]) {
        iterator = [value1 createIterator: environment1];
        
        for ([iterator first], count = 0; ![iterator isDone]; [iterator next]) {
            count++;
        }
        
        [iterator release];
        
        numberOfArgs = [self store: [[NumericTerm alloc] initNumeric: count - 1]];
        
        if (    [self unify: [value1 head] in: environment1 with: value2 in: parentGoal]
                && [self unify: value3 in: parentGoal with: numberOfArgs in: parentGoal] )
        {
            return self;
        } else {
            return nil;
        }
    } else if ([value1 isKindOfClass: [FunctionTerm class]] || [value1 isKindOfClass: [NumericTerm class]]) {
        numberOfArgs = [self store: [[NumericTerm alloc] initNumeric: 0]];
        
        if (    [self unify: value1 in: environment1 with: value2 in: parentGoal]
                && [self unify: value3 in: parentGoal with: numberOfArgs in: parentGoal] )
        {
            return self;
        } else {
            return nil;
        }
    } else if ([value1 isKindOfClass: [ListTerm class]]) {
        numberOfArgs = [self store: [[NumericTerm alloc] initNumeric: 2]];
        functionTerm = [self store: [[FunctionTerm alloc] initFunction: @"."]];
        
        if (    [self unify: functionTerm in: parentGoal with: value2 in: parentGoal]
                && [self unify: value3 in: parentGoal with: numberOfArgs in: parentGoal] )
        {
            return self;
        } else {
            return nil;
        }
    }
    
    return nil;
}

- _get
{
    id                value1;
    unsigned char    ch;
    id                inputCharacter;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if (    [value1 isKindOfClass: [NumericTerm class]]
            || [value1 isKindOfClass: [VariableTerm class]] ) 
    {
        NSInteger bytesRead = 0;
        uint8_t buffer[1];
        do {
            bytesRead = [[proofTree currentInput] read: buffer maxLength: 1];
            ch = buffer[0];
        } while (bytesRead == 1 && (!isprint(ch) || isspace(ch)));

        inputCharacter = [self store: [[NumericTerm alloc] initNumeric: (int) ch]];
        
        if ([self unify: value1 in: parentGoal with: inputCharacter in: self]) {
            return self;
        } else {
            return nil;
        }
    }
    
    return nil;
}

- _get0
{
    id                value1;
    unsigned char    ch = 0;
    id                inputCharacter;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if (    [value1 isKindOfClass: [NumericTerm class]]
            || [value1 isKindOfClass: [VariableTerm class]] ) 
    {
        uint8_t buffer[1];
        NSInteger bytesRead = [[proofTree currentInput] read: buffer maxLength: 1];
        if (bytesRead == 1) {
            ch = buffer[0];
        }
        
        inputCharacter = [self store: [[NumericTerm alloc] initNumeric: (int) ch]];
        
        if ([self unify: value1 in: parentGoal with: inputCharacter in: self]) {
            return self;
        } else {
            return nil;
        }
    }
    
    return nil;
}

- _integer
{
    id    value1;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if ([value1 isKindOfClass: [NumericTerm class]]) {
        return self;
    } else {
        return nil;
    }
}

- _is
{
    id    value1;
    id    environment1;
    id    value2;
    id    environment2;
    id    value3;
    id    environment3;
    id    value4;
    id    environment4;
    id    numericTerm;
    int    result;
    id    iterator;
    
    SUCCEED_ONCE;
    
    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentEnvironment];
    
    value2 = [[argIterator next] currentItem];
    environment2 = [argIterator currentEnvironment];
    
    if (![argIterator isLast]) {
        return nil;
    }
    
    if (    ([value1 isKindOfClass: [VariableTerm class]] || [value1 isKindOfClass: [NumericTerm class]])
            && ([value2 isKindOfClass: [VariableTerm class]] || [value2 isKindOfClass: [NumericTerm class]]) )
    {
        if ([self unify: value1 in: environment1 with: value2 in: environment2]) {
            return self;
        } else {
            return nil;
        }
    } else if ([value2 isKindOfClass: [Structure class]]) {
        iterator = [value2 createIterator: environment2];
        [iterator first];
        
        [iterator next];
        value3 = [iterator currentItem];
        environment3 = [iterator currentEnvironment];
        
        [iterator next];
        value4 = [iterator currentItem];
        environment4 = [iterator currentEnvironment];
        
        [iterator release];
        
        if (    [value3 isKindOfClass: [NumericTerm class]]
                && [value4 isKindOfClass: [NumericTerm class]] )
        {
            if ([[value2 functionName] isEqualToString: @"*"]) {
                result = [value3 intValue] * [value4 intValue];
            } else if ([[value2 functionName] isEqualToString: @"+"]) {
                result = [value3 intValue] + [value4 intValue];
            } else if ([[value2 functionName] isEqualToString: @"-"]) {
                result = [value3 intValue] - [value4 intValue];
            } else if ([[value2 functionName] isEqualToString: @"/"]) {
                result = [value3 intValue] / [value4 intValue];
            } else if ([[value2 functionName] isEqualToString: @"mod"]) {
                result = [value3 intValue] % [value4 intValue];
            } else {
                return nil;
            }
            
            numericTerm = [self store: [[NumericTerm alloc] initNumeric: result]];
            
            if ([self unify: value1 in: environment1 with: numericTerm in: environment2]) {
                return self;
            } else {
                return nil;
            }
        }
    }
    
    return nil;
}

- _listing
{
    id    value1;
    id    aRelation;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if ([value1 isKindOfClass: [FunctionTerm class]]) {
        aRelation = [[proofTree database] findRelation: [value1 functionName]];
        if (aRelation == nil) {
            return nil;
        }
        
        [aRelation printForDebugger: [proofTree currentOutput]];
        [[proofTree currentOutput] printWithFormat: @"\n"];
        return self;
    }

    return nil;
}

- _ls
{
    id        value1;
    FILE *    stream;
    char *    lsCommand;
    int        ch;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if (value1 == nil) {
        stream = popen("ls", "r");
    } else if ([value1 isKindOfClass: [FunctionTerm class]]) {
        (void) sprintf(lsCommand, "ls %s", [[value1 functionName] UTF8String]);
        stream = popen(lsCommand, "r");
    } else {
        return nil;
    }
    
    ch = getc(stream);
    
    while (ch != EOF) {
        [[proofTree currentOutput] printWithFormat: @"%c", (char) ch];
        ch = getc(stream);
    }

    pclose(stream);
    [[proofTree currentOutput] printWithFormat: @"\n"];
    
    return self;
}

- _name
{
    id        numericListIterator;
    id        value1;
    id        value2;
    id        environment2;
    NSString *        name;
    NSUInteger        index;
    id        numericTerm;
    id        functionTerm;
    id        listTerm;
    char    buffer[100];
    char *    ptr;
    
    SUCCEED_ONCE;
            
    value1 = [[argIterator next] currentItem];
    
    value2 = [[argIterator next] currentItem];
    environment2 = [argIterator currentEnvironment];
    
    if ([value1 isKindOfClass: [FunctionTerm class]]) {
        name = [value1 functionName];
        
        for (    index = [name length], listTerm = nil;
                index >= 0;
                index-- )
        {
            numericTerm = [self store: [[NumericTerm alloc] initNumeric: (int) [name characterAtIndex: index]]];
            listTerm = [self store: [[ListTerm alloc] initTerm: numericTerm tail: listTerm]];
        }
        
        if ([self unify: listTerm in: parentGoal with: value2 in: parentGoal]) {
            return self;
        } else {
            return nil;
        }
    } else if ([value2 isKindOfClass: [ListTerm class]]) {
        numericListIterator = [value2 createIterator: environment2];
                            
        for (    [numericListIterator first], ptr = buffer; 
                ![numericListIterator isDone];
                [numericListIterator next] )
        {
            if ([[numericListIterator currentItem] isKindOfClass: [NumericTerm class]]) {
                *ptr++ = [[numericListIterator currentItem] intValue];
            } else {
                return nil;
            }
        }
        
        *ptr = '\0';
        
        functionTerm = [self store: [[FunctionTerm alloc] initFunction: [NSString stringWithUTF8String: buffer]]];
        
        if ([self unify: value1 in: parentGoal with: functionTerm in: parentGoal]) {
            return self;
        } else {
            return nil;
        }
    }
    
    return nil;
}

- _nl
{
    SUCCEED_ONCE;
    [[proofTree currentOutput] printWithFormat: @"\n"];
    return self;
}

- _nodebug
{
    return self;
}

- _nonvar
{
    id    value1;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if (    value1 == nil
            || ![value1 isKindOfClass: [VariableTerm class]] ) 
    {
        return self;
    } else {
        return nil;
    }
}

- _nospy
{
    return self;
}

- _notrace
{
    SUCCEED_ONCE;

    [[proofTree database] setTraceOption: NO];
    return self;
}

- _op
{
    return self;
}

- _put
{
    id    value1;
    
    SUCCEED_ONCE;
            
    value1 = [[argIterator next] currentItem];
    
    if ([value1 isKindOfClass: [NumericTerm class]]) {
        [[proofTree currentOutput] printWithFormat: @"%c", [value1 intValue]];
        return self;
    }
    
    return nil;
}

- _pwd
{
    id        value1;
    FILE *    stream;
    int        ch;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if (value1 == nil) {
        stream = popen("pwd", "r");
    } else {
        return nil;
    }
    
    ch = getc(stream);
    
    while (ch != EOF) {
        [[proofTree currentOutput] printWithFormat: @"%c", (char) ch];
        ch = getc(stream);
    }

    pclose(stream);
    [[proofTree currentOutput] printWithFormat: @"\n"];
    
    return self;
}

- _read
{
    id        value1;
    id        environment1;
    id        newTerm;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentEnvironment];
    newTerm = [[proofTree database] readTerm: [proofTree currentInput] output: [proofTree currentOutput]];
    
    if (newTerm == nil) {
        newTerm = [self store: [[FunctionTerm alloc] initFunction: @"end_of_file"]];
    } else {
        newTerm = [self store: newTerm];
    }
    
    if ([self unify: value1 in: environment1 with: newTerm in: self]) {
        return self;
    } else {
        return nil;
    }
}

- _reconsult
{
    id            value1;
    NSInputStream *    reconsultStream;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    if (![value1 isKindOfClass: [FunctionTerm class]]) {
        return nil;
    }
    
    reconsultStream = [NSInputStream inputStreamWithFileAtPath: [value1 functionName]];
    if (reconsultStream == nil) {
        return nil;
    }
    
    [reconsultStream open];
    [[proofTree database] reconsult: reconsultStream output: [proofTree currentOutput]];
    [reconsultStream close];
    
    return self;
}

- _repeat
{
    if (proofState == START_PROOF) {
        proofState = CALL_SYSTEM_PREDICATE;
    }
    
    return self;
}

- _retract
{
    return self;
}

- _see
{
    id    value1;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];

    if (    [value1 isKindOfClass: [FunctionTerm class]]
            && [proofTree setCurrentInput: [value1 functionName]] ) 
    {
        return self;
    }
    
    return nil;
}

- _seeing
{
    id    value1;
    id    cin;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];

    cin = [self store: [[FunctionTerm alloc] initFunction: [proofTree currentInputName]]];
    
    if ([self unify: value1 in: parentGoal with: cin in: self]) {
        return self;
    }
    
    return nil;
}

- _seen
{
    SUCCEED_ONCE;

    if ([proofTree setCurrentInput: STANDARD_FILENAME]) {
        return self;
    }
    
    return nil;
}

- _skip
{
    id                value1;
    unsigned char    ch;
    id                inputCharacter;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if ([value1 isKindOfClass: [NumericTerm class]]) {
        NSInteger bytesRead = 0;
        do {
            uint8_t buffer[1];
            bytesRead = [[proofTree currentInput] read: buffer maxLength: 1];
            ch = buffer[0];
        } while (bytesRead == 1 && ch != [value1 intValue]);

        inputCharacter = [self store: [[NumericTerm alloc] initNumeric: (int) ch]];
        
        if ([self unify: value1 in: parentGoal with: inputCharacter in: self]) {
            return self;
        } else {
            return nil;
        }
    }
    
    return nil;
}

- _spy
{
    return self;
}

- _tab
{
    id    value1;
    int    count;
    
    SUCCEED_ONCE;
    [argIterator next];
    
    if ([argIterator isDone]) {
        [[proofTree currentOutput] printWithFormat: @" "];
        return self;
    }
    
    value1 = [argIterator currentItem];
    
    if ([value1 isKindOfClass: [NumericTerm class]]) {
        for (count = 0; count < [value1 intValue]; count++) {
            [[proofTree currentOutput] printWithFormat: @" "];
        }
    } else {
        return nil;
    }
    
    return self;
}

- _tell
{
    id    value1;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];

    if (    [value1 isKindOfClass: [FunctionTerm class]]
            && [proofTree setCurrentOutput: [value1 functionName]] ) 
    {
        return self;
    }
    
    return nil;
}

- _telling
{
    id    value1;
    id    cout;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];

    cout = [self store: [[FunctionTerm alloc] initFunction: [proofTree currentOutputName]]];
    
    if ([self unify: value1 in: parentGoal with: cout in: self]) {
        return self;
    }
    
    return nil;
}

- _told
{
    SUCCEED_ONCE;

    if ([proofTree setCurrentOutput: STANDARD_FILENAME]) {
        return self;
    }
    
    return nil;
}

- _trace
{
    SUCCEED_ONCE;

    [[proofTree database] setTraceOption: YES];
    return self;
}

- _true
{
    SUCCEED_ONCE;
    return self;
}

- _ttyflush
{
    return self;
}

- _var
{
    id    value1;
    
    SUCCEED_ONCE;
    value1 = [[argIterator next] currentItem];
    
    if ([value1 isKindOfClass: [VariableTerm class]]) {
        return self;
    } else {
        return nil;
    }
}

- _write
{
    id    value1;
    id    environment1;

    SUCCEED_ONCE;

    value1 = [[argIterator next] currentItem];
    environment1 = [argIterator currentEnvironment];

    [value1 printValue: environment1 output: [proofTree currentOutput]];
    
    return self;
}


@end