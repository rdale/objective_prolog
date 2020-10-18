/* Prolog to WAM compiler 
	module arity.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

% redefine -> for Edinburgh standard P -> Q;R
:- op(0, xfy, ->).
:- op(1100,xfy, -> ).

'->'(P,(Q;R)) :- P,!,Q.
'->'(P,(Q;R)) :- R.


% numbervars(T, Init, Last)

numbervars(V, I, N) :-
  var(V), !,    % red
  V = '$VAR'(I),
  N is I + 1.

numbervars(A, I, I) :-
  atomic(A), !.   % red

numbervars([H | T], I, N) :- !,  % red
  numbervars(H, I, M),
  numbervars(T, M, N).

numbervars(F, I, N) :-
  F =.. [_ | Args],
  numbervars(Args, I, N).
