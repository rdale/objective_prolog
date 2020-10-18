
/* WAM emulator
	module wam.c
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

/* WAM instructions */

#include<stdio.h>

#include "mem.h"
#include "main.h"
#include "unify.h"
#include "wam.h"

address S;
char RWmode;

extern address B, E, H, HB, TR;
extern int P, CP;
extern address registers[];
extern address memory[];



extern atom_name atom_table[];
extern address deref();

static void write_instr(address A)
{
  address val;

  val = deref(A);
  if (TAG_OF(val) == CONST_TAG)	
    printf("%s", atom_table[WITHOUT_TAG(val)]);
  else
  if (TAG_OF(val) == VBL_TAG)
    printf("_%d", WITHOUT_TAG(val));
  else
  if (TAG_OF(val) == LIST_TAG)
  { printf("(");
    write_instr(*(memory + WITHOUT_TAG(val) + 1));
    printf(").");
    write_instr(*(memory + WITHOUT_TAG(val) + 2));
  }
  else
  if (TAG_OF(val) == STRUCT_TAG)
  { int i, arg;
    atom_name name;
    
    sscanf(atom_table[WITHOUT_TAG(*(memory+WITHOUT_TAG(val)+1))], "%[^/]/%d", name, &arg);
    printf("%s(", name);
    write_instr(*(memory + WITHOUT_TAG(val) + 2));
    for (i = 2; i <= arg; i++)
    { printf(", ");
      write_instr(*(memory + WITHOUT_TAG(val) + 1 + i));
    };
    printf(")");
  }
  else
  if (TAG_OF(val) == NIL_TAG)
    printf("[]");
  else
    printf("write: unimplemented type\n");
}

void deallocate_instr()
{
  CP = *(memory + E + CP_offset);
  E = *(memory + E + CE_offset);
  P++;
}

void allocate_instr()
{
  address CE;

  CE = E;
  if (E < B)
    E = B + 1;
  else
    E += environment_size(CP);  /* E points to BASE of environment */
  if (E + 2 > HIGHSTACK)
    fatal("local stack overflow");
  *(memory + E + CP_offset) = CP;
  *(memory + E + CE_offset) = CE;
  P++;
}


void call_instr(code_addr proc_addr, int n)
{
  CP = P + 1;
  P = proc_addr + 1;  /* one more than proc start */
}

void proceed_instr()
{
  P = CP;
}
	
void execute_instr(proc_addr)
code_addr proc_addr;
{
  P = proc_addr + 1;
}


void retry_me_else_instr(L)
code_addr L;
{
  *(memory + B) = L;	/* L on top of choice point */
  P++;
}

void trust_me_else_instr()
{
  HB = *(memory + B - 2);
  B = *(memory + B - 5);
  P++;
}

void try_me_else_instr(L)
code_addr L;
{
  address i, *nextfree;
  if (E < B)
    nextfree = memory + B + 1;
  else
    nextfree = memory + E + environment_size(CP);
  if (nextfree + MAXREGISTER + 6 > memory + HIGHSTACK)
    fatal("local stack overrflow");
  for (i = 0;  i < MAXREGISTER; i++)
    *nextfree++ = registers[i]; 
  *nextfree++ = B;
  *nextfree++ = TR;
  *nextfree++ = E;
  *nextfree++ = HB = H;
  *nextfree++ = CP;
  *nextfree   = L;
  B = nextfree - memory; /* B points to TOP of choice point */
  P++;
}


void retry_instr(L)
code_addr L;
{
  *(memory + B) = P + 1;	/* L on top of choice point */
  P = L;
}

void trust_instr(L)
code_addr L;
{
  HB = *(memory + B - 2);
  B = *(memory + B - 5);
  P = L;
}

void try_instr(L)
code_addr L;
{
  address i, *nextfree;
  if (E < B)
    nextfree = memory + B + 1;
  else
    nextfree = memory + E + environment_size(CP);
  if (nextfree + MAXREGISTER + 6 > memory + HIGHSTACK)
    fatal("local stack overflow");
  for (i = 0;  i < MAXREGISTER; i++)
    *nextfree++ = registers[i]; 
  *nextfree++ = B;
  *nextfree++ = TR;
  *nextfree++ = E;
  *nextfree++ = HB = H;
  *nextfree++ = CP;
  *nextfree   = P + 1;
  B = nextfree - memory; /* B points to TOP of choice point */
  P = L;
}

void fail_instr()
{
  address old_trailptr, trail_entry, *top;
  int i;
  
  if (B == LOWSTACK)
  {
    printf("FAILED\n");
    exit(0);
  };
  top = memory + B;
  P = *top--;
  CP = *top--;
  H = *top--;
  E = *top--;
  old_trailptr = *top;
  for (i = TR - 1;  i >= old_trailptr; i--)
  {     trail_entry = *(memory + i);
        *(memory + trail_entry) = ADD_TAG(trail_entry, VBL_TAG);
  }
  TR = *top--;
  for (i =  MAXREGISTER - 1; i >= 0; i--)
    registers[i] = *(--top);
}

void put_const_instr(C, R)
atom_addr C;
register_type R;
{
  registers[R] = C;
  P++;
}

void get_const_instr(C, R)
atom_addr C;
register_type R;
{
  address val;

  val = deref(registers[R]);
  if (isconstant(val))
  {
    if (C == val)
      P++;
    else
      P = FAIL_PROC;
  }
  else
  {
    if (unbound(val))
    {
      bind(val, C);
      P++;
    }
    else P = FAIL_PROC;
  };
}

void get_perm_variable_instr(Y, R)
int Y;
register_type R;
{
  *(memory + E + Y + 1) = registers[R];   /* m[E] = CE, m[E+1] = CP, so this is actual
                              vbl location in the env */
  P++;
}

void get_temp_variable_instr(V, R)
register_type V;
register_type R;
{
  P++;
  registers[V] = registers[R];
}

void get_perm_value_instr(Y, R)
int Y;
register_type R;
{
  address val, U;

  val = deref(registers[R]);
  U = unify(*(memory + Y +1), val);
  if (U == FAIL)
    P = FAIL_PROC;
  else P++;
}

void get_temp_value_instr(V, R)
register_type V, R;
{
  address val1, val2, U;

  val1 = deref(registers[V]);
  val2 = deref(registers[R]);
  U = unify(val1, val2);
  if (U == FAIL)
    P = FAIL_PROC;
  else
  {
    P++;
    registers[R] = U;
  }
}

void put_perm_variable_instr(Y, R)
int Y;
register_type R;
{
  address A;

  P++;
  A = E + Y + 1;
     /* m[E] = CE, m[E+1] = CP, so this is actual
                              vbl location in the env */
  registers[R] =  ADD_TAG(A, REF_TAG);
  *(memory + A) = ADD_TAG(A, VBL_TAG);
}

void put_temp_variable_instr(V, R)
register_type V, R;
{
  /* create a new vbl cell on the stack and point everything to it */
  P++;
  *(memory + H) = ADD_TAG(H, VBL_TAG);
  registers[V] = registers[R] = ADD_TAG(H, REF_TAG);
  if (H++ > HIGHHEAP)
    fatal("heap overflow");
}

void put_perm_value_instr(Y, R)
int Y;
register_type R;
{
  P++;
  registers[R] = *(memory + Y + E +1);
}

void put_temp_value_instr(V, R)
register_type V, R;
{
  P++;
  registers[R] = registers[V];
}

void put_unsafe_value_instr(Y, R)
int Y;
register_type R;
{
  address val;

  P++;
  /* first deref the vbl */
  val = deref( *(memory + E + Y + 1));
  registers[R] = val;
  if (unbound(val))
  {
    *(memory + H) = ADD_TAG(H, VBL_TAG);
    *(memory + WITHOUT_TAG(val)) = ADD_TAG(H, REF_TAG);
    trail_instr(val);
    registers[R] = ADD_TAG(H, REF_TAG);
    if (H++ > HIGHHEAP)
      fatal("heap overflow");
  };
}

void get_nil_instr(R)
register_type R;
{ address val;

  val = deref(registers[R]);
  if (TAG_OF(val) == NIL_TAG)
    P++;
  else
  if (TAG_OF(val) == VBL_TAG)
  {
    *(memory + WITHOUT_TAG(val)) = ADD_TAG(0, NIL_TAG);
    trail_instr(val);
    P++;
  }
  else P = FAIL_PROC;
}

void put_nil_instr(R)
register_type R;
{
  registers[R] = ADD_TAG(0, NIL_TAG);
  P++;
}

void get_structure_instr(F, R)
atom_addr F;
register_type R;
{
  address val;

  val = deref(registers[R]);
  if (TAG_OF(val) == STRUCT_TAG)
  {
    if (F == *(memory+WITHOUT_TAG(val)+1))
    {
      S = WITHOUT_TAG(val) + 2;
      RWmode = 'r';
      P++;
    }
    else
      P = FAIL_PROC;
  }
  else
  {
    if (unbound(val))
    { /* structures take up two words - one for tag + selfpointer,
                                        one for functor pointer */
      *(memory + WITHOUT_TAG(val))  = *(memory + H) = ADD_TAG(H, STRUCT_TAG);
      *(memory + ++H) = F;
      trail_instr(val);
      RWmode = 'w';
      if (H++ > HIGHHEAP)
        fatal("heap overflow");
      P++;
    }
    else P = FAIL_PROC;
  }
}

void put_structure_instr(F, R)
atom_addr F;
register_type R;
{
    registers[R] = *(memory + H) = ADD_TAG(H, STRUCT_TAG); 
    *(memory + ++H) = F;
    RWmode = 'w';
    if (H++ > HIGHHEAP)
      fatal("heap overflow");
    P++;
}

void put_list_instr(R)
register_type R;
{
  registers[R] = *(memory + H) = ADD_TAG(H, LIST_TAG);
  RWmode = 'w';
  P++;
  if (H++ > HIGHHEAP)
    fatal("heap overflow");
}

void get_list_instr(R)
register_type R;
{ address val;

  val = deref(registers[R]);
  if (TAG_OF(val) == LIST_TAG)
  {
    S = WITHOUT_TAG(val) + 1;
    RWmode = 'r';
    P++;
  }
  else
    if (TAG_OF(val) == VBL_TAG)
    {
      *(memory + H) = *(memory + WITHOUT_TAG(val)) =
				ADD_TAG(H, LIST_TAG);
      if (H++ > HIGHHEAP)
        fatal("heap overflow");
      trail_instr(val);
      RWmode = 'w';
      P++;
    }
    else P = FAIL_PROC;
}

void unify_void_instr(n)
int n;
{
  if (RWmode == 'r')
    S += n;
  else
  { int i;
    
    if (H + n > HIGHHEAP)
      fatal("heap overflow");
    for (i = 0; i < n; i++)
    { *(memory + H) = ADD_TAG(H, VBL_TAG);
      H++;
    }
  };
  P++;
}

void unify_temp_variable_instr(R)
register_type R;
{
  if (RWmode == 'r')
    registers[R] = *(memory + S++);
  else
  {
    *(memory + H) = ADD_TAG(H, VBL_TAG);
    registers[R] = ADD_TAG(H, REF_TAG);
    if (H++ > HIGHHEAP)
      fatal("heap overflow");
  };
  P++;
}

void unify_perm_variable_instr(Y)
int Y;
{
  if (RWmode == 'r')
    *(memory + Y + E +1) = *(memory + S++);
  else
  {
    *(memory + H) = ADD_TAG(H, VBL_TAG);
    *(memory + Y + E + 1) = ADD_TAG(H, REF_TAG);
    trail_instr(Y+E+1);
    if (H++ > HIGHHEAP)
      fatal("heap overflow");
  };
  P++;
}

void unify_temp_local_value_instr(R)
register_type R;
{
  if (RWmode == 'r')
  { address U;
  
    if ((U = unify(registers[R], *(memory+S))) == FAIL)
      P = FAIL_PROC;
    else
    {
      registers[R] = U;
      P++;
      S++;
    }
  }
  else
  { address val;

    val = deref(registers[R]);
    if ((TAG_OF(val) ==VBL_TAG) && (WITHOUT_TAG(val) >= LOWSTACK) &&
		(WITHOUT_TAG(val) <= HIGHSTACK))
    {
      registers[R] = *(memory + H) = ADD_TAG(H, VBL_TAG);
      *(memory + WITHOUT_TAG(val)) = ADD_TAG(H, REF_TAG);
      if (H++ > HIGHHEAP)
        fatal("heap overflow");
      trail_instr(val);
    }
    else
    {
      *(memory + H++) = val;
      if (H > HIGHHEAP)
        fatal("heap overflow");
    }
    P++;
  }
}

void unify_perm_local_value_instr(Y)
int Y;
{
  if (RWmode == 'r')
  { address U;
  
    if ((U = unify(*(memory + Y +1), *(memory+S))) == FAIL)
      P = FAIL_PROC;
    else
    {
      P++;
      S++;
    }
  }
  else
  { address val;

    val = deref(*(memory + Y + 1));
    if ((TAG_OF(val) ==VBL_TAG) && (WITHOUT_TAG(val) >= LOWSTACK) &&
		(WITHOUT_TAG(val) <= HIGHSTACK))
    {
      *(memory + H) = ADD_TAG(H, VBL_TAG);
      *(memory + WITHOUT_TAG(val)) = ADD_TAG(H, REF_TAG);
      if (H++ > HIGHHEAP)
        fatal("heap overflow");
      trail_instr(val);
    }
    else
    {
      *(memory + H++) = val;
      if (H > HIGHHEAP)
        fatal("heap overflow");
    }
    P++;
  }
}

void unify_temp_value_instr(R)
register_type R;
{
  if (RWmode == 'r')
  { address U;
  
    if ((U = unify(registers[R], *(memory+S))) == FAIL)
      P = FAIL_PROC;
    else
    {
      registers[R] = U;
      P++;
      S++;
    }
  }
  else
  {
    if (TAG_OF(registers[R]) == VBL_TAG)
      *(memory + H++) = ADD_TAG(registers[R], REF_TAG);
    else
      *(memory + H++) = registers[R];
    P++;
    if (H > HIGHHEAP)
      fatal("heap overflow");
  }
}

void unify_perm_value_instr(Y)
int Y;
{
  if (RWmode == 'r')
  { address U;
  
    if ((U = unify(*(memory + Y + 1), *(memory+S))) == FAIL)
      P = FAIL_PROC;
    else
    {
      P++;
      S++;
    }
  }
  else
  {
    *(memory + H++) = *(memory + E + Y + 1);
    if (H > HIGHHEAP)
      fatal("heap overflow");
    P++;
  }
}

void unify_const_instr(C)
atom_addr C;
{
  if (RWmode == 'r')
  { address val;

    val = deref(*(memory + S));
    S++;
    if (unbound(val))
    { 
      bind(val, C);
      trail_instr(val);
      P++;
    }
    else
      if (val == C)
        P++;
      else P = FAIL_PROC;
  }
  else
  {
    *(memory + H++) = C;
    if (H > HIGHHEAP)
      fatal("heap overflow");
    P++;
  }
}

void unify_nil_instr()
{
  if (RWmode == 'r')
  { address val;

    val = deref(*(memory+S));
    S++;
    if (unbound(val))
    {
      *(memory + WITHOUT_TAG(val)) = ADD_TAG(0, NIL_TAG); 
      trail_instr(val);
      P++;
    }
    else
      if (TAG_OF(val) == NIL_TAG)
        P++;
      else P = FAIL_PROC;
  }
  else
  {
    *(memory + H++) = ADD_TAG(0, NIL_TAG);
    if (H > HIGHHEAP)
      fatal("heap overflow");
    P++;
  }
}


void switch_on_type_instr(Lv, Lc, Ll, Ls)
code_addr Lv, Lc, Ll, Ls;
{
  address val;

  switch ( TAG_OF(deref(registers[0])) )
  {
    case VBL_TAG :	P = Lv;
			break;
    case NIL_TAG :
    case CONST_TAG :	P = Lc;
			break;
    case LIST_TAG :	P = Ll;
			break;
    case STRUCT_TAG :	P = Ls;
			break;
    default :		fatal("unknown type in switch_on_type");
  }
}


void switch_on_constant_instr(struct hash_entry tbl[])
{
  int i;
  address val;

  i=0;
  val = deref(registers[0]);
  while (i<HASH_MAX && tbl[i].at != 0 && tbl[i].at != val)
    i++;
  if (i == HASH_MAX || tbl[i].at == 0)
    P = FAIL_PROC;
  else
    P = tbl[i].br;
}


void built_in_instr(int N)
{
  switch (N)
  {
    case WRITE:	write_instr(registers[0]);
		break;
    case NL:	putchar('\n');
		break;
    default:	fatal("unimplemented built-in");
  };
  P++;
}
                                      
