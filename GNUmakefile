#
# GNUmakefile - Generated by ProjectCenter
#
ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif
ifeq ($(GNUSTEP_MAKEFILES),)
 $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

#
# Tool
#
VERSION = 0.1
PACKAGE_NAME = ObjcProlog
TOOL_NAME = ObjcProlog
ObjcProlog_TOOL_ICON = 


#
# Libraries
#
ObjcProlog_LIBRARIES_DEPEND_UPON += -lreadline 

#
# Resource files
#
ObjcProlog_RESOURCE_FILES = \
Resources/Version \
Resources/startup.pl 


#
# Header files
#
ObjcProlog_HEADER_FILES = \
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
PostfixExpression.h \
PrefixExpression.h \
Prolog.h \
ProofTree.h \
Relation.h \
Structure.h \
Term.h \
Unify.h \
VariableTerm.h \
parse.h \
prolog.h \
y.tab.h

#
# Class files
#
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
VariableTerm.m

#
# Other sources
#
ObjcProlog_OBJC_FILES += \
main.m \
parse.m \
tokenise.m 

#
# Makefiles
#
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/tool.make
-include GNUmakefile.postamble
