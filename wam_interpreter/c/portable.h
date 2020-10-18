/* WAM emulator
	module portable.h
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not be used for any commercial purposes.
*/

/* This file is a subset of the portability constructs advocated in
   J.E. Lapin "Portable C and Unix System Programming
*/

/* This version of portable.h is for an IBM AT running MicroPort System V */

/* not needed in System V
#include <stdlib.h>
#include <malloc.h>
*/

#define public
#define private static
