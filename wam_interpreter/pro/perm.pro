/* Prolog to WAM compiler 
	module perm.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* permanent_vbls(+Clause, -PermanentVblList)

   given a clause retuns a list of the permanent vbls,
   as numbered from their first occurrence.
   It is an early pass of compilation of a clause.
*/


permanent_vbls(Clause, Perms, Void) :-
	(Clause = (H:-B1,B2)
	->
		vars_in_atoms((f(H,B1),B2), Vs),
		perms(Vs, [], Perms),
		voids(Vs, Perms, [], Void)
	;
	Clause = (H:-B)
	->
		Perms = [],
		vars_in_atoms(f(H,B), Vs),
		voids(Vs, [], [], Void)
	;
		Perms = [],
		vars_in_atoms(Clause , Vs),
		voids(Vs, [], [], Void)
	).

perms([], Perms, Perms).
perms([[] | Rest], SoFar, Perms) :- !, % green
	perms(Rest,  SoFar, Perms).
perms([[V1 | Vs] | Rest], SoFar, Perms) :-
	(member(V1, SoFar)
	 -> 	perms([Vs | Rest], SoFar, Perms)
	 ;
		(nested_member(V1, Rest)
	 	 ->	perms([Vs | Rest], [V1 | SoFar], Perms)
		 ;	perms([Vs | Rest], SoFar, Perms)
		)
	).

member(X, [X | _]) :- !.  % green
member(X, [_ | T]) :-
	member(X,T).

nested_member(X,[H | _]) :- 
	member(X,H), !.   % green
nested_member(X,[_ | T]) :-
	nested_member(X,T).
vars_in_atoms(Atoms, Vbls) :-
	(Atoms = (A1,As)
	->
		Vbls = [V1 | Vs],
		vars_in_atom(A1,V1),
		vars_in_atoms(As,Vs)
	;	% Atoms = a single one
		Vbls = [Vs],
		vars_in_atom(Atoms, Vs)
	).

vars_in_atom(A, Vs) :-
	A =.. [_ | Ts],
	vars_in_terms(Ts, Vs-[]).

vars_in_terms([], X-X).
vars_in_terms([T | Ts], X-Y) :-
	vars_in_term(T, X-Z),
	vars_in_terms(Ts, Z-Y).

vars_in_term(V, [N | X]-X) :-
	vbl(V, N), !.   % green
vars_in_term(C, X-X) :-
	const(C), !.    % green
vars_in_term(F, X-Y) :-
	structure(F, _, Args, _),
	vars_in_terms(Args, X-Y).

voids([], _, Void, Void).
voids([V | Vs], Perms, Vin, Vout) :-
	void(V, Perms, Vin, Vmid),
	voids(Vs, Perms, Vmid, Vout).

void([], _, Vs, Vs).
void([V | Vs], Perms, Vin, Vout) :-
	delete_all(V, Vs, D),
	void(D, Perms, Vin, Vmid),
	(D = Vs
	 ->	(member(V, Perms)
		 ->	Vout = Vmid
		 ;	Vout = [V | Vmid]
		)
	 ;	Vout = Vmid
	).

delete_all(_, [], []) :- !.  % green in 2nd arg
delete_all(X, [H | T], D) :- 
	(X = H
	->
		delete_all(H, T, D)
	;
		D = [H | D1],
		delete_all(X, T, D1)
	).
