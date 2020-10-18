main :- append(X, [e | Y], L), write(X), nl,
        write(Y), nl, write(L), nl.

append([], L,L).
append([H | T], L, [H | TL]) :- append(T, L, TL).
