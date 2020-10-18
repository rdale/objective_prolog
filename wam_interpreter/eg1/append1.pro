main :- append(X, Y, [a,b]), write(X), nl, write(Y).

append([], L,L).
append([H | T], L, [H | TL]) :- append(T, L, TL).
