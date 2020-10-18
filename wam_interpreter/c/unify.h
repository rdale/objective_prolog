/* unify.i -- declarations file for module unify */

#ifndef _UNIFY_H
#define _UNIFY_H

#include "types.h"

extern address unify(address term1, address term2);
extern void bind(address Vbl, address Term);
extern void trail_instr(address vbl);

/* unify.i ends here */

#endif
