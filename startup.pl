/*
	startup.pl
	
	Author:	Richard Dale
	Date:	Jul 1997
	Copyright (c) 1993-1997 Richard Dale.
	
	$Header$
*/

/*
 * $Log$
 */

','(Q, R) :- Q, R.

(If -> Then) :- If, !, Then.

(If -> Then; _Else) :- If, !, Then.
(_If -> _Then; Else) :- !, Else.
';'(Goal, _) :- Goal.
';'(_, Goal) :- Goal.

append([], L, L).
append([X | L1], L2, [X | L3]) :- append(L1, L2, L3).

call(X) :- X.

list(L) :- nonvar(L), L = [_ | _].

member(X, [X | _]).
member(X, [_ | T]) :-
	member(X, T).

not(P) :- P, !, fail.
not(P).

numbervars(V, I, N) :-
  var(V), !,
  V = '$VAR'(I),
  N is I + 1.

numbervars(A, I, I) :-
  atomic(A), !.

numbervars([H | T], I, N) :- !,
  numbervars(H, I, M),
  numbervars(T, M, N).

numbervars(F, I, N) :-
  F =.. [_ | Args],
  numbervars(Args, I, N).

:- chdir('/private/Net/ln4d604hds/home15/daler/Prolog/test').

