
/* WAM emulator
	module load.c
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not be used for any commercial purposes.
*/

#include <stdio.h>
#include <string.h>

#include "const.h"
#include "types.h"
#include "tags.h"
#include "load.h"
#include "main.h"

char *built_ins [] = {
		"write",
		"nl"
		};

/* mapping from opcodes to instruction names, required for reading
   instructions. opstring[allocate] = "allocate" etc.
*/
char *opstring [] = {
 		"allocate",
 		"deallocate",
 		"call",
 		"execute",
 		"proceed",
 		"put_variable",
 		"put_variable",
 		"put_value",
 		"put_value",
 		"put_unsafe_value",
 		"put_const",
 		"put_nil",
 		"put_structure",
 		"put_list",
 		"get_variable",
 		"get_variable",
 		"get_value",
 		"get_value",
 		"get_const",
 		"get_nil",
 		"get_structure",
 		"get_list",
 		"unify_void",
 		"unify_variable",
 		"unify_variable",
 		"unify_value",
 		"unify_value",
 		"unify_local_value",
 		"unify_local_value",
 		"unify_constant",
		"unify_nil",
 		"try_me_else",
 		"retry_me_else",
 		"trust_me_else",
 		"try",
 		"retry",
 		"trust",
 		"switch_on_type",
 		"switch_on_constant",
 		"switch_on_structure",
		"built_in",
 		"fail",
 		"trail",
 		"newproc"
	};

#define MAXCODE 256	/* max size of code store */

struct instr_type codestore[MAXCODE];

/* the first location in code store is reserved for instruction FAIL,
   the next for instruction SUCCEED. codetop starts at the next free
*/
static int codetop = 2;

#define MAXPROC 128	/* max no. of preocedures that can be defined */

struct proc_table_type proc_table[MAXPROC];

int proc_count = 0;

#define MAXATOMS 256

atom_name atom_table[MAXATOMS];

static int atom_top = 0;

static optype findop(char *opname);
static void read_instruction(char *opname, struct instr_type *instr);
static void load_instr(struct instr_type instr);
static void add_call(char *n);
static int atom_tbl_addr();
static int atom_tbl_addr(atom_name name);
static void skip_comments();

void loadstore()
{
	char opname[MAXSTRING];
	struct instr_type instr;

	skip_comments();
	codestore[0].opcode = fail;
	codestore[1].opcode = succeed;
	while(scanf("%s", opname) != EOF)
	{
		read_instruction(opname, &instr);
		printf("%d: %s\n", (codetop-1), opname);
	};
	fix_unres_addr();
	printf("loaded store\n");
#ifdef DUMP_MEM
	{ int i;
	  printf("Atom store contains:\n");
 	  for (i=0; i < atom_top; i++)
   	  printf("%d: %s\n", i, atom_table[i]);
	}
#endif
}

static optype findop(opname)
char *opname;
{
	optype op;

	for (op = 0; op < MAXOP; op++)
		if (strcmp(opstring[op], opname) == 0)
			return(op);
	/* couldn't find it in known instructions so .. */
	return(newproc);
}

static void read_instruction(opname, instr)
char *opname;
struct instr_type *instr;
{
	optype op;

	op = findop(opname);
	instr->opcode = op;
	switch (op)
	{
		case call:	/* call Proc_addr,N */
				{ atom_name name;
				  scanf(" %[^,] , %d", name,
						      &(instr->data.c.env_size));
				  instr->data.c.p_addr = FAIL_PROC; /* default to fail */
				  load_instr(*instr);
				  add_call(name);
				  break;
				}
		case unify_nil:
		case proceed:
		case fail:
		case allocate:
		case deallocate:
				load_instr(*instr); break;

		case execute:	/* execute Proc_addr */
				{ atom_name name;

                                  scanf(" %s", name);
				  instr->data.c.p_addr = FAIL_PROC;
				  load_instr(*instr);
				  add_call(name);
				  break;
				}

		case trust_me_else_fail:
		case trust:		/* trust_me_else fail */
				scanf(" fail");
				instr->data.c_addr = FAIL_PROC;
				load_instr(*instr);
				break;
 	
		case try_me_else:	/* try_me_else L  .. integer(L) */
		case retry_me_else:
		case try:
		case retry:
				{ int i;

				  scanf(" %d", &i);
				  instr->data.c_addr = i + codetop;
				}
				load_instr(*instr);
				break;
		case newproc:	/* Proc : */
				if (proc_count == MAXPROC)
					fatal("Too many procedures defined");
				scanf(" %*[:]");  /* discard ':' */
				{	int i;
					strcpy(instr->data.proc_name, opname);
					load_instr(*instr);
					for ( i = 0; i < proc_count; i++)
						if (strcmp(proc_table[i].p_name,
							opname) == 0)
						{	proc_table[i].p_addr =
								codetop;
							return;
						}
					strcpy(proc_table[proc_count].p_name,
							opname);
					proc_table[proc_count].p_addr = codetop;
					/* addres stored is start of first
					   instr in proc */
					proc_table[proc_count++].p_unres = NULL;
				}
				break;
		case get_const:
		case put_const: /* get_const Const, An */
				{ atom_name name;

				  scanf(" %[^ ,] , A %d", name,
						       &(instr->data.r_c.register_no));
				  instr->data.r_c.c_number =
						ADD_TAG(atom_tbl_addr(name),
							CONST_TAG);
				  load_instr(*instr);
				  break;
				};
		
		case get_structure:
		case put_structure:	/* get_struct F/N, An */
				{ atom_name name;

				  scanf(" %[^ ,] , A %d", name,
						       &(instr->data.r_c.register_no));
				  instr->data.r_c.c_number =
						ADD_TAG(atom_tbl_addr(name),
							STRUCT_TAG);
				  load_instr(*instr);
				  break;
				}
		
		case built_in:  {  atom_name name;  int i;

				   scanf(" %s", name);
				   for (i = 0; i < MAX_BUILTIN; i++)
				     if (strcmp(built_ins[i], name) == 0)
				     {  instr->data.built_in_no = i;
				        load_instr(*instr);
					break;
				     }
				   break;
				};

                case get_list:
		case put_list:
		case get_nil:
		case put_nil:	/* get_nil An */
				scanf(" A%d", &(instr->data.register_no));
				load_instr(*instr);
				break;

		case get_perm_variable:	/* get_variable Yn,Ai */
		case put_perm_variable:
		case get_perm_value:
		case put_perm_value:
		case put_unsafe_value:	/* before anything else, must establish
					for some of these whether it is a temp.
					or permanent vbl, by looking to see if a
					Y or X is first */
				{ char flag[2];

					scanf(" %[XY]", flag);
					if (strcmp(flag, "X") == 0)
					switch (op) {
						case get_perm_variable:
							instr->opcode = get_temp_variable;
							break;
						case put_perm_variable:
							instr->opcode = put_temp_variable;
							break;
						case get_perm_value:
							instr->opcode = get_temp_value;
							break;
						case put_perm_value:
							instr->opcode = put_temp_value;
							break;
						default:
							break;
					};
				};
				scanf("%d , A%d", &(instr->data.r_v.vbl_no),
						  &(instr->data.r_v.register_no));
				load_instr(*instr);
				break;
		case unify_void:scanf("%d", &(instr->data.void_no));
				load_instr(*instr);
				break;
		case unify_constant:
				{ atom_name name;

				  scanf(" %s", name); 
				  instr->data.r_c.c_number =
					ADD_TAG(atom_tbl_addr(name),
							CONST_TAG);
				  load_instr(*instr);
				  break;
 				}
		case unify_perm_variable:
		case unify_perm_value:
		case unify_perm_local_value:
				
				{ char flag[2];

					scanf(" %[XY]", flag);
					if (strcmp(flag, "X") == 0)
					switch (op) {
						case unify_perm_variable:
							instr->opcode = unify_temp_variable;
							break;
						case unify_perm_value:
							instr->opcode = unify_temp_value;
							break;
						case unify_perm_local_value:
							instr->opcode = unify_temp_local_value;
							break;
					};
				};
				scanf("%d", &(instr->data.register_no));
				load_instr(*instr);
				break;
		case switch_on_type :	
				scanf(" %d, %d, %d, %d",
					&(instr->data.s.Lv),
					&(instr->data.s.Lc),
					&(instr->data.s.Ll),
					&(instr->data.s.Ls));
				if (instr->data.s.Lv != -1)
				  instr->data.s.Lv += codetop;
				if (instr->data.s.Lc != -1)
				  instr->data.s.Lc += codetop;
				if (instr->data.s.Ll != -1)
				  instr->data.s.Ll += codetop;
				if (instr->data.s.Ls != -1)
				  instr->data.s.Ls += codetop;
				load_instr(*instr);
				break;

		case switch_on_constant :
				{int i,N;
				 atom_name name;

				 scanf(" %d,", &N);
				 scanf(" [");
				 for (i=0; i<N; i++)
				 {	scanf(" %[^ :]", name);
					instr->data.hash_tbl[i].at =
						ADD_TAG(atom_tbl_addr(name),
							CONST_TAG);
					scanf(" : %d,", &instr->data.hash_tbl[i].br);
					instr->data.hash_tbl[i].br += codetop;
				 };
				 scanf(" ]");
				 for (i=N; i<HASH_MAX; i++)
					instr->data.hash_tbl[i].at = FAIL_PROC;
				 load_instr(*instr);
			         break;
				}

		default:	printf("\7Unimplemented instruction!\n");
	}
}

static void load_instr(instr)
struct instr_type instr;
{
	if (codetop >= MAXCODE)
		fatal("Program too large");
	codestore[codetop++] = instr;
}

static void add_call(n)
char *n;
{
/* for instructions call P,N and execute P, find and use address of P
   if it is already defined, else add this instruction to a list of
   unresolved calls for this procedure
*/
  	int i;
 
	for ( i = 0; i < proc_count; i++)
		if (strcmp(proc_table[i].p_name, n) == 0)
		{	/* if address known put it in straight away */
			if (proc_table[i].p_addr != FAIL_PROC)
				codestore[codetop-1].data.c.p_addr =
						proc_table[i].p_addr;
			else /* add this one to list of unresolved jumps */
			{	struct unres_proc *p;

				p = (struct unres_proc *)
					malloc(sizeof(struct unres_proc));
				if ( p == NULL)
					fatal("malloc: can't allocate space");
				p->next_unres = proc_table[i].p_unres;
				p->unres_addr = codetop - 1;
				proc_table[i].p_unres = p;
				proc_table[i].p_addr = FAIL_PROC;
			}
		return;
		}
	/* not known so far */
	proc_table[proc_count].p_unres =
				 (struct unres_proc *)                
					malloc(sizeof(struct unres_proc));
				if ( proc_table[proc_count].p_unres == NULL)
					fatal("malloc: can't allocate space");
	proc_table[proc_count].p_unres->unres_addr = codetop - 1;
	proc_table[proc_count].p_unres->next_unres = NULL;
           
	proc_table[proc_count].p_addr = FAIL_PROC;		/* default fail */
	strcpy(proc_table[proc_count++].p_name, n);
}

void fix_unres_addr()
{	int i, c;
 	struct unres_proc *p;

	for (i = 0; i < proc_count; i++)
	{
		p = proc_table[i].p_unres;
		c = proc_table[i].p_addr;
		while (p != NULL)
		{

			codestore[p->unres_addr].data.c.p_addr = c;
			p = p->next_unres;
		}
	}
}


static int atom_tbl_addr(name)
atom_name name;
{
/* find in or add an atom to atom table */
	int i;

	for (i = 0; i < atom_top; i++)
		if (strcmp(atom_table[i], name) == 0)
			return(i);
	if (atom_top == MAXATOMS)
		fatal("too many atoms");
	strcpy(atom_table[atom_top], name);
	return(atom_top++);
}

static void skip_comments()
{	/* each file is allowed to start with a commented section, with
	   each line begun with a '%' 
	*/
	int c;

	while ( (c = getc(stdin)) == '%')
		while ( (c = getc(stdin)) != '\n');
	ungetc(c, stdin);
}
