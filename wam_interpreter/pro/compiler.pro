/* Prolog to WAM compiler 
	module compiler.pro
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* This loads the relevant files apart from any compatability
   files required. Note that under Arity, which has an
   unusual def of '->', the file 'arity.pro' MUST be loaded first
   to correct this to the more normal one for the files which follow.
   Similarly, under Sicstus Prolog the file 'sicstus.pro' must be loaded
   to give the definition of 'not'.
*/


:- consult('comp.pro'), write(comp),nl.
:- consult('perm.pro'), write(perm),nl.
:- consult('perm_temp.pro'), write(perm_temp),nl.
:- consult('number_perms.pro'), write(number_perms),nl.
:- consult('vbl_value.pro'), write(vbl_value),nl.
:- consult('unify_void.pro'), write(unify_void),nl.
:- consult('number_temps.pro'), write(number_temps),nl.
:- consult('comp_prog.pro'), write(comp_prog),nl.
:- consult('alloc_dealloc.pro'), write(alloc_dealloc),nl.

compile_file(F) :-
  see(F),
  comp_prog(null_proc, X-X),
  seen.
