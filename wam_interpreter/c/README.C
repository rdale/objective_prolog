This directory contains files for a WAM emulator in 'C', which
executes WAM instructions interpretively. The emulator files are

  CONST.H
  TYPES.H
  TAGS.H
  PORTABLE.H

  LOAD.C    
  UNIFY.C    
  MEM.C    
  MAIN.C    
  WAM.C    

Tag mechanisms are given for 2 types of machine. For a 32 bit integer
machine such as a Sun define the variable "tag_32_hi" in "tags.h".
For a 16 bit integer machine such as a PC define the variable
"tag_16_hi" in "tags.h".

The language is as 'defined' in Warren's 83 SRI paper.

The following instructions are not supported:
	
	switch_on_constant
	switch_on_structure

The following variation is used: registers and temporary variables
are numbered from zero upwards instead on one.

The following extensions are in place:

.	The first lines of a file may be comments.
	Each of these comment lines must begin with a '%'
	(even if rest of line is blank).
	No comments are allowed elsewhere.

.	Each instruction is regarded as occupying one logical line.
	Extra whitespace is ignored, so extra blank lines may be
	introduced, or many instructions can appear on the same line.

.	A number of built-in extension functions are available:

		write, nl
	These are invoked by
		built_in write
		built_in nl

	The instruction 'write' outputs the dereferenced contents of A0

The following restrictions are in place:

.	The first line of program must define the entry point
		main/0
	The program will start there (and crash if it isn't).

.	The symbolic proc name in a 'call' or 'execute' must 
	appear as in the WAM

.	The branch label in 'try_me_else' etc must be replaced by the
	offset from the current instruction number
	instruction number. 

.	The branch label in trust_me_else and trust
	must be the word 'fail'

EXAMPLE

The Prolog program

      main :-
        append([1,2,3], [4,5,6], L),
        write(L).
      
      append([], L, L).
      append([X | T], L, [X | T1]) :-
        append(T, L, T1).

has corresponding WAM code of

      main/0 :
      put_structure ./2,A4
      unify_constant 3
      unify_constant []
      put_structure ./2,A3
      unify_constant 2
      get_variable X2,A4
      unify_value X2
      put_structure ./2,A0
      unify_constant 1
      get_variable X1,A3
      unify_value X1
      put_structure ./2,A4
      unify_constant 6
      unify_constant []
      put_structure ./2,A3
      unify_constant 5
      get_variable X2,A4
      unify_value X2
      put_structure ./2,A1
      unify_constant 4
      get_variable X2,A3
      unify_value X2
      allocate
      put_variable Y1,A2
      call append/3,1
      put_unsafe_value Y1,A0
      deallocate
      built_in write
      proceed
      
      append/3 :
      try_me_else 5
      get_const [],A0
      get_variable X1,A1
      get_value X1,A2
      proceed
      
      trust_me_else fail
      get_structure ./2,A0
      unify_variable X3
      unify_variable X0
      get_variable X1,A1
      get_structure ./2,A2
      unify_value X3
      unify_variable X2
      put_value X0,A0
      put_value X1,A1
      put_value X2,A2
      execute append/3


-----------------------------------------------------------------------------

The internals of the emulator memory organisation are as follows:

Data is stored as tagged. The top 3 bits are for the tag, which can
distinguish: constant, nil-list, non-nil list, unbound variable,
reference to a variable, structure.

The tags are given in "tags.h".
Tag mechanisms for two representations are given: a 32 bit data word,
with the tag using the 3 high bits, and a 16 bit data word again
using the 3 high bits for the tag.

A variable occupies one data word on the local or global stacks.

An unbound variable points to itself, in addition to having a
variable tag.

A constant occupies one word, and its value is a pointer to a
symbol table.

A list constructor occupies one word consisting of a list tag
and a pointer to itself.

A functor constructor occupies two words: the first word contains the
tag and a self pointer, while the second holds a pointer to a symbol
table.
(Self pointers allow for dereference chains to stop at nice places).

An environment holds: 
  CE - The continuation environment. i.e. when the current clause
	successfully completes, and we continue with the parent
	then this is the parent's environment
  CP -	The program continuation. i.e. when the current clause
	successfully completes then program execution continues
	from this point. CP is the address of the NEXT instruction
	after the call/execute which invoked this clause.
  vbls - The permanent vbls are stored immediately above CE, CP.

A choice point holds (from bottom to top):

  regs - Copies of the values of the argument registers when this
	procedure was invoked. It is of fixed size 0..(MAXREG - 1), and
	so saves some bogus values
  B -	The top of the choice point before this one was created
  TR -	The top of the trail stack
  E -	The current env pointer
  H -	The current top of heap
  CP -	The continuation pointer for this predicate
  L -	The retry address of this current clause fails.

Memory is organised from bottom to top:

  heap - all constructed terms and some 'globalised' vbls
  stack - choice points and environments
  trail - trailed vbls

A pushdown stack somewhere in memory should be used for unification.
It is not used here as a recursive function 'unify' uses the system
stack instead, courtesy of the local 'C' compiler.

