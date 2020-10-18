 /* Prolog to WAM compiler 
	module alloc_de.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* alloc_dealloc(+InCode, +PermVbls, -OutCode)

   adds allocate/deallocate instructions to the code
*/

alloc_dealloc(Code, Perms, NewCode) :-
	add_alloc(Code, NewCode).

add_alloc(Code, NewCode) :-
	(Code = [C | Y] - Z
	->
		add_alloc1(C, Y-Z, NewCode)
	;
		Code = X - X,
		NewCode = Z - Z
	).

add_alloc1(C, In, Out) :-
	(C = call(X,A,N)
	->
		Out = [allocate, call(X,A,N) | Y1]-Z1,
		add_dealloc(In, Y1-Z1)
	;
	C = put_vbl(X,perm,A)
	->
		Out = [allocate, put_vbl(X,perm,A) | Y1]-Z1,
		add_dealloc(In, Y1-Z1)
	;
	C = get_vbl(X,perm,A)
	->
		Out = [allocate, get_vbl(X,perm,A) | Y1]-Z1,
		add_dealloc(In, Y1-Z1)
	;
	C = unify_vbl(X,perm)
	->
		Out = [allocate, unify_vbl(X,perm) | Y1]-Z1,
		add_dealloc(In, Y1-Z1)
	;
		Out = [C | Y1]-Z1,
		add_alloc(In, Y1-Z1)
	).

add_dealloc([execute(X,A) | Y]-Z, [deallocate, execute(X,A) | Y]-Z) :- !. % green
add_dealloc([C | Y]-Z, [C | Y1]-Z1) :-
	C \= execute(_,_),
	add_dealloc(Y-Z, Y1-Z1).
