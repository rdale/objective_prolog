
/* WAM emulator
	module types.h
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not be used for any commercial purposes.
*/

#ifndef _TYPES_H
#define _TYPES_H

#include "const.h"

typedef unsigned address;	/* address of element in memory */
typedef int	optype;


typedef int atom_addr;	/* index into atom table */
typedef int code_addr;	/* index into code store */
typedef int register_type; /* index into register file A0, A1, ... */


typedef char atom_name[MAXSTRING];

/* the following types are used to store WAM instructions, using record
   structures. This wastes space but is simple. A more economical version
   would store just the bytes or integers required
*/

struct call_type {	/* for call P,N */
	code_addr	p_addr;
	int		env_size;
	};

struct reg_vbl {	/* for get_temp_vbl X1,A0, get_perm_vbl Y1,A0 etc */
	int		vbl_no;
	register_type	register_no;
	};
	
struct reg_const {	/* for put_const foo,A0 etc */
	atom_addr	c_number;
	register_type	register_no;
	};

struct term_sw_addr {	/* for switch_on_term */
	code_addr	Lv, Lc, Ll, Ls;
	};

struct hash_entry {	/* for switch_on_const */
	atom_addr	at;
	code_addr	br;
	};

struct instr_type {	/* the variant record structure for instructions */
	optype	opcode;
	union {
		int			void_no;
		struct call_type	c;
		code_addr		c_addr;
		register_type		register_no;
		struct reg_vbl		r_v;
		struct reg_const 	r_c;
		struct term_sw_addr	s;
		atom_name		proc_name;
	        int			built_in_no;
		struct hash_entry	hash_tbl[4];
	      }	data;
	};

/* mapping from tags to fields:


	    unify_nil
            proceed,
            allocate,
            deallocate			--> null
            
	    call,
            execute,
            
            get_perm_variable,
            get_temp_variable,
            get_perm_value,
            get_temp_value,
	    put_perm_variable,
            put_temp_variable,
            put_perm_value,
            put_temp_value,
            put_unsafe_value 		--> reg_vbl

	    built_in			--> built_in_no

	    write,
            get_list,
            get_nil,
            put_list,
            put_nil			--> register_type

	    unify_constant,
            put_const,
            put_structure,
            get_const,
            get_structure		--> reg_const
            	
	    unify_void			--> void_no

            unify_perm_variable,
            unify_temp_variable,
            unify_perm_value,
            unify_temp_value,
            unify_perm_value,
            unify_temp_value		--> register_type
           
	    try_me_else,
            retry_me_else,
            trust_me_else_fail,
            try	,
            retry,
            trust			--> code_addr

            switch_on_term		--> term_switch_addr

            switch_on_constant,
            switch_on_structure		--> unassigned (not implemented)

	    succeed
            fail,
            trail			--> null (not instructions)

*/

/* These types are used in loading instructions referencing procedures not
   yet defined, which will require addresses to be patched later 
*/
struct unres_proc	{
	code_addr	unres_addr;
	struct
	unres_proc	*next_unres;
	};

struct proc_table_type {
	atom_name	p_name;
	code_addr	p_addr;
	struct
	unres_proc	*p_unres;
	};

#endif
