GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = ObjcProlog

ObjcProlog_HEADERS = \
    Binding.h \
    BuiltinPredicate.h \
    Clause.h \
    FunctionTerm.h \
    Goal.h \
    InfixExpression.h \
    ListIterator.h \
    ListTerm.h \
    NamedVariable.h \
    NestedStructureIterator.h \
    NSOutputStream_Printf.h \
    NumericTerm.h \
    ObjcProlog.h \
    PostfixExpression.h \
    PrefixExpression.h \
    prolog.h \
    Prolog.h \
    ProofTree.h \
    Relation.h \
    Structure.h \
    Term.h \
    Unify.h \
    VariableTerm.h

ObjcProlog_OBJC_FILES = \
    Binding.m \
    BuiltinPredicate.m \
    Clause.m \
    FunctionTerm.m \
    Goal.m \
    InfixExpression.m \
    ListIterator.m \
    ListTerm.m \
    NamedVariable.m \
    NestedStructureIterator.m \
    NSOutputStream_Printf.m \
    NumericTerm.m \
    PostfixExpression.m \
    PrefixExpression.m \
    Prolog.m \
    ProofTree.m \
    Relation.m \
    Structure.m \
    Term.m \
    Unify.m \
    VariableTerm.m \
    parse.m \
    tokenise.m \
    main.m

ObjcProlog_RESOURCE_FILES =

include $(GNUSTEP_MAKEFILES)/application.make

parse.m y.tab.h: parse.ym
	$(YACC) -ydv parse.ym
	mv y.tab.c parse.m

tokenise.m: tokenise.lm y.tab.h
	$(LEX) -d -o tokenise.m tokenise.lm
