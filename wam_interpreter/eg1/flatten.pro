
main :- flatten([[a,b,c, [d,e,f]], []], L), write(L).

flatten([], []).
flatten([[] | T], L) :- flatten(T, L).
flatten([[X|Y] | T], L) :-
  flatten([X|Y], L1),
  flatten(T, L2),
  append(L1, L2, L).
flatten([H | T], [H | L]) :- flatten(T, L).

append([], L,L).
append([H | T], L, [H | TL]) :- append(T, L, TL).
