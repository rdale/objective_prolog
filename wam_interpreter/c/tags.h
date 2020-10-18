
/* WAM emulator
	module tags.h
	version 1.1
	date 89/09/19
   Copyright J.D. Newmarch
   This software may be used freely for educational purposes
   and may be distributed as long as this copyright notice is
   retained.  It may not be used for any commercial purposes.
*/
#ifndef _TAGS_H
#define _TAGS_H

#define tag_32_hi    

#ifdef tag_32_hi     /* tag is top 3 bits of 32 bit integer */
#define TAG_MASK	(address) 0340000000 	/* 1110..0 */
#define UNTAG_MASK	(address) 037777777 	/* 0001..1 */
#define CONST_TAG	(address) 0340000000 	/* 1110..0 */
#define REF_TAG		(address) 0300000000 	/* 1100..0 */
#define LIST_TAG	(address) 0240000000 	/* 1010..0 */
#define STRUCT_TAG	(address) 0200000000 	/* 1000..0 */
#define VBL_TAG		(address) 0140000000 	/* 0110..0 */
#define NIL_TAG		(address) 0100000000 	/* 0100..0 */
#define INT_TAG		(address) 0040000000 	/* 0010..0 */
#endif

#ifdef tag_16_hi     /* tag is top 3 bits of 16 bit integer */
#define TAG_MASK	(address) 0160000 	/* 1110..0 */
#define UNTAG_MASK	(address) 017777 	/* 0001..1 */
#define CONST_TAG	(address) 0160000 	/* 1110..0 */
#define REF_TAG		(address) 0140000 	/* 1100..0 */
#define LIST_TAG	(address) 0120000 	/* 1010..0 */
#define STRUCT_TAG	(address) 0100000 	/* 1000..0 */
#define VBL_TAG		(address) 060000 	/* 0110..0 */
#define NIL_TAG		(address) 040000 	/* 0100..0 */
#define INT_TAG		(address) 020000 	/* 0010..0 */
#endif

#define TAG_OF(x)	((x) & TAG_MASK)
#define WITHOUT_TAG(x)	((x) & UNTAG_MASK)
 
#define ADD_TAG(x, TYPE)	(((x) & UNTAG_MASK) | TYPE)

#define isconstant(x)		(TAG_OF(x) == CONST_TAG)
#define unbound(x)		(TAG_OF(x) == VBL_TAG)

/* The above are specific versions of these general cases:
   
 	UNTAG_MASK	= (unsigned) (~0) >>3;
	TAG_MASK	= ~UNTAG_MASK;
	CONST_TAG	= (UNTAG_MASK + 1) * 7;
	REF_TAG	= (UNTAG_MASK + 1) * 6;
	LIST_TAG	= (UNTAG_MASK + 1) * 5;
	STRUCT_TAG	= (UNTAG_MASK + 1) * 4;
	INT_TAG	= (UNTAG_MASK + 1) * 3;
	VBL_TAG	= (UNTAG_MASK + 1) * 2;
	NIL_TAG	= (UNTAG_MASK + 1) * 1;
*/

#endif

