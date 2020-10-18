main :- new(Q), insert(a, Q, Q1), insert(b, Q1, Q2), delete(X, Q2, Q3),
	write(Q1), nl, write(Q2), nl,
	write(Q3), nl, write(X).


insert(X, Q1-[X|Q2], Q1-Q2).

delete(X, [X|Q1]-Q2, Q1-Q2).

new(Q-Q).
