

/* WAM emulator
	module const.h
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not be used for any commercial purposes.
*/

#ifndef _CONST_H
#define _CONST_H

#define FAIL (address) 0

#define MAXSTRING 20	/* max length of an atom name */
	
#define MAXREGISTER 16	/* max number of registers A0...A(maxreg-1) */


  /* offsets into the environment frame on the stack */
#define  CE_offset  0
#define  CP_offset  1


#define MAXMEMORY  07777     /* must be <= UNTAG_MASK to fit */

/* split memory into heap, stack and trail.
   They could split into any sized portions
*/
#define LOWHEAP   0
#define HIGHHEAP  (MAXMEMORY / 3 - 1) 
#define LOWSTACK  (MAXMEMORY / 3) 
#define HIGHSTACK (2 * MAXMEMORY / 3 - 1)
#define LOWTRAIL  (2 * MAXMEMORY / 3) 
#define HIGHTRAIL (MAXMEMORY - 1)  

#define FAIL_PROC  0    /* fail address in code from NO_PROC or from execution */
#define SUCC_PROC  1    /* success address in code of a proof */

#define MAX_BUILTIN 2 	/* number of built-in names below */

#define WRITE	0	/* these are the built-in function labels */
#define NL 	1

#define MAXOP 44	/* max number of ops below */

/* The following are needed because some 'C's have no enum, and anyway
   allows for replacement of symbolic names in input file by these integer
*/

#define allocate		0
#define deallocate		1
#define call			2
#define execute			3
#define proceed			4
#define put_perm_variable	5
#define put_temp_variable	6
#define put_perm_value		7
#define put_temp_value		8
#define put_unsafe_value	9
#define put_const		10
#define put_nil			11
#define put_structure		12
#define put_list		13
#define get_perm_variable	14
#define get_temp_variable	15
#define get_perm_value		16
#define get_temp_value		17
#define get_const		18
#define get_nil			19
#define get_structure		20
#define get_list		21
#define unify_void		22
#define unify_perm_variable	23
#define unify_temp_variable	24
#define unify_perm_value	25
#define unify_temp_value	26
#define unify_perm_local_value	27
#define unify_temp_local_value	28
#define unify_constant		29
#define unify_nil		30
#define try_me_else		31
#define retry_me_else		32
#define trust_me_else_fail	33
#define try			34
#define retry			35
#define trust			36
#define switch_on_type		37
#define switch_on_constant	38
#define switch_on_structure	39
#define built_in		40
#define fail			41
#define trail			42
#define succeed			43
#define newproc			44

#define HASH_MAX	4

#endif
