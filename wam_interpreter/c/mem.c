
/* WAM emulator
	module mem.c
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

#include "portable.h"
#include "const.h"
#include "tags.h"
#include "types.h"
#include "mem.i"

extern struct instr_type codestore[];

public address memory[MAXMEMORY];

public address registers[MAXREGISTER];


  /* offsets into the choice point frame on the stack */
  /* B points to the top of a choice point frame. The registers are at the top
   H points to the first empty space in the heap. 
   HB follows it.
   TR points to the first empty space in the trail.
   E points to the lowest element in the current environment
   B points to the topmost element of the current backtrack point

   It looks likes this (but the order does not matter)

        |----|
   B -> | L  |
        |----|
        | CP |
        |----|
        | HB |
        |----|
        | E  |
        |----|
        | TR |
        |----|
        | B  |
        |----|
        | An |
        | .  |
        | .  |
        | .  |
        | A0 |
        |----|
*/

address HB, H, E, TR, B;
extern address S;
extern char RWmode;

/* P points to the current instruction being executed in the code store
   CP is the continuation pointer after successful completion of the 
   calling proc.
   An environment looks like this:

	|----|
	| Yn |
	| .  |
	| .  |
	| Y0 |
	|----|
	| CP |
	|----|
   E -> | CE |
	|----|

   The permanent vbls must be above CP and CE

   Note that location 0 in the code store is reserved for NO-OP, and is
   used to signal failure, and that 1 is reserved for SUCCESS to stop
   the machine successfully
*/

public address P, CP;

public void init_memory()
{
	HB = 1;        /* a nasty: 0 is reserved for FAIL return from unify! */
	H = 1;
	E = LOWSTACK - 1;
	TR = LOWTRAIL;
	CP =  1;	/* this is address of 'succeed' in code store,
			   as set by 'loadstore'  */
	B = LOWSTACK;   /* a choice point pointing outside of the stack
	                               so that failure can be discovered */ 

}

extern int proc_count;
extern struct proc_table_type proc_table[];

public int environment_size(a)
address a;
{
  if (a <= 1)
    return(0);
  else
    return(codestore[a - 1].data.c.env_size + 2); /* + 2 for CP, CE */
}

public void dump_mem()
{
  address i, tos;

  printf("heap:\n");
  for (i=LOWHEAP + 1; i < H; i++)
    printf("%7o ", i);
  printf("\n");
  for (i=LOWHEAP+1; i < H; i++)
    printf("%7o ", *(memory+i));
  printf("\n");

  printf("local stack:\n");
  if (E < B)
    tos = B + 6 + MAXREGISTER;
  else
    tos = E + 2 + environment_size(CP);
  for (i=LOWSTACK; i <= tos; i++)
    printf("%5o ", i);
  printf("\n");
  for (i=LOWSTACK; i <= tos; i++)
    printf("%5o ", WITHOUT_TAG(*(memory+i)));
  printf("\n");

  printf("trail:\n");
  for (i = LOWTRAIL; i < TR; i++)
    printf("%5o ", i);
  printf("\n");
  for (i=LOWTRAIL; i < TR; i++)
    printf("%5o ", *(memory+i));
  printf("\n");

  for (i=0; i < MAXREGISTER; i++)
    printf("A%d: %o ", i, WITHOUT_TAG(registers[i]));
  printf("\n");

  printf("H: %o HB: %o E: %o TR: %o B: %o P: %o CP: %o S: %o RW %c:\n",
    H, HB, E, TR, B, P, CP, S, RWmode);
}



