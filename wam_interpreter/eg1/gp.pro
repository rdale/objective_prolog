main :- gp(X,fred), write(X), nl.

gp(X,Y) :- p(X,Z), p(Z,Y).

p(jane,tom).
p(jane,bill).
p(bill,fred).
