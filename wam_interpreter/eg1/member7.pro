main :- member(a(X), [a(1)]), write(X).

member(H, [H | T]).
member(X, [H | T]) :- member(X, T).
