#include <Foundation/Foundation.h>
#include "Prolog.h"

int main (void)
{
    NSAutoreleasePool *pool;

    pool = [NSAutoreleasePool new];
    Prolog *prolog = [[Prolog alloc] init];

    RELEASE(prolog);
    RELEASE(pool);
    
    return 0;
}

