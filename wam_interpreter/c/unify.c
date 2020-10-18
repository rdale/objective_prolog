
/* WAM emulator
	module unify.c
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not not be used for any commercial purposes.
*/

#include <stdio.h>

#include "const.h"
#include "tags.h"
#include "types.h"
#include "main.h"
#include "unify.h"

extern address TR, HB, H, B;
extern address memory[];

static int arity();

static void push_trail(address vbl)
{
  if (TR == HIGHTRAIL)
      fatal("trail overflow");
  *(memory + TR++) = vbl;
}

void trail_instr(address vbl)
{
  address v;

  v = WITHOUT_TAG(vbl);
  if ((v >= LOWHEAP) && (v < HIGHHEAP))
  {
    if (v < HB)
      push_trail(v);
  }
  else
    if (v < B - 6 - MAXREGISTER + 1)
      push_trail(v);
}

address deref(V)
address V;
{
  while (TAG_OF(V) == REF_TAG)
    V = *(memory + WITHOUT_TAG(V));
  return(V);
}


void bind(address Vbl, address Term)
{
  *(memory + WITHOUT_TAG(Vbl)) = Term;
  trail_instr(Vbl);
}
extern atom_name atom_table[];

static int arity(int addr)
{  	int a;
	atom_name n;

	sscanf(atom_table[addr], " %[^/] / %d", n, &a);
	return(a);
}

address unify(address term1, address term2)
{
	address tag1, tag2;
	if (term1 == term2)
		return(term1);
	while (TAG_OF(term1) == REF_TAG)
		term1 = *(memory + WITHOUT_TAG(term1));
	while (TAG_OF(term2) == REF_TAG)
		term2 = *(memory + WITHOUT_TAG(term2));
	tag1 = TAG_OF(term1);
	tag2 = TAG_OF(term2);
	if (tag1 == VBL_TAG)
	{	
		if (tag2 == VBL_TAG)
		{
			if (term1 < term2)
			{	*(memory + WITHOUT_TAG(term1)) = ADD_TAG(term2, REF_TAG);
				trail_instr(term1);
				return(term2);
			}
			else
			{	*(memory + WITHOUT_TAG(term2)) = ADD_TAG(term1, REF_TAG);
				trail_instr(term2);
				return(term1);
			}
		}
		bind(term1, term2);
		return(term2);
	}
	else
	if (tag1 ==  LIST_TAG)	
	{
		if (tag2 == VBL_TAG)
		{	bind(term2, term1);
			return(term1);
		};
		if (tag2 != LIST_TAG)
			return(FAIL);
		if (unify(*(memory+WITHOUT_TAG(term1)+1), 
			  *(memory+WITHOUT_TAG(term2)+1))
				&& unify(*(memory+WITHOUT_TAG(term1)+2), 
					 *(memory+WITHOUT_TAG(term2)+2)))
			return(term1);
		return(FAIL);
	}
	else
	if (tag1 ==  CONST_TAG)	
	{
		if (tag2 == VBL_TAG)
		{	bind(term2, term1);
			return(term1);
		};
		if (term1 == term2)
			return(term1);
		return(FAIL);
	}
	else
	if (tag1 ==  NIL_TAG)	
	{
		if (tag2 == VBL_TAG)
		{	bind(term2, ADD_TAG(0, NIL_TAG));
			return(term1);
		};
		if (tag2 == NIL_TAG)
			return(term1);
		return(FAIL);
	}
	else
	if (tag1 == STRUCT_TAG)
	{
		if (tag2 == VBL_TAG)
		{	bind(term2, term1);
			return(term1);
		};
		if (tag2 != STRUCT_TAG)
			return(FAIL);
		if ( *(memory+1+WITHOUT_TAG(term1)) != *(memory+1+WITHOUT_TAG(term2)) )
			return(FAIL);
		{ int i, count;

			count = arity(WITHOUT_TAG(*(memory+1 + WITHOUT_TAG(term1))));
			for (i = 1; i <= count; i++)
				if (!unify(*(memory+WITHOUT_TAG(term1)+1+i), 
					   *(memory+WITHOUT_TAG(term2)+1+i)))
					return(FAIL);
			return(term1);
		};
	};
	return(FAIL);
}

