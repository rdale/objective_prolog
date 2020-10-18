/* Prolog to WAM compiler 
	module number_p.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* number_perms(+Code, +Perms, +NumberPerms, -NewCode)

   Given code, it returns new code which has the permanent vbls in it
   numbegreen from their occurrence from the end of the code. It
   also fixes the env size in call instructions.

   It uses the output of vbl_value_s
*/

number_perms([], [], 0, A-A) :- !.  % green
number_perms([H | X], Perms, NPerms, [NewH | A]-B) :-
	number_perms(X, Ps, NPs, A-B),
	number_perm(H, Ps, NPs, NewH, Perms, NPerms).

number_perm(get_vbl(N, perm, A), Ps, NPs, get_vbl(Label, perm, A), Perms, NPerms) :- !, % green
	(member(N/Label, Ps)
	->	Perms = Ps, NPerms = NPs
	;	Perms = [N/NPerms | Ps],
		NPerms is NPs+1,
		Label = NPerms
	).

number_perm(put_vbl(N, perm, A), Ps, NPs, put_vbl(Label, perm, A), Perms, NPerms) :- !, % green
	(member(N/Label, Ps)
	->	Perms = Ps, NPerms = NPs
	;	Perms = [N/NPerms | Ps],
		NPerms is NPs+1,
		Label = NPerms
	).

number_perm(unify_vbl(N, perm), Ps, NPs, unify_vbl(Label, perm), Perms, NPerms) :- !, % green
	(member(N/Label, Ps)
	->	Perms = Ps, NPerms = NPs
	;	Perms = [N/NPerms | Ps],
		NPerms is NPs+1,
		Label = NPerms
	).

number_perm(get_value(N, perm, A), Ps, NPs, get_value(Label, perm, A), Perms, NPerms) :- !, % green
	(member(N/Label, Ps)
	->	Perms = Ps, NPerms = NPs
	;	Perms = [N/NPerms | Ps],
		NPerms is NPs+1,
		Label = NPerms
	).

number_perm(put_value(N, perm, A), Ps, NPs, put_value(Label, perm, A), Perms, NPerms) :- !, % green
	(member(N/Label, Ps)
	->	Perms = Ps, NPerms = NPs
	;	Perms = [N/NPerms | Ps],
		NPerms is NPs+1,
		Label = NPerms
	).

number_perm(put_unsafe_value(N, perm, A), Ps, NPs, put_unsafe_value(Label, perm, A), Perms, NPerms) :- !, % green
	(member(N/Label, Ps)
	->	Perms = Ps, NPerms = NPs
	;	Perms = [N/NPerms | Ps],
		NPerms is NPs+1,
		Label = NPerms
	).

number_perm(unify_value(N, perm), Ps, NPs, unify_value(Label, perm), Perms, NPerms) :- !, % green
	(member(N/Label, Ps)
	->	Perms = Ps, NPerms = NPs
	;	Perms = [N/NPerms | Ps],
		NPerms is NPs+1,
		Label = NPerms
	).

number_perm(call(Proc,Arity), Ps, NPs, call(Proc, Arity, NPs), Ps, NPs) :- !. % green
number_perm(X, Ps, NPs, X, Ps, NPs) :- % none of the above
	X \= get_vbl(_,perm,_),
	X \= put_vbl(_,perm,_),
	X \= unify_vbl(_,perm),
	X \= get_value(_,perm,_),
	X \= put_value(_,perm,_),
	X \= put_unsafe_value(_,perm,_),
	X \= unify_value(_,perm),
	X \= call(_,_).
