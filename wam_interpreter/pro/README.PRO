
The compiler files are

    COMPILER.PRO
    PERM_TEMP.PRO
    NUMBER_TEMPS.PRO
    COMP.PRO
    ALLOC_DEALLOC.PRO
    COMP_PRO.PRO
    PERM.PRO
    VBL_VALUE.PRO
    NUMBER_PERMS.PRO
    UNIFY_VOID.PRO

with extra files SICSTUS.PRO or ARITY.PRO which should be loaded first,
depending on the Prolog used. (Sicstus is designed to be functionally
compatable to Quintus, but I haven't tested it under Quintus.)

Consulting "compiler.pro" will load the rest of the files.
A Prolog source file can be compiled to WAM
code with output to stdout by the goal

                  ?- compile_file(Source_file).

Clause indexing instructions are not generated. In addition the
compiler does not generate "get_list", "get_nil" instructions instead
of "get_structure ./2" etc but this is minor.

NB: The compiler will generate correct registers for compound
structures.  However, the number of registers used will grow
according to the complexity of the structure (e.g. [1,2,3] uses 2
registers, [1,2,3,4,5] uses 4).  The WAM emulator uses a fixed number
of registers, so large structures may blow this limit. No warnings
are issued.

The compiler will not compile itself. This is because of various
arithmetic and metalogical constructs, but also due to heavy use of
the 'if then else' construct. This was done intentionally to avoid
the use of 'red' cuts and to avoid the use of incorrect 'catchall'
clauses at the end of a predicate.

