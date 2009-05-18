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
#import "ProofTree.h"

@interface Prolog : NSObject

{
    BOOL                    traceOption;
    BOOL                    reconsultMode;
    NSInputStream *         consoleIn;
    NSOutputStream *        consoleOut;
    NSMutableDictionary *   relationTable;
    NSMutableDictionary *   deletedRelationTable;
}

- init;
- (BOOL) traceOption;
- setTraceOption: (BOOL) trace;
- (NSInputStream *) consoleIn;
- (NSOutputStream *) consoleOut;
- (int) consult: (NSInputStream *) inputStream output: (NSOutputStream *) outputStream;
- (int) reconsult: (NSInputStream *) inputStream output: (NSOutputStream *) outputStream;
- readTerm: (NSInputStream *) inputStream output: (NSOutputStream *) outputStream;
- addClause: clause;
- findRelation: (NSString *) relationName;
- showDatabase;
- query: queryClause;
- (void) dealloc;

@end

extern Prolog * prolog;
