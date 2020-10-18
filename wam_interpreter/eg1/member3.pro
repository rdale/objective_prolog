main :- member(d, [a,b,c]), write(ok).

member(H, [H | T]).
member(X, [H | T]) :- member(X, T).
