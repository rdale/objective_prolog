
/* Prolog to WAM compiler 
	module sicstus.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

:- op(700, xfx, \= ).
\=(X,Y) :- not(X = Y).

:- op(900, fy, not).
not(X) :- \+ X.

list(X) :- fail.
