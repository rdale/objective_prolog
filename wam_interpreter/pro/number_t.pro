/* Prolog to WAM compiler 
	module number_t.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* number_temps(+Code, -NewCode)

   This predicate performs correct temporary vbl allocation from code
   which contains 'get_vbl', 'put_value' instructions, etc. which
   assume that the Xi and Ai registers are distinct.
*/



number_temps([], X-X).
number_temps([H | T], [H | X]-Y) :-
	number_temps(T, X-Y).

number_temps(F/A, In, Out) :-
	listN(A, L),
	lifetime(In, Mid, L, []),
	assign_temp(Mid, Out, []).

/* lifetime(+Incode, -Outcode, +Regs_alive, ?Temp_vbls_alive) */


/* Initial set of registers used is A0 .. A(arity-1).
   When a register has its value used it is removed from
   the set Regs_alive. This is done by
	get_const .. get_value
   When a register is brought into use it is added to Regs_alive
   This is done by
	put_const .. put_value
   Regs_alive is set to empty after
	call .. execute

   All others leave Regs_alive unchanged

   Initial temp vbls alive is empty. Temp vbls must be nil
   when execute .. proceed is reached because they all should
   be in registers by then. Many instructions e.g get_struct
   have no effedt on temporaries.
   For the rest, temporary vbl lifetime is calculated coming
   back out of the recursion i.e. the lifetime is calculated
   from the end of the instruction list.
   Temp vbl must be alive before
	put_value X, unify_value X get_value X, unify_local_value X
   because otherwise they would have no value. This is true whether
   or not they were alive after.
   temp vbl cannot be alive before
	put_vbl X, unify_vbl X, get_vbl X (and reget_vbl X)
   because this makes it alive.
   Info about regs + tmep vbls alive is added to the put instructions
   which are the ones which may cause conflicts.
*/
   
lifetime([], [], _, _).

lifetime(In, Out, Args, Vbls) :-
	(In = [execute(P,A) | Cs] , Vbls = []
	->
		Out = [execute(P,A) | CLs], 	
		lifetime(Cs, CLs, [], [])
	;
	In = [call(P, A,N) | Cs], Vbls = []
	->
		Out = [call(P, A,N) | CLs],
		lifetime(Cs, CLs, [], [])
	;
	In = [proceed | Cs], Vbls = []
	->
		Out = [proceed | CLs],
		lifetime(Cs, CLs, [], [])
	;
	In = [get_const(C, A) | Cs] 
	->
		Out = [get_const(C, A) | Cls],
		delete(A, Args, Nargs),
		lifetime(Cs, Cls, Nargs, Vbls)
	;
	In = [get_struct(S, A) | Cs] 
	->
		Out = [get_struct(S, A) | Cls],
		delete(A, Args, Nargs),
		lifetime(Cs, Cls, Nargs, Vbls)
	;
	In = [get_vbl(Y, perm, A) | Cs] 
	->
		Out = [get_vbl(Y, perm, A) | Cls],
		delete(A, Args, Nargs),
		lifetime(Cs, Cls, Nargs, Vbls)
	;
	In = [get_vbl(X, temp, A) | Cs] 
	->
		Out = [get_vbl(X, temp, A) | Cls],
		delete(A, Args, Nargs),
		lifetime(Cs, Cls, Nargs, NVbls), 
		(delete(X, NVbls, Vbls) 	
		-> 	true
		;	Vbls = NVbls  % void ones have zero life
		)
	;
	In = [reget_vbl(X, temp, A) | Cs] 
	->
		Out = [reget_vbl(X, temp, A) | Cls],
		delete(A, Args, Nargs),
		lifetime(Cs, Cls, Nargs, NVbls), 
		delete(X, NVbls, Vbls)
	;
	In = [get_value(Y, perm, A) | Cs] 
	->
		Out = [get_value(Y, perm, A) | Cls],
		delete(A, Args, Nargs),
		lifetime(Cs, Cls, Nargs, Vbls)
	;
	In = [get_value(X, temp, A) | Cs] 
	->
		Out = [get_value(X, temp, A) | Cls],
		delete(A, Args, Nargs),
		lifetime(Cs, Cls, Nargs, NVbls), 
		addnew(X, NVbls, Vbls)
	;
	In = [put_const(C, A) | Cs] 
	->
		Out = [put_const(C, A, Args, Vbls) | Cls],
		lifetime(Cs, Cls, [A | Args], Vbls)
	;
	In = [put_struct(S, A) | Cs] 
	->
		Out = [put_struct(S, A, Args, Vbls) | Cls],
		lifetime(Cs, Cls, [A | Args], Vbls)
	;
	In = [put_vbl(Y, perm, A) | Cs] 
	->
		Out = [put_vbl(Y, perm, A, Args, Vbls) | Cls],
		lifetime(Cs, Cls, [A | Args], Vbls)
	;
	In = [put_vbl(X, temp, A) | Cs] 
	->
		Out = [put_vbl(X, temp, A, Args, Vbls) | Cls],
		lifetime(Cs, Cls, [A | Args], NVbls),
		(delete(X, NVbls, Vbls)
		->	true
		;	Vbls = NVbls	% void vbls have zero life
		)
	;
	In = [put_value(Y, perm, A) | Cs]
	->
		Out = [put_value(Y, perm, A, Args, Vbls) | Cls],
		lifetime(Cs, Cls, [A | Args], Vbls)
	;
	In = [put_unsafe_value(Y, perm, A) | Cs]
	->
		Out = [put_unsafe_value(Y, perm, A, Args, Vbls) | Cls],
		lifetime(Cs, Cls, [A | Args], Vbls)
	;
	In = [put_value(X, temp, A) | Cs]
	->
                Out = [put_value(X, temp, A, Args, Vbls) | Cls],
		lifetime(Cs, Cls, [A | Args], NVbls), 
		addnew(X, NVbls, Vbls)
	;
	In = [unify_vbl(X,temp) | Cs] 
	->
		Out = [unify_vbl(X,temp,Args,Vbls) | CLs],
		lifetime(Cs, CLs, Args,  NVbls), 
		delete(X, NVbls, Vbls)
	;
	In = [unify_value(X,temp) | Cs] 
	->
		Out = [unify_value(X,temp) | CLs],
		lifetime(Cs, CLs, Args, NVbls), 
		addnew(X, NVbls, Vbls)
	;
	In = [unify_local_value(X,temp) | Cs] 
	->
		Out = [unify_local_value(X,temp) | CLs],
		lifetime(Cs, CLs, Args, NVbls), 
		addnew(X, Nvbls, Vbls)
	;
		In = [C | Cs],
		Out = [C | Cls],
		lifetime(Cs, Cls, Args, Vbls)
	).

/* listN(+, -)  create a list of integers [(N-1) .. 0] */

listN(0, []) :- !.  % green
listN(N, [N1 | T]) :-
	N > 0,
	N1 is N - 1,
	listN(N1, T).

addnew(X, L, L1) :-
	(member(X, L)
	->
		L1 = L
	;
		L1 = [X | L]
	).

/* assign_temp(+In, -Out, +Temp_vbl_assignments)  */

/* Temp vbl to register assignment starts out empty.
   Default assignment is of temp vbl to its corresponding
   register:
	get_vbl X, reget_vbl X
   Look up register assignment for:
	get_value X, unify_value X, unify_local_value X
   Conflict occurs when putting something into a register
   already in use. Must move the one already in use.
   Can occur in any of the put instructions
*/


assign_temp([], X-X, _).

assign_temp(In, Out, Assign) :-
	(In = [get_vbl(X, temp, A) | Cs] 
	->
		Out = [get_vbl(A, temp, A) | Cls]-D,
		assign_temp(Cs, Cls-D, [X/A | Assign])
	;
	In = [get_value(X, temp, A) | Cs] 
	->
		Out = [get_value(Z, temp, A) | Cls]-D,
        	member(X/Z, Assign),
		assign_temp(Cs, Cls-D, Assign)
	;
	In = [reget_vbl(X, temp, A) | Cs] 
	->
		Out = [reget_vbl(A, temp, A) | Cls]-D,
		assign_temp(Cs, Cls-D, [X/A | Assign])
	;
	In = [put_const(C, A, Args, Vbls) | Cs]
	->
		(member(A1/A, Assign)   % conflict has occurred
		->
			Out = [put_value(A, temp, B), put_const(C, A) | Cls]-D,
			nextfree(0, B, Args, Vbls, Assign),
			delete(A1/A, Assign, NAssign),
			assign_temp(Cs, Cls-D, [A1/B | NAssign])
		;
			Out = [put_const(C, A) | Cls]-D,
			assign_temp(Cs, Cls-D, Assign)
		)
	;
	In = [put_struct(S, A, Args, Vbls) | Cs]
	->
		(member(A1/A, Assign)   % conflict has occurred
		->
			Out = [put_value(A, temp, B), put_struct(S, A) | Cls]-D,
			nextfree(0, B, Args, Vbls, Assign),
			delete(A1/A, Assign, NAssign),
			assign_temp(Cs, Cls-D, [A1/B | NAssign])
		;
			Out = [put_struct(S, A) | Cls]-D,
			assign_temp(Cs, Cls-D, Assign)
		)
	;
	In = [put_vbl(Y, perm, A, Args, Vbls) | Cs]
	->
		(member(A1/A, Assign)   % conflict has occurred
		->
			Out = [put_value(A, temp, B), put_vbl(Y, perm, A) | Cls]-D,
			nextfree(0, B, Args, Vbls, Assign),
			delete(A1/A, Assign, NAssign),
			assign_temp(Cs, Cls-D, [A1/B | NAssign])
		;
			Out = [put_vbl(Y, perm, A) | Cls]-D,
			assign_temp(Cs, Cls-D, Assign)
		)
	;
	In = [put_value(Y, perm, A, Args, Vbls) | Cs]
	->
		(member(A1/A, Assign)   % conflict has occurred
		->
			Out = [put_value(A, temp, B), put_value(Y, perm, A) | Cls]-D,
			nextfree(0, B, Args, Vbls, Assign),
			delete(A1/A, Assign, NAssign),
			assign_temp(Cs, Cls-D, [A1/B | NAssign])
		;
			Out = [put_value(Y, perm, A) | Cls]-D,
			assign_temp(Cs, Cls-D, Assign)
		)
	;
	In = [put_unsafe_value(Y, perm, A, Args, Vbls) | Cs]
	->
		(member(A1/A, Assign)   % conflict has occurred
		->
			Out = [put_value(A, temp, B), put_unsafe_value(Y, perm, A) | Cls]-D,
			nextfree(0, B, Args, Vbls, Assign),
			delete(A1/A, Assign, NAssign),
			assign_temp(Cs, Cls-D, [A1/B | NAssign])
		;
			Out = [put_unsafe_value(Y, perm, A) | Cls]-D,
			assign_temp(Cs, Cls-D, Assign)
		)
	;
	In = [put_vbl(X, temp, A, Args, Vbls) | Cs] 
	->
		(member(A1/A, Assign)   % conflict has occurred
		->
			Out = [put_value(A, temp, B), put_vbl(A, temp, A) | Cls]-D,
			nextfree(0, B, Args, Vbls, Assign),
			delete(A1/A, Assign, NAssign),
			assign_temp(Cs, Cls-D, [A1/B, A/A | NAssign])
		;
			Out = [put_vbl(A, temp, A) | Cls]-D,
			assign_temp(Cs, Cls-D, [X/A | Assign])
		)
	;
	In = [put_value(X, temp, A, Args, Vbls) | Cs]
	->
         	(member(X/A1, Assign),
         	 A = A1
		->
        		Out = [put_value(A, temp, A) | Cls]-D,
			assign_temp(Cs, Cls-D, Assign)
		;
         		(member(Z/A, Assign),
         		 member(Z, Vbls)
			->
             			Out = [get_vbl(B, temp, A), 
					put_value(C, temp, A) | Cls]-D,
         			nextfree(0, B, Args, Vbls, Assign),
         			delete(X/C, Assign, N_assign),
				assign_temp(Cs, Cls-D, [Z/B | N_assign])
			;
             			Out = [put_value(B, temp, A) | Cls]-D,
         			member(X/B, Assign),
				assign_temp(Cs, Cls-D, Assign)
			)
		)
	;
	In = [unify_vbl(X, temp, Args,Vbls) | Cs] 
	->
		Out = [unify_vbl(B, temp) | Cls]-D,
         	nextfree(0, B, Args, Vbls, Assign),
		assign_temp(Cs, Cls-D, [X/B | Assign])
	;
	In = [unify_value(X, temp) | Cs] 
	->
		Out = [unify_value(B, temp) | Cls]-D,
         	member(X/B, Assign),
		assign_temp(Cs, Cls-D, Assign)
	;
	In = [unify_local_value(X, temp) | Cs] 
	->
		Out = [unify_local_value(B, temp) | Cls]-D,
        	member(X/B, Assign),
		assign_temp(Cs, Cls-D, Assign)
	;
	In = [call(P, A, N) |Cs] 
	->
		Out = [call(P, A, N) | Cls]-D,
		assign_temp(Cs, Cls-D, [])
	;
		In = [C |Cs], 
		Out = [C | Cls]-D, 
		assign_temp(Cs, Cls-D, Assign)
	).

nextfree(N, B, Args, Vbls, Assign) :-
        (member(N, Args)
	->
         	N1 is N + 1,
         	nextfree(N1, B, Args, Vbls, Assign)
	;
        member(X/N, Assign), member(X, Vbls)
        ->
         	N1 is N + 1,
         	nextfree(N1, B, Args, Vbls, Assign)
	;
		B = N
	).
