main :- nrev([a,b,c,d], R), write(R).

nrev([], []).
nrev([H | T], R) :-
  nrev(T, TR),
  append(TR, [H], R).

append([], L,L).
append([H | T], L, [H | TL]) :- append(T, L, TL).
