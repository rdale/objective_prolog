/*
   Project: ObjcProlog

   Author: Richard Dale

   Created: 2019-07-28 13:01:40 +0100 by rdale
*/

#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>

#import <Foundation/Foundation.h>
#import "Prolog.h"

static const char *PROLOG_PROMPT = "?- ";

int
main(int argc, const char *argv[])
{
    id pool = [[NSAutoreleasePool alloc] init];

    Prolog *prolog = [[Prolog alloc] init];

    char* readlineBuffer;
    char* inputBuffer;

    while ((readlineBuffer = readline(PROLOG_PROMPT)) != NULL) {
        if (strlen(readlineBuffer) > 0) {
            add_history(readlineBuffer);
        }

        inputBuffer = (char *) malloc(strlen(PROLOG_PROMPT) + strlen(readlineBuffer) + 1);
        strcpy(inputBuffer, PROLOG_PROMPT);
        strcat(inputBuffer, readlineBuffer);

        NSData *inputData = [NSData dataWithBytes: inputBuffer length: strlen(inputBuffer)];
        NSInputStream * inputStream = [[NSInputStream alloc] initWithData: inputData];
        [inputStream open];

        NSOutputStream * outputStream = [NSOutputStream outputStreamToMemory];
        [outputStream open];

        [prolog consult: inputStream output: outputStream];

        NSData *outputData = [outputStream propertyForKey: NSStreamDataWrittenToMemoryStreamKey];
        char *ptr = (char *) [outputData bytes];
        int len = [outputData length];
        printf("%*.*s", len, len, ptr);

        free(readlineBuffer);
        free(inputBuffer);

        [inputStream release];
        [inputData release];
        [outputStream release];
    }

    [pool release];

    return 0;
}

