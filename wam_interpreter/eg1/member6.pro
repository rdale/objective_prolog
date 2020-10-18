main :- member(X, Y), write(X), nl, write(Y).

member(H, [H | T]).
member(X, [H | T]) :- member(X, T).
