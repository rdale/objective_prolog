/* Prolog to WAM compiler 
	module unify_vo.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* unify_void(+InCode, -OutCode)

   add unify_void instructions to the code.

   It uses the output of 'alloc_dealloc'
*/


unify_void([], []).
unify_void([unify_vbl(_,void) | Y], [unify_void(N) | T]) :- !, % green
	count_void(Y,1,N,Z),
	unify_void(Z, T).
unify_void([C | Y], [C | Z]) :-
	C \= unify_vbl(_,void),
	unify_void(Y, Z).

count_void([unify_vbl(_,void) | Y], N, M, Z) :- !, % green
	N1 is N+1,
	count_void(Y, N1, M, Z).
count_void(Y, N, N, Y) :-
	Y \= [unify_vbl(_,void) | _].
