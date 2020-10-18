/* Prolog to WAM compiler 
	module vbl_valu.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* vbl_value_s(+Code, +Vbls_processed_so_far, -Output_code, -Unsafe_vbls)

   changes get_vbl and put_vbl for permanent vbls into the full range of
   put_vbl, put_value, put_unsafe_value, etc.
   It uses the output of pgreenicate 'perm_tmp'
*/

vbl_value_s([], FirstOccur, C-C, Unsafe) :-
	unsafe(FirstOccur, Unsafe).

vbl_value_s([X | T], FirstOccur, [NewX | NewT]-C, Unsafe) :-
	vbl_value(X, FirstOccur, MidX, NextOccur),
	vbl_value_s(T, NextOccur, NewT-C, Uns),
	fix_unsafe(MidX, Uns, NewX, Unsafe).

vbl_value(put_vbl(X, Type, A), Seen, C, NewSeen) :- !, % green
	(member(X/_, Seen)
	->	C = put_value(X, Type, A),
		NewSeen = Seen
	;	C = put_vbl(X, Type, A),
		NewSeen = [X/put_vbl(Type) | Seen]
	).

vbl_value(get_vbl(X, Type, A), Seen, C, NewSeen) :- !, % green
	(member(X/_, Seen)
	->	C = get_value(X, Type, A),
		NewSeen = Seen
	;	C = get_vbl(X, Type, A),
		NewSeen = [X/get_vbl | Seen]
	).

vbl_value(unify_vbl(X, Type), Seen, C, NewSeen) :- !, % green
	(delete(X/T, Seen, TSeen)
	->	fix_unify_local(X,T,Type,C,NewT),
		NewSeen = [X/NewT | TSeen]
	;	C = unify_vbl(X, Type),
		NewSeen = [X/unify_vbl | Seen]
	).

vbl_value(C, Seen, C, Seen) :- % none of the above
	C \= put_vbl(_,_,_),
	C \= get_vbl(_,_,_),
	C \= unify_vbl(_,_).

fix_unify_local(X,get_vbl, Type, unify_local_value(X,Type), get_unify) :- !. % green
fix_unify_local(X,put_vbl, Type, unify_local_value(X,Type), put_unify(Type)) :- !. % green
fix_unify_local(X,T, Type, unify_value(X,Type), T) :-  % none of the above
	T \= get_vbl,
	T \= put_vbl.


fix_unsafe(put_value(X, perm, A), Uns, C, Unsafe) :- !, % green
	(delete(X, Uns, Unsafe)
	->	C = put_unsafe_value(X, perm, A)
	;	C = put_value(X, perm, A),
		Unsafe = Uns
	).
fix_unsafe(C, Unsafe, C, Unsafe) :-
	C \= put_value(_,perm,_).

unsafe([], []).
unsafe([X/put_vbl(perm) | T], [X | NewT]) :- !, % green
	unsafe(T, NewT).
unsafe([X/put_unify(perm) | T], [X | NewT]) :- !, % green
	unsafe(T, NewT).
unsafe([X | T], [X | NewT]) :- % neither of the last two
	X \= _/put_vbl(perm),
	X \= _/put_unify(perm),
	unsafe(T, NewT).

delete(X, [X | T], T) :- !. % green
delete(X, [H | T], [H | NewT]) :-
	delete(X, T, NewT).
