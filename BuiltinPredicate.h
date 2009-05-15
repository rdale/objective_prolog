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

#import "FunctionTerm.h"
#import "ListTerm.h"
#import "NSOutputStream(Printf).h"

@interface Goal(BuiltinPredicate)

- __cut;
- __eq;
- __ge;
- __gt;
- __le;
- __lt;
- __ne;
- __notstricteq;
- __stricteq;
- __univ;

- _arg;
- _assert;
- _asserta;
- _assertz;
- _atom;
- _atomic;
- _chdir;
- _clause;
- _consult;
- _debugging;
- _display;
- _functor;
- _get;
- _get0;
- _integer;
- _is;
- _listing;
- _ls;
- _name;
- _nl;
- _nodebug;
- _nonvar;
- _nospy;
- _notrace;
- _op;
- _put;
- _pwd;
- _read;
- _reconsult;
- _repeat;
- _retract;
- _see;
- _seeing;
- _seen;
- _skip;
- _spy;
- _tab;
- _tell;
- _telling;
- _told;
- _trace;
- _true;
- _ttyflush;
- _var;
- _write;

@end