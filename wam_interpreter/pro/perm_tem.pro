/* Prolog to WAM compiler 
	module perm_tem.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* perm_tmp(+Code, +PermanentVbls, -Code)

   Given a list of permanent vbls and code which has put_vbl(X)
   and get_vbl(X), repalces these with put_vbl(X,temp) etc.
   It requires the output of predicates 'comp_clause' and 'permanent_vbls'
*/

perm_tmp([], _, _, A-A) :- !.  % green
perm_tmp([H | X], Perms, Void, [NewH | A]-B) :-
	add_perm_tmp(H, Perms, Void, NewH),
	perm_tmp(X, Perms, Void, A-B).

add_perm_tmp(get_vbl(X,A), Perms, _, get_vbl(X, Type, A)) :- !, % green
	(member(X, Perms)
	->	Type = perm
	;	Type = temp).

add_perm_tmp(put_vbl(X,A), Perms, _, put_vbl(X, Type, A)) :- !, % green
	(member(X, Perms)
	->	Type = perm
	;	Type = temp).

add_perm_tmp(unify_vbl(X), Perms, Void, unify_vbl(X, Type)) :- !, % green
	(member(X, Perms)
	->	Type = perm
	;	(member(X, Void)
		 ->	Type = void
		 ;	Type = temp
		)).

add_perm_tmp(Code, _, _, Code) :- % none of the above
	Code \= get_vbl(_,_),
	Code \= put_vbl(_,_),
	Code \= unify_vbl(_).

