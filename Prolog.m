#import "Prolog.h"

#include <sys/types.h>
#include <sys/timeb.h>

extern void    SetStreams(NSInputStream * inStream, NSOutputStream * outStream);
extern int        yyparse(void);
extern int        yydebug;
extern id        CurrentTerm(void);
extern void    BeginEdinburghSyntax(void);
extern void    BeginStandardSyntax(void);
extern void    BeginSimpleSyntax(void);

id prolog = nil;

@implementation Prolog

- init
{
    [super init];
    relationTable = [[NSMutableDictionary alloc] init];
    [self setTraceOption: NO];
    
    NSBundle * bundle = [NSBundle bundleForClass: [Prolog class]];
    NSString * startupScript = [bundle pathForResource: @"startup" ofType: @"pl"];    
    NSInputStream * inputStream = [NSInputStream inputStreamWithFileAtPath: startupScript];
    [inputStream open];
    
    NSOutputStream * outputStream = [NSOutputStream outputStreamToFileAtPath: @"/tmp/startup.out" append: NO];
    [outputStream open];
    
    [self consult: inputStream output: outputStream];
    
    [inputStream close];
    [outputStream close];
    prolog = self;
    return self;
}

- (BOOL) traceOption
{
    return traceOption;
}

- setTraceOption: (BOOL) trace
{
    traceOption = trace;
    return self;
}

- (NSInputStream *) consoleIn
{
    return consoleIn;
}

- (NSOutputStream *) consoleOut
{
    return consoleOut;
}

/*
 *    Reads in a set of clauses, adding them to the end of any relations with the same
 *        principal functor that are already present.
 */
- (int) consult: (NSInputStream *) inputStream output: (NSOutputStream *) outputStream
{
    id        currentTerm;
    
    BeginEdinburghSyntax();
    SetStreams(inputStream, outputStream);
    consoleOut = outputStream;
    
    currentTerm = [self readTerm: inputStream output: outputStream];
    
    while (currentTerm != nil) {
        if (    [currentTerm headTerm] == nil 
            && (    [[currentTerm functionName] isEqualToString: @"?-"] 
                        || [[currentTerm functionName] isEqualToString: @":-"] ) )
        {
            [self query: currentTerm];
        } else {
            [self addClause: currentTerm];
        }
        
        currentTerm = [self readTerm: inputStream output: outputStream];
    }
    
    return SUCCESS;
}

/*
 *    Reads in a set of clauses, overwriting any relations with the same principal
 *        functor that are already present.
 */
- (int) reconsult: (NSInputStream *) inputStream output: (NSOutputStream *) outputStream
{
    reconsultMode = YES;
    deletedRelationTable = [[NSMutableDictionary alloc] init];
    
    [self consult: inputStream output: outputStream];
    
    [deletedRelationTable removeAllObjects];
    [deletedRelationTable release];
    reconsultMode = NO;
    
    return SUCCESS;
}

- readTerm: (NSInputStream *) inputStream output: (NSOutputStream *) outputStream
{
    int        parseResult;

    BeginEdinburghSyntax();
    SetStreams(inputStream, outputStream);
    
    // yydebug = 1;
    parseResult = yyparse();
    if (parseResult == SUCCESS) {
        return CurrentTerm();
    } else {
        return nil;
    }
}

/*
 *    Adds a clause to the database. 
 *    - If the relation already exists, the new clause is added onto the end of the 
 *        existing clauses. Otherwise a new relation entry is set up and the clause
 *        inserted.
 *    - If in �reconsultMode� and an old relation is already present, the
 *        old relation is removed and replaced by a new one. The old relation is
 *        saved in the �deletedRelationTable. Hence, an �old relation� is defined as
 *        as a relation which already exists in the relationTable, but not in the
 *        deletedRelationTable.
 */
- addClause: clause
{
    id        relation;
    NSString *        name;
    
    name = [[clause headTerm] functionName];
    
    if ([relationTable valueForKey: name] != nil) {
        relation = [relationTable valueForKey: name];
        
        if (reconsultMode && [deletedRelationTable valueForKey: name] == nil) {
            (void) [deletedRelationTable setValue: relation forKey: name];
            (void) [relationTable removeObjectForKey: name];
            relation = [[NSMutableArray alloc] init];
            [relation addObject: clause];
            [relationTable setValue: relation forKey: name];
        } else {
            [relation addObject: clause];
        }
    } else {
        if (reconsultMode) {
            (void) [deletedRelationTable setValue: nil forKey: name];
        }
        
        relation = [[NSMutableArray alloc] init];
        [relation addObject: clause];
        [relationTable setValue: relation forKey: name];
    }
    
    return self;
}

- findRelation: (NSString *) relationName
{
    return [relationTable valueForKey: relationName];
}

- showDatabase
{
    id                relation; 
    
    [consoleOut printWithFormat: @"==> DATABASE\n\n"];
    for (id key in relationTable) {
        relation = [[relationTable objectForKey: key] retain];
        [relation printForDebugger: consoleOut];
    }
    
    [consoleOut printWithFormat: @"\n<== DATABASE\n"];
    
    return self;
}

/*
 *    Takes a goal clause and queries the database.
 */
- query: queryClause
{
    id        proofTree;
    
    proofTree = [[ProofTree alloc] initQuery: queryClause database: self tracing: traceOption];
    while ([proofTree getSolution]) {
        ;
    }
    
    [proofTree printStatistics];
    [proofTree release];
    
    return self;
}

- (void) dealloc
{
    [relationTable removeAllObjects];
    [relationTable release];
    [super dealloc];
}

@end
