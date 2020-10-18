main :- classification(h1, X), write(X).

classification(A, C) :- animal(C, L), member(A, L).

animal(animal(V), X) :- aquatic(V, X).
animal(animal(V), X) :- terrestrial(V, X).

aquatic(aquatic, [a1, a2]).

terrestrial(terrestrial(V), X) :- reptile(V, X).
terrestrial(terrestrial(V), X) :- bird(V, X).
terrestrial(terrestrial(V), X) :- mammal(V, X).

reptile(reptile, [r1]).

bird(bird, [b1, b2]).

mammal(mammal(V), X) :-  herbivore(V, X).
mammal(mammal(V), X) :-  omnivore(V, X).

herbivore(herbivore, [h1]).

omnivore(omnivore, [o1, o2]).

member(H, [H | T]).
member(X, [H | T]) :- member(X, T).
