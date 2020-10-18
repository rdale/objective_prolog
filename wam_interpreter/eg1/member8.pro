main :- member(a(b(X)), [a(1), a(b(2))]), write(X).

member(H, [H | T]).
member(X, [H | T]) :- member(X, T).
