main :- member(X, [a,b,c]), write(X).

member(H, [H | T]).
member(X, [H | T]) :- member(X, T).
