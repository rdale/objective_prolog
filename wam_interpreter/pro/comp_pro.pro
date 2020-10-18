
/* Prolog to WAM compiler 
	module comp_pro.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* comp_prog(+Current_pred, -Code_for_pred)

   Compiles a program a predicate at a time. The first arg is the
   name of the current pred being compiled, in the form Functor/Arity.
   The clauses for a pred are read in in total.
   When the clause read in belongs to a different pred then the whole
   thing is compiled and printed, and execution continues with the
   next pred.

                 -----------------------------

   comp_pred(+Pred_name, +List_of_clauses, -Code)

   Compiles an individual predicate consisting of >=1 clauses.

                  -----------------------------

   wam_clause(+Clause, -Code)

   Compiles an individual clause.
*/


c :-
	comp_prog(null_pred, X-X).

comp_prog(end_of_file/0, _) :- !. % green
comp_prog(Curr_pred, PredSoFar) :-
	Curr_pred \= end_of_file/0,
	read(Cl),
	predicate(Cl, Pred),
	comp_preds(Curr_pred, Pred, Cl, PredSoFar).

comp_preds(Pred, Pred, Cl, X-[Cl | Y]) :- !,  % green 
	comp_prog(Pred, X-Y).
comp_preds(Pred, NextPred, NextCl, Cls-[]) :-
	Pred \= NextPred,
	comp_pred(Pred, Cls, Code),
	pp_code(Code),
	comp_prog(NextPred, [NextCl | X]-X).

comp_pred(_, [], []) :- !.  % green on 2nd arg
comp_pred(Pred, [Cl1, Cl2 | Cls], [pred(Pred), try_me_else(L) | X]) :- !, % green
	wam_clause(Pred, Cl1, X-Y),
	comp_clauses(Pred, [Cl2 | Cls], Y-[]),
	dlength(X-Y, Len),
	L is Len+1.
comp_pred(Pred, [Cl], [pred(Pred) | X]) :-
	wam_clause(Pred, Cl, X-[]).

comp_clauses(Pred, [Cl], [trust_me_else | X]-Y) :- !, % green
	wam_clause(Pred, Cl, X-Y).
comp_clauses(Pred, [Cl1, Cl2 | Cls], [retry_me_else(L) | X]-Y) :-
	wam_clause(Pred, Cl1, X-Z),
	comp_clauses(Pred, [Cl2 | Cls], Z-Y),
	dlength(X-Z, Len),
	L is Len+1.

wam_clause(Pred, Cl, Code7) :-
	numbervars(Cl, 0, N), 
	comp_clause(Cl, N, Code1-[]), 
	permanent_vbls(Cl, Perms, Void),
	perm_tmp(Code1, Perms, Void, Code2-[]),
	vbl_value_s(Code2, [], Code3-[], _),
	number_perms(Code3, _, _, Code4-[]),
	alloc_dealloc(Code4-[], Perms, Code5-[]),
	unify_void(Code5, Code6),
	number_temps(Pred, Code6, Code7).




dlength(X-Y, 0) :- X == Y, !. % green. nonlogical == is due to lack of occurs check
dlength(X-Y, Len) :-
	X \== Y,
	X = [_ | Z],
	dlength(Z-Y, L),
	Len is L+1.

predicate((H:-_), F/A) :- !, % green
	functor(H, F, A).
predicate(H, F/A) :-
	H \= (_ :- _),
	functor(H, F, A).

pp_code([]) :- nl.
pp_code([H | T]) :-
	pp_instr(H), nl,
	pp_code(T).

% cuts in here are green
pp_instr(allocate) :- write(allocate).
pp_instr(deallocate) :- write(deallocate).
pp_instr(try_me_else(L)) :- writelist([try_me_else, ' ', L]).
pp_instr(retry_me_else(L)) :- writelist([retry_me_else, ' ', L]).
pp_instr(trust_me_else) :- writelist([trust_me_else, ' ', fail]).
pp_instr(proceed) :- write(proceed).
pp_instr(execute(P,A)) :- 
        (built_in(P, A)
	->
        	writelist([built_in, ' ', P]),
         	nl,
         	writelist([proceed])
	;
		writelist([execute, ' ', P, '/', A])
	).
pp_instr(call(P,A,N)) :- 
        (built_in(P, A)
	->
        	writelist([built_in, ' ', P])
	;
		writelist([call, ' ', P, '/', A, ',', N])
	).
pp_instr(pred(F/A)) :- writelist([F, '/', A, ' ', ':']).
pp_instr(get_vbl(Y, perm, A)) :- !, writelist([get_variable, ' Y', Y, ',A', A]).
pp_instr(get_vbl(X, temp, A)) :- writelist([get_variable, ' X', X, ',A', A]).
pp_instr(reget_vbl(X, temp, A)) :- writelist([get_variable, ' X', X, ',A', A]).
pp_instr(get_value(Y, perm, A)) :- !, writelist([get_value, ' Y', Y, ',A', A]).
pp_instr(get_value(X, temp, A)) :- writelist([get_value, ' X', X, ',A', A]).
pp_instr(put_vbl(Y, perm, A)) :- !, writelist([put_variable, ' Y', Y, ',A', A]).
pp_instr(put_vbl(X, temp, A)) :- writelist([put_variable, ' X', X, ',A', A]).
pp_instr(put_value(Y, perm, A)) :- !, writelist([put_value, ' Y', Y, ',A', A]).
pp_instr(put_value(X, temp, A)) :- writelist([put_value, ' X', X, ',A', A]).
pp_instr(put_unsafe_value(Y, perm, A)) :- writelist([put_unsafe_value, ' Y', Y, ',A', A]).
pp_instr(get_const(C,A)) :- writelist([get_const, ' ', C, ',A', A]).
pp_instr(get_struct(F/N,A)) :- writelist([get_structure, ' ', F, '/', N, ',A', A]).
pp_instr(put_const(C,A)) :- writelist([put_const, ' ', C, ',A', A]).
pp_instr(put_struct(F/N,A)) :- writelist([put_structure, ' ', F, '/', N, ',A', A]).
pp_instr(unify_void(N)) :- writelist([unify_void, ' ', N]).
pp_instr(unify_vbl(X, temp)) :- !, writelist([unify_variable, ' X', X]).
pp_instr(unify_vbl(Y, perm)) :- writelist([unify_variable, ' Y', Y]).
pp_instr(unify_value(X, temp)) :- !, writelist([unify_value, ' X', X]).
pp_instr(unify_value(Y, perm)) :- writelist([unify_value, ' Y', Y]).
pp_instr(unify_local_value(X, temp)) :- !, writelist([unify_local_value, ' X', X]).
pp_instr(unify_local_value(Y, perm)) :- writelist([unify_local_value, ' Y', Y]).
pp_instr(unify_const(C)) :- writelist([unify_constant, ' ', C]).

built_in(write, 1).
built_in(nl, 0).

writelist([]).
writelist([H|T]) :-
	write(H),
	writelist(T).
