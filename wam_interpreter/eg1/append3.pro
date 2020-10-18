main :- append(Z,W,[a,b,c,d,e]), append(X, [U | Y], Z),
        write(U), nl, write(V), nl, write(W), nl,
        write(X), nl, write(Y), nl, write(Z).

append([], L,L).
append([H | T], L, [H | TL]) :- append(T, L, TL).
