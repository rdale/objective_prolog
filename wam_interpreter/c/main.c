
/* WAM emulator
	module main.c
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not be used for any commercial purposes.
*/

#include <stdio.h>
#include <sys/types.h>


#include "portable.h"
#include "const.h"
#include "tags.h"
#include "types.h"
#include "main.i"

/* the following flags control execution profiling.
   BENCHMARKING runs the program 20 times
   MAX_MEM reports on maximimum stack sizes
   TRACE gives an instruction trace
   DUMP_MEM dumps the stacks and registers before each instruction
*/

/* 
#define BENCHMARKING 
#define MAX_MEM 1
#define TRACE 1
#define DUMP_MEM 1
*/

#ifdef MAX_MEM
address max_heap, max_trail, max_local;
#endif

extern address E, H, P, CP, TR, B;
extern struct instr_type codestore[];
extern address fail_proc_addr;
extern address registers[];
extern char *opstring[];

public void fatal(s)
char *s;
{
  fprintf(stderr, "Fatal error - %s\n Execution halted\n", s);
  exit(1);
}

/* WAM control loop, which calls above procs */


private int inf_count = 0;

private void execute_prog()
{
  struct instr_type instr;
  /* all WAM programs executed by this have an entry point of `main/0'
     and so the code must define `main/0'. It must be the first code line */

  init_memory();
  /* commence execution at first proc in file, which starts at 3 */
  P = 3;
  instr = codestore[P];

  for(;;)
  {
#ifdef TRACE 
	printf("About to execute instr no: %d", P);  
 	printf("\t(%s)\n", opstring[codestore[P].opcode]);  
#endif
#ifdef DUMP_MEM
	dump_mem();
#endif
#ifdef MAX_MEM
	if (H > max_heap) max_heap = H;
	if (TR > max_trail) max_trail = TR;
	if (B > max_local) max_local = B;
	if (E+environment_size(CP) > max_local)
		max_local = E + environment_size(CP);
#endif
    switch (instr.opcode)
    {
      case call              : /* call_instr(instr.data.c.p_addr, instr.data.c.env_size); */
				CP = P + 1; P = instr.data.c.p_addr; 
			       inf_count++; break;
      case proceed           : /* proceed_instr(); */
				P = CP; 
			        break;
      case execute           : /* execute_instr(instr.data.c.p_addr); */
				P = instr.data.c.p_addr; 
			       inf_count++; break;
      case retry_me_else     : retry_me_else_instr(instr.data.c_addr); break;
      case trust_me_else_fail: trust_me_else_instr(); break;
      case try_me_else       : try_me_else_instr(instr.data.c_addr); break;
      case fail              : fail_instr(); break;
      case allocate          : allocate_instr(); break;
      case deallocate        : deallocate_instr(); break;
      case get_const         : get_const_instr(instr.data.r_c.c_number, 
					instr.data.r_c.register_no); break;
      case put_const         : put_const_instr(instr.data.r_c.c_number, 
					instr.data.r_c.register_no); break;
      case get_structure     : get_structure_instr(instr.data.r_c.c_number,
					instr.data.r_c.register_no); break;
      case put_structure     : put_structure_instr(instr.data.r_c.c_number,
					instr.data.r_c.register_no); break;
      case get_perm_variable : get_perm_variable_instr(instr.data.r_v.vbl_no,
                                              instr.data.r_v.register_no); break;
      case get_temp_variable : get_temp_variable_instr(instr.data.r_v.vbl_no,
                                              instr.data.r_v.register_no); break;
      case get_perm_value    : get_perm_value_instr(instr.data.r_v.vbl_no,
                                              instr.data.r_v.register_no); break;
      case get_temp_value    : get_temp_value_instr(instr.data.r_v.vbl_no,
                                              instr.data.r_v.register_no); break;
      case put_perm_variable : put_perm_variable_instr(instr.data.r_v.vbl_no,
                                              instr.data.r_v.register_no); break;
      case put_temp_variable : put_temp_variable_instr(instr.data.r_v.vbl_no,
                                              instr.data.r_v.register_no); break;
      case put_perm_value    : put_perm_value_instr(instr.data.r_v.vbl_no,
                                              instr.data.r_v.register_no); break;
      case put_temp_value    : put_temp_value_instr(instr.data.r_v.vbl_no,
                                              instr.data.r_v.register_no); break;
      case put_unsafe_value  : put_unsafe_value_instr(instr.data.r_v.vbl_no,
                                             instr.data.r_v.register_no); break;
      case unify_nil         : unify_nil_instr(); break;
      case unify_constant    : unify_const_instr(instr.data.r_c.c_number); break;
      case unify_perm_variable: unify_perm_variable_instr(instr.data.register_no);break;
      case unify_temp_variable: unify_temp_variable_instr(instr.data.register_no);break;
      case unify_perm_value: unify_perm_value_instr(instr.data.register_no);break;
      case unify_temp_value: unify_temp_value_instr(instr.data.register_no);break;
      case unify_perm_local_value: unify_perm_local_value_instr(instr.data.register_no);break;
      case unify_temp_local_value: unify_temp_local_value_instr(instr.data.register_no);break;
      case unify_void	     : unify_void_instr(instr.data.void_no); break;
      case built_in	     : built_in_instr(instr.data.built_in_no); break;
      case succeed           : return;    /* terminate proof */
      case get_nil           : get_nil_instr(instr.data.register_no); break;
      case get_list          : get_list_instr(instr.data.register_no); break;
      case put_nil           : put_nil_instr(instr.data.register_no); break;
      case put_list          : put_list_instr(instr.data.register_no); break;
      case switch_on_type    : switch_on_type_instr( instr.data.s.Lv,
					instr.data.s.Lc,
					instr.data.s.Ll,
					instr.data.s.Ls);
			       break;  
      case switch_on_constant :
			       switch_on_constant_instr(instr.data.hash_tbl);
			       break;
      default		     : fatal("unimplemented instruction");
    };
    instr = codestore[P];
  };
}

  
public int main(argc, argv)
int argc;
char *argv[];
{ 
  loadstore();

#ifdef BENCHMARKING
  { int i;
  for (i = 0; i < 20; i++) {
#endif

  execute_prog();

#ifdef BENCHMARKING
  }
  }
#endif

#ifdef MAX_MEM
  printf("max heap: %d\n", max_heap-LOWHEAP);
  printf("max local: %d\n", max_local-LOWSTACK);
  printf("max trail: %d\n", max_trail-LOWTRAIL);
#endif
  printf("Execution terminated succesfully\n");

  exit(0);
}
