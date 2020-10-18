main :- append([a], [b], X), write(X).

append([], L,L).
append([H | T], L, [H | TL]) :- append(T, L, TL).
