/* wam.i -- declarations file for module wam */

#ifndef _WAM_H
#define _WAM_H

#include <stdlib.h>
#include <stdio.h>

#include "const.h"
#include "tags.h"
#include "types.h"

void retry_me_else_instr(code_addr L);
void deallocate_instr();
void call_instr(code_addr proc_addr, int n);
void deallocate_instr();
void allocate_instr();
void proceed_instr();
void execute_instr(code_addr proc_addr);
void retry_me_else_instr(code_addr L);
void trust_me_else_instr();
void try_me_else_instr(code_addr L);
void retry_instr(code_addr L);
void trust_instr(code_addr L);
void try_instr(code_addr L);
void fail_instr();
void put_const_instr(atom_addr C, register_type R);
void get_const_instr(atom_addr C, register_type R);
void get_perm_variable_instr(int Y, register_type R);
void get_temp_variable_instr(register_type V, register_type R);
void get_perm_value_instr(int Y, register_type R);
void get_temp_value_instr(register_type V, register_type R);
void put_perm_variable_instr(int Y, register_type R);
void put_temp_variable_instr(register_type V, register_type R);
void put_perm_value_instr(int Y, register_type R);
void put_temp_value_instr(register_type V, register_type R);
void put_unsafe_value_instr(int Y, register_type R);
void get_nil_instr(register_type R);
void put_nil_instr(register_type R);
void get_structure_instr(atom_addr F, register_type R);
void put_structure_instr(atom_addr F, register_type R);
void put_list_instr(register_type R);
void get_list_instr(register_type R);
void unify_void_instr(int n);
void unify_temp_variable_instr(register_type R);
void unify_perm_variable_instr(int Y);
void unify_temp_local_value_instr(register_type R);
void unify_perm_local_value_instr(int Y);
void unify_temp_value_instr(register_type R);
void unify_perm_value_instr(int Y);
void unify_const_instr(atom_addr C);
void unify_nil_instr();
void switch_on_type_instr(code_addr Lv, code_addr Lc, code_addr Ll, code_addr Ls);
void switch_on_constant_instr(struct hash_entry tbl[]);
void built_in_instr(int N);

/* wam.i ends here */

#endif
