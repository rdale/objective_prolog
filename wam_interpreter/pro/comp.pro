
/* Prolog to WAM compiler 
	module comp.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* comp_clause(+Clause, +MaxVarsInClause, -Code)

   translates a clause into a dlist of terms
	put_vbl, get_vbl, unify_vbl
   and similarly with constants and structures
   This is the first pass of the compilation for an individual clause.
   It does not analyise variables at all.
*/



number_args([], [], N, N).
number_args([A | As],  [(A, N) | ANs],  N,  M) :-
	N1 is N+1,
	number_args(As,  ANs,  N1,  M).

comp_clause(Clause,  MaxV,  X-Y) :-
	(Clause = (H:-B)
	->
		comp_head(H, MaxV, X-Z),
		comp_body(B, MaxV, Z-Y)
	;
		comp_head(Clause, MaxV, X-[proceed | Y])
	).

comp_head(H, MaxV, X-Y) :-
	H =.. [_ | Args], 
        number_args(Args, ArgsNum, 0, Argcount),  
	comp_head_terms(ArgsNum, X-Y, MaxV, Argcount).


comp_head_term(C, A, [get_const(C, A) | X]-X, _, _) :-
	const(C), !.    % green
comp_head_term(V, A, [get_vbl(N, A) | X]-X, _, _) :-
	vbl(V, N), !.   % green
comp_head_term(L, A, [get_list(L, A) | X]-X, _, _) :-
	list(L), !.     % green
comp_head_term(F, A, [get_struct(Func/Arity, A) | X]-Y, MaxV, MaxR) :-
	structure(F, Func, Args, Arity), 
	comp_head_nested_terms(Args, X-Z, MaxV, NewV, MaxR, NewR, NestedTerms-[]), 
	comp_head_terms(NestedTerms, Z-Y, NewV, NewR).

comp_head_terms([], X-X, _, _).
comp_head_terms([(T, A) | Terms], X-Y, MaxV, MaxR) :-
	comp_head_term(T, A, X-Z, MaxV, MaxR), 
	comp_head_terms(Terms, Z-Y, MaxV, MaxR).

comp_head_nested_terms([], X-X, MaxV, MaxV, MaxR, MaxR, Z-Z).
comp_head_nested_terms([T | Terms], X-Y, MaxV, NewV, MaxR, NewR, Z1-Z2) :-
	comp_head_nested_term(T, X-Z, MaxV, NextV, MaxR, NextR, Z1-Z3),
	comp_head_nested_terms(Terms, Z-Y, NextV, NewV, NextR, NewR, Z3-Z2).

comp_head_nested_term(C, [unify_const(C) | X]-X, MaxV, MaxV, MaxR, MaxR, Z-Z) :-
	const(C), !.    % green
comp_head_nested_term(V, [unify_vbl(N) | X]-X, MaxV, MaxV, MaxR, MaxR, Z-Z) :-
	vbl(V, N), !.   % green
comp_head_nested_term(F, [unify_vbl(MaxV), put_value(MaxV, temp, MaxR) | X]-X, 
		MaxV, NextV, MaxR, NextR, [(F, MaxR) | Z]-Z) :-
	structure(F, _, _, _), 
	NextV is MaxV+1,
	NextR is MaxR+1.

const(C) :-
	atomic(C).

vbl('$VAR'(N), N).

structure(F, Func, Args, Arity) :-
	F =.. [Func | Args], 
	functor(F, _, Arity).


comp_body(Body, MaxV, X-Y) :- 
	(Body = (B1,B2)
	->
		comp_body_atom(B1, MaxV, Pred, Arity, X-[call(Pred, Arity) | Z]),
		comp_body(B2, MaxV, Z-Y)
	;
		comp_body_atom(Body, MaxV, Pred, Arity, 
			X-[execute(Pred, Arity) | Y])
	).

		

comp_body_atom(B, MaxV, Pred, Arity, X-Y) :-
	B =.. [Pred | Args],
	number_args(Args, ArgsNum, 0, Argcount),  
	Arity is Argcount,
	comp_body_terms(ArgsNum, X-Y, MaxV, Argcount).

comp_body_term(C, A, [put_const(C, A) | X]-X, _, _) :-
	const(C), !.    % green
comp_body_term(V, A, [put_vbl(N, A) | X]-X, _, _) :-
	vbl(V, N), !.   % green
comp_body_term(L, A, [put_list(L, A) | X]-X, _, _) :-
	list(L), !.     % green
comp_body_term(F, A, X-Y, MaxV, MaxR) :-
	structure(F, Func, Args, Arity), 
	comp_body_nested_terms(Args, Z-Y, MaxV, NewV, MaxR, NewR, NestedTerms-[]), 
	comp_body_terms(NestedTerms, X-[put_struct(Func/Arity, A) | Z], NewV, NewR).

comp_body_terms([], X-X, _, _).
comp_body_terms([(T, A) | Terms], X-Y, MaxV, MaxR) :-
	comp_body_term(T, A, X-Z, MaxV, MaxR), 
	comp_body_terms(Terms, Z-Y, MaxV, MaxR).

comp_body_nested_terms([], X-X, MaxV, MaxV, MaxR, MaxR, Z-Z).
comp_body_nested_terms([T | Terms], X-Y, MaxV, NewV, MaxR, NewR, Z1-Z2) :-
	comp_body_nested_term(T, X-Z, MaxV, NextV, MaxR, NextR, Z1-Z3), 
	comp_body_nested_terms(Terms, Z-Y, NextV, NewV, NextR, NewR, Z3-Z2).

comp_body_nested_term(C, [unify_const(C) | X]-X, MaxV, MaxV, MaxR, MaxR, Z-Z) :-
	const(C), !.    % green
comp_body_nested_term(V, [unify_vbl(N) | X]-X, MaxV, MaxV, MaxR, MaxR, Z-Z) :-
	vbl(V, N), !.   % green
comp_body_nested_term(F, [reget_vbl(MaxV, temp, MaxR), 
                   unify_value(MaxV, temp) | X]-X,
		MaxV, NextV, MaxR, NextR, [(F, MaxR) | Z]-Z) :-
	structure(F, _, _, _), 
	NextV is MaxV+1,
	NextR is MaxR+1.
