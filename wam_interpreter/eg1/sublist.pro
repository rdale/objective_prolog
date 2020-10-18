main :- sublist(T, [a,b]), write(T).

sublist(T, U) :- append(H,T,V), append(V,W,U).

append([], L,L).
append([H | T], L, [H | TL]) :- append(T, L, TL).
