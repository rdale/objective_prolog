main :- member(c, [a,b,c]), write(ok).

member(H, [H | T]).
member(X, [H | T]) :- member(X, T).
